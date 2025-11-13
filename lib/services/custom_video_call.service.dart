import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/overlay.service.dart';

class CustomVideoCallService {
  // ZegoCloud credentials - Updated to use the working credentials
  static const int appID = 1386611196;
  static const String appSign =
      'a3c2d5d7fee736984686f5bff89c066a02efb63f91794f7e2907931ae9acb13e';

  static bool _isInitialized = false;
  static String? _currentCallId;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('CustomVideoCall: Initializing ZegoCloud service...');

      if (!AuthServices.authenticated()) {
        debugPrint(
          'CustomVideoCall: User not authenticated, skipping initialization',
        );
        return;
      }

      final currentUser = await AuthServices.getCurrentUser();
      final userID = 'driver_${currentUser.id}';
      final userName = currentUser.name ?? 'Driver Account';

      await initializeWithUser(userID, userName);

      _isInitialized = true;
      debugPrint('CustomVideoCall: Service initialized successfully');
    } catch (e) {
      debugPrint('CustomVideoCall: Error initializing service: $e');
      rethrow;
    }
  }

  // Initialize ZegoCloud service with specific user
  static Future<void> initializeWithUser(String userID, String userName) async {
    if (_isInitialized) {
      await dispose();
    }

    try {
      debugPrint('CustomVideoCall: Initializing ZegoCloud for driver: $userID');

      // Check if overlay permission is granted
      bool overlayPermissionGranted =
          await OverlayService.isOverlayPermissionGranted();
      debugPrint(
        'CustomVideoCall: Overlay permission granted: $overlayPermissionGranted',
      );

      // Prepare permissions list based on overlay permission status
      List<ZegoCallInvitationPermission> permissions = [
        ZegoCallInvitationPermission.camera,
        ZegoCallInvitationPermission.microphone,
      ];

      // Only include systemAlertWindow permission if granted
      if (overlayPermissionGranted) {
        permissions.add(ZegoCallInvitationPermission.systemAlertWindow);
      }

      // Initialize ZegoUIKitPrebuiltCallInvitationService
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appID,
        appSign: appSign,
        userID: userID,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        config: ZegoCallInvitationConfig(permissions: permissions),
        requireConfig: (ZegoCallInvitationData data) {
          final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
          // Keep default UI; only basic visibility tweaks if needed
          config.topMenuBar.isVisible = true;
          config.bottomMenuBar.isVisible = true;
          return config;
        },
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
            debugPrint('CustomVideoCall: Call ended - ${event.reason}');
            defaultAction.call();
          },
        ),
        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
          // Enhanced debugging to understand when callbacks are triggered
          onIncomingCallDeclineButtonPressed: () {
            debugPrint(
              '*** DRIVER DEBUG: Incoming call declined via ZegoUIKit button',
            );
          },
          onIncomingCallAcceptButtonPressed: () {
            debugPrint(
              '*** DRIVER DEBUG: Incoming call accepted via ZegoUIKit button',
            );
          },
          onOutgoingCallCancelButtonPressed: () {
            debugPrint(
              '*** DRIVER DEBUG: Outgoing call cancelled via ZegoUIKit button',
            );
          },
        ),
      );

      _isInitialized = true;
      debugPrint('CustomVideoCall: ZegoCloud service initialized successfully');
    } catch (e) {
      debugPrint('CustomVideoCall: Error initializing ZegoCloud service: $e');
      rethrow;
    }
  }

  // Make a video call to customer
  static Future<void> makeVideoCall({
    required String receiverId,
    required String receiverName,
    String? receiverPhoto,
    String callType = 'video',
  }) async {
    try {
      if (!AuthServices.authenticated()) {
        throw Exception('User not authenticated');
      }

      debugPrint(
        'CustomVideoCall: Making $callType call to $receiverName (ID: $receiverId)',
      );

      final customerUserID =
          'customer_$receiverId'; // Convert to customer user ID format
      final isVideoCall = callType == 'video';

      // Send ZegoCloud call invitation
      await ZegoUIKitPrebuiltCallInvitationService().send(
        isVideoCall: isVideoCall,
        invitees: [ZegoCallUser(customerUserID, receiverName)],
        customData: 'Driver calling customer for order assistance',
      );

      // ZegoCloud will show its own outgoing call UI

      // Create call notification for customer app compatibility
      await _createCallNotificationForCustomer(
        receiverId,
        receiverName,
        callType,
      );

      debugPrint('CustomVideoCall: Call invitation sent successfully');
    } catch (e) {
      debugPrint('CustomVideoCall: Error making video call: $e');
      rethrow;
    }
  }

  // Create call notification for customer app compatibility
  static Future<void> _createCallNotificationForCustomer(
    String customerId,
    String customerName,
    String callType,
  ) async {
    try {
      debugPrint(
        'CustomVideoCall: Creating call notification for customer: $customerId',
      );

      // Use application documents directory instead of hardcoded path
      final directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/call_notifications');
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
      }

      final callFile = File(
        '${downloadDir.path}/geomart_call_notification_${customerId}_customer.json',
      );

      final currentUser = await AuthServices.getCurrentUser();
      final callData = {
        'callerName': currentUser.name ?? 'Driver Account',
        'callerType': 'driver',
        'channelName': 'zego_call_${DateTime.now().millisecondsSinceEpoch}',
        'uid': 'driver_${currentUser.id}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'callerApp': 'driver',
        'zegoCall': true, // Flag to indicate ZegoCloud call
        'callType': callType,
      };

      await callFile.writeAsString(jsonEncode(callData));
      debugPrint(
        'CustomVideoCall: Call notification created at: ${callFile.path}',
      );
    } catch (e) {
      debugPrint('CustomVideoCall: Error creating call notification: $e');
    }
  }

  // Update user info
  static Future<void> updateUserInfo(String userID, String userName) async {
    try {
      debugPrint('CustomVideoCall: Updating user info: $userID, $userName');

      await initializeWithUser(userID, userName);

      debugPrint('CustomVideoCall: User info updated successfully');
    } catch (e) {
      debugPrint('CustomVideoCall: Error updating user info: $e');
      rethrow;
    }
  }

  // Uninitialize service
  static Future<void> dispose() async {
    try {
      debugPrint('CustomVideoCall: Disposing ZegoCloud service...');
      ZegoUIKitPrebuiltCallInvitationService().uninit();
      _isInitialized = false;
      _currentCallId = null;
      debugPrint('CustomVideoCall: Service disposed');
    } catch (e) {
      debugPrint('CustomVideoCall: Error disposing service: $e');
    }
  }

  // Check if service is initialized
  static bool get isInitialized => _isInitialized;

  // Get current call ID
  static String? get currentCallId => _currentCallId;
}
