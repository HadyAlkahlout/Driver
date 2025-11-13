import 'dart:io';
import 'package:flutter_background/flutter_background.dart';
import 'package:fuodz/services/background_order.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/order_manager.service.dart';

import 'package:localize_and_translate/localize_and_translate.dart';

import 'app_permission_handler.service.dart';

class AppbackgroundService {
  //

  startBg() async {
    final permitted =
        await AppPermissionHandlerService().handleLocationRequest();
    if (!permitted) {
      return;
    }

    // Use the safer location listener that doesn't throw exceptions
    final locationReady =
        await LocationService().prepareLocationListenerSafely();
    if (!locationReady) {
      print(
        "Failed to prepare location listener, but continuing with background service",
      );
    }

    await OrderManagerService().startListener();
    BackgroundOrderService();

    //
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
      final allowed =
          await AppPermissionHandlerService().handleBackgroundRequest();
      //
      if (allowed) {
        await FlutterBackground.initialize(androidConfig: androidConfig);
        await FlutterBackground.enableBackgroundExecution();
      }
    }
  }

  void stopBg() {
    // Platform.isAndroid
    if (Platform.isAndroid) {
      bool enabled = FlutterBackground.isBackgroundExecutionEnabled;
      if (enabled) {
        FlutterBackground.disableBackgroundExecution();
      }
    }
    OrderManagerService().stopListener();
  }
}
