import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bg_launcher/bg_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:fuodz/services/order_assignment.service.dart';
import 'package:fuodz/services/pending_notifications.service.dart';
import 'package:fuodz/widgets/bottomsheets/new_order_alert.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:singleton/singleton.dart' as SingletonLib;
import 'package:velocity_x/velocity_x.dart';
import 'extened_order_service.dart';

class BackgroundOrderService extends ExtendedOrderService {
  //
  /// Factory method that reuse same instance automatically
  factory BackgroundOrderService() =>
      SingletonLib.Singleton.lazy(() => BackgroundOrderService._());

  /// Private constructor
  BackgroundOrderService._() {
    this.fbListener();
  }
  // StreamController<NewOrder> showNewOrderStream = StreamController.broadcast();
  NewOrder? newOrder;

  // Track processed message IDs to prevent duplicates
  final Set<String> _processedMessageIds = <String>{};
  Timer? _messageCleanupTimer;

  // Track recently processed order IDs with timestamps
  final Map<int, int> _recentlyProcessedOrders = <int, int>{};
  Timer? _orderCleanupTimer;

  // Generate a message ID based on order data and timestamp
  String _generateMessageId(NewOrder order) {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch ~/
        300000; // 5-minute window (consistent with pending notifications)
    return '${order.id ?? 0}_${order.vendorId ?? 0}_$timestamp';
  }

  // Check if a message was already processed
  bool _isMessageProcessed(String messageId) {
    return _processedMessageIds.contains(messageId);
  }

  // Check if order was recently processed (within 10 minutes)
  bool _isOrderRecentlyProcessed(int orderId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastProcessed = _recentlyProcessedOrders[orderId];
    if (lastProcessed != null) {
      final timeDiff = now - lastProcessed;
      return timeDiff < 600000; // 10 minutes in milliseconds (increased from 5)
    }
    return false;
  }

  // Mark order as recently processed
  void _markOrderAsProcessed(int orderId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _recentlyProcessedOrders[orderId] = now;
    print("DEBUG: Marked order $orderId as recently processed");

    // Start cleanup timer if not already running
    _orderCleanupTimer ??= Timer.periodic(Duration(minutes: 5), (timer) {
      // More frequent cleanup
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final beforeCount = _recentlyProcessedOrders.length;
      _recentlyProcessedOrders.removeWhere((id, timestamp) {
        return (currentTime - timestamp) >
            600000; // Remove older than 10 minutes (reduced from 15)
      });
      if (beforeCount != _recentlyProcessedOrders.length) {
        print(
          "DEBUG: Cleaned up ${beforeCount - _recentlyProcessedOrders.length} old processed orders",
        );
      }
    });
  }

  // Mark message as processed
  void _markMessageProcessed(String messageId) {
    _processedMessageIds.add(messageId);
    print("DEBUG: Marked message processed: $messageId");

    // Start cleanup timer if not already running
    _messageCleanupTimer ??= Timer.periodic(Duration(minutes: 3), (timer) {
      // More frequent cleanup
      final currentTimestamp =
          DateTime.now().millisecondsSinceEpoch ~/ 300000; // 5-minute window
      final beforeCount = _processedMessageIds.length;
      _processedMessageIds.removeWhere((id) {
        final parts = id.split('_');
        if (parts.length >= 3) {
          final timestamp = int.tryParse(parts[2]) ?? 0;
          return (currentTimestamp - timestamp) >
              4; // Remove older than 20 minutes (increased from 5)
        }
        return true;
      });
      if (beforeCount != _processedMessageIds.length) {
        print(
          "DEBUG: Cleaned up ${beforeCount - _processedMessageIds.length} old message IDs",
        );
      }
    });
  }

