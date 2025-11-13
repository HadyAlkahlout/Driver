import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/toast.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

class OverlayService {
  // Keys for SharedPreferences
  static const String _overlayPermissionKey = 'overlay_permission_granted';
  static const String _overlayPermissionRequestedKey =
      'overlay_permission_requested';

  //
  Future<void> showFloatingBubble() async {
    //
    // Check if we've already requested permission and it was granted
    final prefs = await SharedPreferences.getInstance();
    final permissionPreviouslyGranted =
        prefs.getBool(_overlayPermissionKey) ?? false;
    final permissionPreviouslyRequested =
        prefs.getBool(_overlayPermissionRequestedKey) ?? false;

    // If permission was previously granted, try to show overlay without requesting again
    if (permissionPreviouslyGranted) {
      bool isGranted = await FlutterOverlayWindow.isPermissionGranted();
      if (isGranted) {
        await _showOverlay();
        return;
      } else {
        // Permission was revoked, update our records
        await prefs.setBool(_overlayPermissionKey, false);
      }
    }

    // If we haven't requested permission before or it was denied, check current status
    bool status = await FlutterOverlayWindow.isPermissionGranted();

    // If not granted and we haven't asked before, request it
    if (!status && !permissionPreviouslyRequested) {
      status = await FlutterOverlayWindow.requestPermission() ?? false;
      // Save that we've requested the permission
      await prefs.setBool(_overlayPermissionRequestedKey, true);
      // Save the result
      await prefs.setBool(_overlayPermissionKey, status);
    }

    /// Open overLay content
    if (status) {
      await _showOverlay();
    } else {
      ToastService.toastError("Permission for overlay is not granted".tr());
      //show as regular notification
    }
  }

  /// Show the overlay content
  Future<void> _showOverlay() async {
    //if there is previous overlay, close it
    await closeFloatingBubble();
    //
    int width =
        (AppService().navigatorKey.currentContext!.percentWidth * 40).ceil();
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      height: width,
      width: width,
      alignment: OverlayAlignment.topLeft,
      positionGravity: PositionGravity.auto,
      overlayTitle: "Awaiting New Order".tr(),
      overlayContent: "You will be notified when there is a new order".tr(),
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      startPosition: const OverlayPosition(0, kToolbarHeight + 20),
    );

    // Save that permission is granted
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OverlayService._overlayPermissionKey, true);
  }

  /// Close the overlay
  closeFloatingBubble() async {
    //if is not android, return
    if (!Platform.isAndroid) {
      return;
    }
    final isOpen = await FlutterOverlayWindow.isActive();

    if (isOpen) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  /// Method to check if overlay permission is granted
  static Future<bool> isOverlayPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionPreviouslyGranted =
        prefs.getBool(_overlayPermissionKey) ?? false;

    if (permissionPreviouslyGranted) {
      bool isCurrentlyGranted =
          await FlutterOverlayWindow.isPermissionGranted();
      return isCurrentlyGranted;
    }

    return false;
  }

  /// Method to reset permission state (useful for testing)
  static Future<void> resetPermissionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_overlayPermissionKey);
    await prefs.remove(_overlayPermissionRequestedKey);
  }
}
