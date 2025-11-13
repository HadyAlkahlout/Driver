import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/widgets/bottomsheets/background_permission.bottomsheet.dart';
import 'package:fuodz/widgets/bottomsheets/regular_location_permission.bottomsheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandlerService {
  //MANAGE BACKGROUND SERVICE PERMISSION
  Future<bool> handleBackgroundRequest() async {
    //check for permission
    bool hasPermissions = await FlutterBackground.hasPermissions;
    if (!hasPermissions) {
      //background app service permission
      final result = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return BackgroundPermissionDialog();
        },
      );
      //
      if (result != null && (result is bool) && result) {
        hasPermissions = result;
      }
    }

    return hasPermissions;
  }

  //MANAGE LOCATION PERMISSION
  Future<bool> isLocationGranted() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  // Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permission with better error handling
  Future<bool> requestLocationPermissionSafely() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        return false;
      }

      var status = await Permission.locationWhenInUse.status;

      // If already granted, return true
      if (status.isGranted) {
        return true;
      }

      // If denied but not permanently, request permission
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
        return status.isGranted;
      }

      // If permanently denied, return false
      return false;
    } catch (error) {
      print("Error requesting location permission: $error");
      return false;
    }
  }

  Future<bool> handleLocationRequest() async {
    var status = await Permission.locationWhenInUse.status;
    //check if location permission is not granted
    if (!status.isGranted) {
      final requestResult = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return RegularLocationPermissionDialog();
        },
      );
      //check if dialog was accepted or not
      if (requestResult == null || (requestResult is bool && !requestResult)) {
        return false;
      }

      //
      PermissionStatus status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        //   //
        //   final requestResult = await showDialog(
        //     barrierDismissible: false,
        //     context: AppService().navigatorKey.currentContext!,
        //     builder: (context) {
        //       return BackgroundLocationPermissionDialog();
        //     },
        //   );
        //   //check if dialog was accepted or not
        //   if (requestResult == null ||
        //       (requestResult is bool && !requestResult)) {
        //     return false;
        //   }

        //   //request for alway in use location
        //   status = await Permission.locationAlways.request();
        //   if (!status.isGranted) {
        //     permissionDeniedAlert();
        //   }
        // } else {
        permissionDeniedAlert();
      }

      if (status.isPermanentlyDenied && Platform.isAndroid) {
        //When the user previously rejected the permission and select never ask again
        //Open the screen of settings
        await openAppSettings();
      }
    }
    return true;
  }

  //
  void permissionDeniedAlert() async {
    //The user deny the permission
    await AlertController.show(
      "Permission".tr(),
      "Permission denied".tr(),
      TypeAlert.warning,
    );
  }

  // Show a user-friendly message when location is not available
  void showLocationUnavailableMessage() async {
    await AlertController.show(
      "Location Unavailable".tr(),
      "Location permission is required for this feature. Please enable location permission in your device settings."
          .tr(),
      TypeAlert.warning,
    );
  }

  // Check if we should show location permission request
  Future<bool> shouldRequestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isDenied && !status.isPermanentlyDenied;
  }
}
