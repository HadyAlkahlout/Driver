import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/services/background_order.service.dart';
import 'package:fuodz/services/firebase_token.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/views/pages/video_call/incoming_call_screen.dart';
import 'package:fuodz/models/notification.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:singleton/singleton.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.data}');

  // Process order notifications in background
  final data = message.data;
  if (data.containsKey('newOrder') || data.containsKey('order_id')) {
    try {
      // Process delivery order
      final newOrder = NewOrder.fromJson(data, clean: true);
      print("Background processing delivery order: ${newOrder.id}");
      BackgroundOrderService().processOrderNotification(newOrder);
    } catch (e) {
      print("Error processing background order notification: $e");
    }
  }
}

class FirebaseService {
  //
  // Removed request instances

  //
  NotificationModel? notificationModel;
  FirebaseMessaging? firebaseMessaging;
  Map? notificationPayloadData;

  // Firebase initialization for notifications only
  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      firebaseMessaging = FirebaseMessaging.instance;
      print("Firebase initialized for notifications only");
    } catch (e) {
      print("Firebase initialization failed: $e");
    }
  }

  setUpFirebaseMessaging() async {
    print("Setting up Firebase messaging for order notifications only");

    try {
      await initializeFirebase();

      if (firebaseMessaging == null) {
        print("Firebase messaging not available");
        return;
      }

      // Request permission for notifications
      NotificationSettings settings = await firebaseMessaging!
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission for notifications');

        // Get FCM token for backend registration
        String? token = await firebaseMessaging!.getToken();
        if (token != null) {
          print("FCM Token: $token");
          // Send token to backend for driver topic subscription
          await FirebaseTokenService.instance.syncDeviceTokenWithServer(token, true);

          // Subscribe to driver topic for video calls
          if (AuthServices.authenticated()) {
            final currentUser = AuthServices.currentUser;
            if (currentUser != null) {
              final driverTopic = 'driver_${currentUser.id}';
              await firebaseMessaging!.subscribeToTopic(driverTopic);
              print('Subscribed to driver topic: $driverTopic');
            }
          }
        }

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Received foreground message: ${message.data}');
          handleOrderNotification(message);
        });

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('Notification tapped: ${message.data}');
          handleOrderNotification(message);
        });
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print("Firebase messaging setup failed: $e");
    }
  }

  // Handle order notifications and chat messages
  void handleOrderNotification(RemoteMessage message) {
    final data = message.data;

    // Check if this is a video call notification
    if (data.containsKey('is_video_call') && data['is_video_call'] == '1') {
      print("Processing video call notification: $data");
      _handleVideoCallNotification(data);
      return;
    }

    // Check if this is a chat notification
    if (data.containsKey('path') &&
        data['path']?.toString().contains('/chat/') == true) {
      print("Processing chat notification: $data");
      // Chat notifications are handled by the chat polling system
      // Just show a local notification if needed
      return;
    }

    // Check if this is an order notification
    if (data.containsKey('newOrder') || data.containsKey('order_id')) {
      print("Processing order notification: $data");

      try {
        // Process the order notification through the proper service
        // Parse the newOrder data if it's a JSON string
        Map<String, dynamic> orderData = data;
        if (data.containsKey('newOrder')) {
          final newOrderData = data['newOrder'];
          if (newOrderData is String) {
            // Parse JSON string to Map
            orderData = json.decode(newOrderData);
          } else if (newOrderData is Map<String, dynamic>) {
            orderData = newOrderData;
          }
        }

        // Check if it's a taxi order or regular order
        // Process delivery order
        final newOrder = NewOrder.fromJson(orderData, clean: true);
        print("Processing delivery order notification: ${newOrder.id}");
        BackgroundOrderService().processOrderNotification(newOrder);
      } catch (e) {
        print("Error processing order notification: $e");
        // Fallback to showing basic notification
        showNotification(message);
      }
    } else {
      print("Non-order notification ignored: $data");
    }
  }

  //write to notification list
  Future<void> saveNewNotification(
    dynamic message, {
    String? title,
    String? body,
  }) async {
    print("Saving order notification: $title - $body");
    // Save notification to local storage for processing
    try {
      if (message is RemoteMessage) {
        final data = message.data;
        // Store notification data for order processing
        notificationPayloadData = data;
      }
    } catch (e) {
      print("Error saving notification: $e");
    }
  }

  //
  showNotification(dynamic message) async {
    print("Showing order notification");
    try {
      if (message is RemoteMessage) {
        final data = message.data;
        final title = message.notification?.title ?? "New Order";
        final body = message.notification?.body ?? "You have a new order";

        // Use AwesomeNotifications to show local notification
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'new_order_channel',
            title: title,
            body: body,
            payload: data.map((key, value) => MapEntry(key, value?.toString())),
            notificationLayout: NotificationLayout.Default,
          ),
        );
      }
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  //
  selectNotification(String? payload) async {
    print("Order notification selected: $payload");
    // Handle notification tap - this will be processed by NotificationService
  }

  refreshOrdersList(dynamic message) {
    print("Refreshing orders list from notification");
    // Trigger order list refresh
  }

  // Handle video call notifications
  void _handleVideoCallNotification(Map<String, dynamic> data) {
    try {
      final callStatus = data['call_status'] ?? 'incoming';
      final sessionId = data['session_id'] ?? '';
      final callerName = data['caller_name'] ?? 'Unknown';
      final callerType = data['caller_type'] ?? 'customer';
      final agoraChannelName = data['agora_channel_name'] ?? '';
      final callerUID =
          int.tryParse(data['caller_uid']?.toString() ?? '0') ?? 0;

      print(
        'FirebaseService: Handling video call notification - Status: $callStatus, Session: $sessionId',
      );

      switch (callStatus) {
        case 'incoming':
          _showIncomingCallNotification(
            sessionId: sessionId,
            callerName: callerName,
            callerType: callerType,
            agoraChannelName: agoraChannelName,
            callerUID: callerUID,
          );
          break;
        case 'accepted':
          print('FirebaseService: Call was accepted by the other party');
          // The enhanced video call service will handle this through polling
          break;
        case 'rejected':
          print('FirebaseService: Call was rejected by the other party');
          // The enhanced video call service will handle this through polling
          break;
        case 'ended':
          print('FirebaseService: Call was ended');
          // The enhanced video call service will handle this through polling
          break;
        default:
          print('FirebaseService: Unknown call status: $callStatus');
      }
    } catch (e) {
      print('FirebaseService: Error handling video call notification: $e');
    }
  }

  // Show incoming call notification
  void _showIncomingCallNotification({
    required String sessionId,
    required String callerName,
    required String callerType,
    required String agoraChannelName,
    required int callerUID,
  }) {
    final context = AppService().navigatorKey.currentContext;
    if (context != null) {
      // Play ringtone
      AppService().playNotificationSound();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => IncomingCallScreen(
                callId: sessionId,
                callerName: callerName,
                callerPhoto: '', // Default empty photo, can be enhanced later
                callerType: callerType,
                callType: 'video', // Default to video call
                onCallDeclined: () {
                  AppService().stopNotificationSound();
                  // Handle call rejection
                },
                onCallAccepted: () {
                  AppService().stopNotificationSound();
                  // Handle call acceptance
                },
              ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  /// Factory method that reuse same instance automatically
  factory FirebaseService() => Singleton.lazy(() => FirebaseService._());

  /// Private constructor
  FirebaseService._() {}
}
