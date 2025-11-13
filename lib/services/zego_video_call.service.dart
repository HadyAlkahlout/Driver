import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoVideoCallService {
  // ZegoCloud credentials - Updated to use the working credentials
  static const int appID = 1386611196;
  static const String appSign =
      'a3c2d5d7fee736984686f5bff89c066a02efb63f91794f7e2907931ae9acb13e';

  static bool _isInitialized = false;
  static Timer? _callListenerTimer;

  // Callbacks for call events
  static Function(String orderId)? onIncomingCall;
  static Function()? onCallEnded;
  static Function(String error)? onError;

  // Initialize ZegoCloud service
  static Future<void> initialize(String driverUserId, String driverName) async {
    if (_isInitialized) return;

    try {
      debugPrint(
        'ZegoVideoCall: Initializing ZegoCloud service for driver: $driverUserId',
      );

      // Initialize ZegoUIKitPrebuiltCallInvitationService with proper configuration
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appID,
        appSign: appSign,
        userID: driverUserId,
        userName: driverName,
        plugins: [ZegoUIKitSignalingPlugin()],
        requireConfig: (ZegoCallInvitationData data) {
          final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
          // Keep default UI; only basic visibility tweaks if needed
          config.topMenuBar.isVisible = true;
          config.bottomMenuBar.isVisible = true;
          return config;
        },
        events: ZegoUIKitPrebuiltCallEvents(
          onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
            debugPrint('ZegoVideoCall: Call ended - ${event.reason}');
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
      debugPrint('ZegoVideoCall: ZegoCloud service initialized successfully');

      // Start listening for legacy call notifications (compatibility with old system)
      _startCallListener();
    } catch (e) {
      debugPrint('ZegoVideoCall: Error initializing service: $e');
      onError?.call('Failed to initialize video call service: $e');
      rethrow;
    }
  }

  // Start listening for call notifications (compatibility with existing system)
  static void _startCallListener() {
    _callListenerTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      await _checkForIncomingCalls();
    });
  }

  // Check for incoming call notifications
  static Future<void> _checkForIncomingCalls() async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!downloadDir.existsSync()) return;

      final files =
          downloadDir
              .listSync()
              .where(
                (file) =>
                    file.path.contains('geomart_call_notification_') &&
                    file.path.endsWith('_driver.json'),
              )
              .cast<File>();

      for (final file in files) {
        if (file.existsSync()) {
          final content = await file.readAsString();
          debugPrint('ZegoVideoCall: Found call notification: $content');

          // Extract order ID from filename
          final filename = file.path.split('/').last;
          final orderIdMatch = RegExp(
            r'geomart_call_notification_(\d+)_driver\.json',
          ).firstMatch(filename);

          if (orderIdMatch != null) {
            final orderId = orderIdMatch.group(1)!;
            onIncomingCall?.call(orderId);

            // Clean up the file
            await file.delete();
            debugPrint(
              'ZegoVideoCall: Call notification processed and cleaned up',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('ZegoVideoCall: Error checking for calls: $e');
    }
  }

  // Stop listening for calls
  static void stopCallListener() {
    _callListenerTimer?.cancel();
    _callListenerTimer = null;
    debugPrint('ZegoVideoCall: Call listener stopped');
  }

  // Uninitialize service
  static Future<void> uninitialize() async {
    try {
      debugPrint('ZegoVideoCall: Uninitializing ZegoCloud service...');
      stopCallListener();
      ZegoUIKitPrebuiltCallInvitationService().uninit();
      _isInitialized = false;
      debugPrint('ZegoVideoCall: Service uninitialized');
    } catch (e) {
      debugPrint('ZegoVideoCall: Error uninitializing service: $e');
    }
  }

  // Accept incoming call
  static Future<void> acceptCall() async {
    try {
      debugPrint('ZegoVideoCall: Accepting incoming call');
      // ZegoCloud handles call acceptance automatically through UI
      debugPrint('ZegoVideoCall: Call acceptance handled by ZegoCloud UI');
    } catch (e) {
      debugPrint('ZegoVideoCall: Error accepting call: $e');
      onError?.call('Failed to accept call: $e');
    }
  }

  // Reject incoming call
  static Future<void> rejectCall() async {
    try {
      debugPrint('ZegoVideoCall: Rejecting incoming call');
      // ZegoCloud handles call rejection automatically through UI
      debugPrint('ZegoVideoCall: Call rejection handled by ZegoCloud UI');
    } catch (e) {
      debugPrint('ZegoVideoCall: Error rejecting call: $e');
      onError?.call('Failed to reject call: $e');
    }
  }

  // Make a call to customer (if needed)
  static Future<void> makeVideoCall(
    String customerUserID,
    String customerName,
  ) async {
    try {
      debugPrint(
        'ZegoVideoCall: Making video call to customer: $customerUserID',
      );

      // Send call invitation to customer
      ZegoUIKitPrebuiltCallInvitationService().send(
        isVideoCall: true,
        invitees: [ZegoCallUser(customerUserID, customerName)],
        customData: 'Driver calling customer for order assistance',
      );

      debugPrint('ZegoVideoCall: Video call invitation sent successfully');
    } catch (e) {
      debugPrint('ZegoVideoCall: Error making video call: $e');
      onError?.call('Failed to make video call: $e');
    }
  }

  // Make a voice call to customer (if needed)
  static Future<void> makeVoiceCall(
    String customerUserID,
    String customerName,
  ) async {
    try {
      debugPrint(
        'ZegoVideoCall: Making voice call to customer: $customerUserID',
      );

      // Send call invitation to customer
      ZegoUIKitPrebuiltCallInvitationService().send(
        isVideoCall: false,
        invitees: [ZegoCallUser(customerUserID, customerName)],
        customData: 'Driver calling customer for order assistance',
      );

      debugPrint('ZegoVideoCall: Voice call invitation sent successfully');
    } catch (e) {
      debugPrint('ZegoVideoCall: Error making voice call: $e');
      onError?.call('Failed to make voice call: $e');
    }
  }

  // Check if service is initialized
  static bool get isInitialized => _isInitialized;

  // Update driver info
  static Future<void> updateDriverInfo(
    String driverUserId,
    String driverName,
  ) async {
    try {
      debugPrint(
        'ZegoVideoCall: Updating driver info: $driverUserId, $driverName',
      );

      // Reinitialize with new info
      await uninitialize();
      await initialize(driverUserId, driverName);

      debugPrint('ZegoVideoCall: Driver info updated successfully');
    } catch (e) {
      debugPrint('ZegoVideoCall: Error updating driver info: $e');
      onError?.call('Failed to update driver info: $e');
    }
  }
}
