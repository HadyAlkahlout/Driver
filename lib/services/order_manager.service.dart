import 'dart:async';

// Removed cloud_firestore import
import 'package:flutter/foundation.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/background_order.service.dart';
// Removed firebase_order_handler import
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/new_order_websocket.service.dart';
import 'package:fuodz/services/order_assignment.service.dart';
import 'package:fuodz/services/pending_notifications.service.dart';
import 'package:schedulers/schedulers.dart';
import 'package:singleton/singleton.dart';

import 'app.service.dart';

class OrderManagerService {
  //
  /// Factory method that reuse same instance automatically
  factory OrderManagerService() =>
      Singleton.lazy(() => OrderManagerService._());

  /// Private constructor
  OrderManagerService._() {}

  //
  dynamic firebaseFireStore; // Removed FirebaseFirestore
  StreamSubscription<dynamic>? newOrderDocsRefSubscription;
  StreamSubscription<dynamic>? driverNewOrderDocsRefSubscription;
  StreamSubscription<dynamic>? firebaseOrderHandlerServiceSubscription;
  IntervalScheduler? driverNewOrderDataScheduler;
  final alertDriverNewOrderAlert = "can_notify_driver";

  //listen to driver new order firebase node
  startListener() async {
    //
    //for new driver matching system
    //for websocket
    if (AppStrings.useWebsocketAssignment) {
      NewOrderWebsocketService().connectToOrderChannel((eventData) {
        //
        if (kDebugMode) {
          print("Received Event: WebsocketDriverNewOrderEvent");
          print("Received Data: $eventData");
        }
        //check if empty data sent
        final newOrderAlertData = eventData;
        if (newOrderAlertData == null) {
          return;
        }

        // Process delivery order
        final newOrder = NewOrder.fromJson(newOrderAlertData);
        BackgroundOrderService().processOrderNotification(newOrder);

        // Start monitoring for order status changes
        monitorOrderStatusChanges();
      });
      /*
      final driverId = (await AuthServices.getCurrentUser()).id.toString();
      final _websocketService = WebsocketService();
      final channelName = "private-driver.new-order.$driverId";
      _websocketService.closeConnection();
      await _websocketService.init();
      _websocketService.echoClient!.channel(channelName).listen(
        "WebsocketDriverNewOrderEvent",
        (eventData) {
          //
          if (kDebugMode) {
            print("Received Event: WebsocketDriverNewOrderEvent");
            print("Received Data: $eventData");
          }
          //check if empty data sent
          final newOrderAlertData = eventData;
          if (newOrderAlertData == null) {
            return;
          }

          // Process delivery order
          final newOrder = NewOrder.fromJson(newOrderAlertData);
          BackgroundOrderService().processOrderNotification(newOrder);
        },
        //
      );
      */
      return;
    } else if (AppStrings.driverMatchingNewSystem) {
      return;
    }
    //old driver matching from firebase notification - ENABLED
    else {
      print(
        "Firebase order notifications enabled - processing order notifications",
      );
      // Firebase order processing is handled by BackgroundOrderService
      // through the Firebase messaging handlers in firebase.service.dart
      return;
    }
  }

  //stop
  bool stopListener() {
    newOrderDocsRefSubscription?.cancel();
    // WebsocketService().closeConnection();
    NewOrderWebsocketService().disconnect();
    // driverNewOrderDocsRefSubscription?.cancel();
    //
    firebaseOrderHandlerServiceSubscription?.cancel();
    firebaseOrderHandlerServiceSubscription = null;
    // Firebase order handler stopped
    print("Firebase order handler service stopped");
    return true;
  }

  //This is not monitor if the driver node onf ifrestore has the online/free fields
  //so it can be used in connecting order to drivers
  monitorOnlineStatusListener({AppService? appService}) async {
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    bool shouldGoOffline = false;

    if (AppStrings.useWebsocketAssignment) {
      await AuthRequest().updateOnlineStatus(
        isOnline: AppService().driverIsOnline,
      );
    } else {
      final driverDoc =
          await firebaseFireStore.collection("drivers").doc(driverId).get();
      //if exists
      if (driverDoc.exists) {
        //
        if (driverDoc.data() != null &&
            (!driverDoc.data()!.containsKey("online") ||
                !driverDoc.data()!.containsKey("free"))) {
          //forcefully update doc value
          await driverDoc.reference.update({
            "online":
                driverDoc.data()!.containsKey("online")
                    ? driverDoc.get("online")
                    : 1,
            "free":
                driverDoc.data()!.containsKey("free")
                    ? driverDoc.get("free")
                    : 1,
          });
        }
      } else {
        shouldGoOffline = true;
        await driverDoc.reference.set({
          "online": AppService().driverIsOnline ? 1 : 0,
          "free": 1,
        });
      }
    }
    //set the status to the backend
    if (shouldGoOffline) {
      await LocalStorageService.prefs!.setBool(AppStrings.onlineOnApp, false);
      if (appService != null) {
        appService.driverIsOnline = false;
      } else {
        AppService().driverIsOnline = false;
      }
    }
  }

  //
  void scheduleClearDriverNewOrderListener() {
    driverNewOrderDataScheduler?.dispose();
    driverNewOrderDataScheduler = null;

    if (driverNewOrderDataScheduler == null) {
      driverNewOrderDataScheduler = IntervalScheduler(
        delay: Duration(seconds: AppStrings.alertDuration),
      );
    }
    //
    driverNewOrderDataScheduler?.run(() => clearDriverNewOrderListener());
  }

  //This is delete exipred driver_new_order data
  void clearDriverNewOrderListener() async {
    //
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    final driverNewOrderData =
        await firebaseFireStore
            .collection("driver_new_order")
            .doc(driverId)
            .get();

    //
    if (driverNewOrderData.exists) {
      await firebaseFireStore
          .collection("driver_new_order")
          .doc(driverId)
          .delete();
    }
  }

  // Monitor order status changes to cleanup invalid notifications
  void monitorOrderStatusChanges() {
    // Check for pending notifications that may have become invalid
    Timer.periodic(Duration(seconds: 5), (timer) {
      _cleanupInvalidNotifications();
    });
  }

  void _cleanupInvalidNotifications() async {
    try {
      // Import the pending notifications service
      final pendingService = PendingNotificationsService();

      // Check regular orders
      final pendingOrders = List.from(pendingService.pendingOrders);
      for (final order in pendingOrders) {
        // Check if order is still valid
        if (order.docRef != null) {
          final isValid = await OrderAssignmentService.checkOrderStatus(
            order.toJson(),
            order.docRef!,
          );
          if (!isValid) {
            print(
              "DEBUG: Removing invalid regular order ${order.id} from pending notifications",
            );
            pendingService.removeOrderById(order.id!);
            BackgroundOrderService().removeOrderFromPending(order.id!);
          }
        }
      }
    } catch (error) {
      print("DEBUG: Error in cleanup invalid notifications: $error");
    }
  }
}
