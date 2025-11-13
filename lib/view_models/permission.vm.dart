import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/overlay.service.dart';
// import 'package:fuodz/views/pages/permission/widgets/request_bg_location_permission.view.dart';
import 'package:fuodz/views/pages/permission/widgets/request_bg_permission.view.dart';
import 'package:fuodz/views/pages/permission/widgets/request_location_permission.view.dart';
import 'package:fuodz/views/pages/permission/widgets/request_overlay_permission.view.dart';
import 'package:fuodz/views/pages/shared/home.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class PermissionViewModel extends MyBaseViewModel {
  PermissionViewModel(BuildContext context) {
    this.viewContext = context;
  }

  int currentStep = 0;
  PageController pageController = PageController();
  bool locationPermissionGranted = false;
  // bool bgLocationPermissionGranted = false;
  bool bgPermissionGranted = false;
  bool overlayPermissionGranted = false;

  // Keys for SharedPreferences
  static const String _overlayPermissionSkippedKey =
      'overlay_permission_skipped';
  static const String _overlayPermissionGrantedKey =
      'overlay_permission_granted';

  void initialise() async {
    //
    await fetchAllNeededPermissions();
  }

  fetchAllNeededPermissions() async {
    locationPermissionGranted = await isLocationPermissionGranted();
    // bgLocationPermissionGranted = await isBgLocationPermissionGranted();
    bgPermissionGranted = await isBgPermissionGranted();
    overlayPermissionGranted =
        await OverlayService.isOverlayPermissionGranted();

    // Check if user has previously made a decision about overlay permission
    final prefs = await SharedPreferences.getInstance();
    final overlaySkipped = prefs.getBool(_overlayPermissionSkippedKey) ?? false;
    final overlayGranted = prefs.getBool(_overlayPermissionGrantedKey) ?? false;
    final overlayPermanentlyDisabled =
        prefs.getBool('overlay_permission_permanently_disabled') ?? false;

    // if all permissions granted or user has made decisions
    if (locationPermissionGranted) {
      //for android
      if (Platform.isAndroid &&
          bgPermissionGranted &&
          (overlayPermissionGranted ||
              overlaySkipped ||
              overlayGranted ||
              overlayPermanentlyDisabled)) {
        loadHomepage();
      } else {
        loadHomepage();
      }
    }
  }

  Future<List<Widget>> permissionPages() async {
    List<Widget> pages = [];

    //location permission
    pages.add(RequestLocationPermissionView(this));
    //bg location permission
    // if (Platform.isAndroid) {
    //   pages.add(RequestBGLocationPermissionView(this));
    // }

    if (Platform.isAndroid) {
      pages.add(RequestBGPermissionView(this));
    }

    //overlay permission - only show if user hasn't made a decision
    if (Platform.isAndroid) {
      final prefs = await SharedPreferences.getInstance();
      final overlaySkipped =
          prefs.getBool(_overlayPermissionSkippedKey) ?? false;
      final overlayGranted =
          prefs.getBool(_overlayPermissionGrantedKey) ?? false;
      final overlayPermanentlyDisabled =
          prefs.getBool('overlay_permission_permanently_disabled') ?? false;
      final overlayServiceGranted =
          await OverlayService.isOverlayPermissionGranted();

      // Only show overlay permission page if:
      // 1. User hasn't skipped it
      // 2. User hasn't granted it
      // 3. User hasn't permanently disabled it
      // 4. Overlay service hasn't already granted it
      if (!overlaySkipped &&
          !overlayGranted &&
          !overlayPermanentlyDisabled &&
          !overlayServiceGranted) {
        pages.add(RequestOverlayPermissionView(this));
      }
    }

    return pages;
  }

  onPageChanged(int index) {
    currentStep = index;
    notifyListeners();
  }

  //
  Future<bool> isLocationPermissionGranted() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  // Future<bool> isBgLocationPermissionGranted() async {
  //   var status = await Permission.locationAlways.status;
  //   return status.isGranted;
  // }

  Future<bool> isBgPermissionGranted() async {
    return Platform.isAndroid && await FlutterBackground.hasPermissions;
  }

  //PERMISSION HANDLERS
  handleLocationPermission() async {
    // First request locationWhenInUse permission
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      nextStep();
      notifyListeners();
    } else if (status.isPermanentlyDenied) {
      // If permanently denied, still proceed but show a warning
      toastError(
        "Location permission is permanently denied. Some features may not work properly."
            .tr(),
      );
      nextStep();
      notifyListeners();
    } else {
      toastError(
        "Location permission is required for the app to work properly.".tr(),
      );
      // Still proceed to next step to avoid blocking the user
      nextStep();
      notifyListeners();
    }
  }

  handleBackgroundLocationPermission() async {
    bool granted = await Permission.locationAlways.isGranted;
    if (granted) {
      toastSuccessful("Permission Already Granted".tr());
      nextStep();
      notifyListeners();
      return;
    }

    //
    PermissionStatus status = await Permission.locationAlways.request();
    if (status.isGranted) {
      nextStep();
      notifyListeners();
    } else {
      toastError("Permission denied".tr());
    }

    if (status.isPermanentlyDenied) {
      nextStep();
      notifyListeners();
      return;
    }
  }

  handleOverlayPermission() async {
    // Use our improved overlay service
    final overlayService = OverlayService();
    await overlayService.showFloatingBubble();

    // Check if permission was granted
    bool isGranted = await OverlayService.isOverlayPermissionGranted();

    if (isGranted) {
      // Save that user granted the permission
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_overlayPermissionGrantedKey, true);
      await nextStep();
    } else {
      // Save that user denied the permission
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_overlayPermissionSkippedKey, true);
      toastError("Permission denied".tr());
      await nextStep();
    }
  }

  // Method to handle skipping overlay permission
  Future<void> skipOverlayPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overlayPermissionSkippedKey, true);
    await nextStep();
  }

  // Method to permanently disable overlay permission requests
  Future<void> permanentlyDisableOverlayPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overlayPermissionSkippedKey, true);
    await prefs.setBool('overlay_permission_permanently_disabled', true);
    await nextStep();
  }

  bool bgPermissinGranted = false;
  handleBackgroundPermission() async {
    if (Platform.isAndroid) {
      //
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Background service".tr(),
        notificationText: "Background notification to keep app running".tr(),
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(
          name: 'notification_icon',
          defType: 'drawable',
        ), // Default is ic_launcher from folder mipmap
      );

      //check for permission
      //CALL THE PERMISSION HANDLER
      await FlutterBackground.initialize(androidConfig: androidConfig);
      bool isGranted = await FlutterBackground.hasPermissions;
      if (isGranted) {
        await FlutterBackground.initialize(androidConfig: androidConfig);
        await FlutterBackground.enableBackgroundExecution();
      }
      nextStep();
    }
    nextStep();
  }

  //
  Future<void> nextStep() async {
    final pages = await permissionPages();
    if ((currentStep + 1) >= pages.length) {
      loadHomepage();
    } else {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }

    notifyListeners();
  }

  loadHomepage() async {
    await AuthServices().initData();
    viewContext.nextAndRemoveUntilPage(HomePage());
  }
}