  //
  processOrderNotification(NewOrder newOrder) async {
    print("DEBUG: Processing regular order notification - ID: ${newOrder.id}");

    // Skip if order has no valid ID
    if (newOrder.id == null) {
      print("DEBUG: Order has no ID, skipping");
      return;
    }

    // Check if this order was recently processed (regardless of timestamp)
    if (_isOrderRecentlyProcessed(newOrder.id!)) {
      print(
        "DEBUG: Order ${newOrder.id} was recently processed, skipping duplicate",
      );
      return;
    }

    // Check for duplicate messages first
    final messageId = _generateMessageId(newOrder);
    if (_isMessageProcessed(messageId)) {
      print(
        "DEBUG: Message already processed for order ${newOrder.id}, skipping duplicate",
      );
      return;
    }

    // Additional check: if this order ID appears in any processed notification, skip it
    final anyOrderWithSameId = _processedMessageIds.any((key) {
      final parts = key.split('_');
      if (parts.length >= 1) {
        final orderId = int.tryParse(parts[0]);
        return orderId == newOrder.id;
      }
      return false;
    });

    if (anyOrderWithSameId) {
      print(
        "DEBUG: Order ${newOrder.id} ID found in processed messages, skipping duplicate",
      );
      return;
    }

    // Mark message as processed immediately to prevent race conditions
    _markMessageProcessed(messageId);
    _markOrderAsProcessed(newOrder.id!);

    print("DEBUG: Processing new order notification for order ${newOrder.id}");

    // First check if order is already assigned/completed by checking the order JSON data
    if (await _isOrderAlreadyProcessed(newOrder)) {
      print(
        "DEBUG: Order ${newOrder.id} is already processed/assigned, skipping notification",
      );
      return;
    }

    // Check if we should handle this order based on filters
    final canHandle = await OrderAssignmentService.driverCanHandleOrder(
      newOrder.toJson(),
      newOrder.docRef ?? '',
    );

    if (!canHandle) {
      print(
        "DEBUG: Driver cannot handle order ${newOrder.id}, skipping notification",
      );
      return;
    }

    // Check if this order is already in pending notifications to avoid duplicates
    final existingPendingOrders = PendingNotificationsService().pendingOrders;
    final alreadyPending = existingPendingOrders.any(
      (order) => order.id == newOrder.id,
    );

    if (alreadyPending) {
      print(
        "DEBUG: Order ${newOrder.id} is already in pending notifications, skipping",
      );
      return;
    }

    // Add to pending notifications list
    PendingNotificationsService().addPendingOrder(newOrder);
    print("DEBUG: Added regular order to pending notifications");

    //
    if (appIsInBackground()) {
      if (Platform.isAndroid && await FlutterOverlayWindow.isActive()) {
        BgLauncher.bringAppToForeground();
        showNewOrderInAppAlert(newOrder);
      } else {
        showNewOrderNotificationAlert(newOrder);
      }
    } else {
      showNewOrderInAppAlert(newOrder);
    }
  }

  // Remove order from pending notifications when it's taken by another driver
  void removeOrderFromPending(int orderId) {
    print("DEBUG: Removing order $orderId from pending notifications");
    PendingNotificationsService().removeOrderById(orderId);
  }

  //handle showing new order alert bottom sheet to driver in app
  showNewOrderInAppAlert(NewOrder newOrder) async {
    // Note: Order is already added to pending notifications in processOrderNotification

    final result = await showModalBottomSheet(
      context: AppService().navigatorKey.currentContext!,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return NewOrderAlertBottomSheet(newOrder);
      },
    );

    //
    if (result is bool && result) {
      // Remove from pending notifications when accepted
      PendingNotificationsService().removePendingOrder(newOrder.id!);
      AppService().refreshAssignedOrders.add(true);
    } else {
      // Remove from pending notifications when rejected
      PendingNotificationsService().removePendingOrder(newOrder.id!);

      // Only attempt to release if docRef is available
      if (newOrder.docRef != null && newOrder.docRef!.isNotEmpty) {
        await OrderAssignmentService.releaseOrderForotherDrivers(
          newOrder.toJson(),
          newOrder.docRef!,
        );
      }
    }
  }

  //
  //show notification
  showNewOrderNotificationAlert(
    NewOrder newOrder, {
    int notifcationId = 10,
  }) async {
    //
    //show action notification to driver
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifcationId,
        ticker: "${AppStrings.appName}",
        channelKey:
            NotificationService.newOrderNotificationChannel().channelKey!,
        title: "New Order Alert".tr(),
        backgroundColor: AppColor.primaryColorDark,
        body:
            ("Pickup Location".tr() +
                ": " +
                "${newOrder.pickup?.address} (${newOrder.pickup?.distance?.numCurrency}km)"),
        //
        payload: {
          "id": newOrder.id.toString(),
          "notifcationId": notifcationId.toString(),
          "newOrder": jsonEncode(newOrder.toJson()),
        },
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Transport,
        criticalAlert: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "open",
          label: "Open".tr(),
          color: AppColor.primaryColor,
        ),
      ],
    );

    return;
  }

  // Check if order is already processed/assigned
  Future<bool> _isOrderAlreadyProcessed(NewOrder order) async {
    try {
      // Check if the order has an assignment_id (assigned to someone)
      if (order.assignmentId != null && order.assignmentId! > 0) {
        print(
          "DEBUG: Order ${order.id} already has assignment ${order.assignmentId}",
        );
        return true;
      }

      // Check if order has expired
      if (order.expiresAt < DateTime.now().millisecondsSinceEpoch) {
        print("DEBUG: Order ${order.id} has expired");
        return true;
      }

      return false;
    } catch (error) {
      print("DEBUG: Error checking order processed status: $error");
      return false;
    }
  }
}
