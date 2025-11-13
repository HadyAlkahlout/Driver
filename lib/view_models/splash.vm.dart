import 'dart:convert';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
// Removed Firebase Messaging import
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/constants/app_theme.dart';
import 'package:fuodz/requests/settings.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/custom_video_call.service.dart';

import 'package:fuodz/services/websocket.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/permission/permission.page.dart';
import 'package:fuodz/widgets/cards/language_selector.view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashViewModel extends MyBaseViewModel {
  SplashViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  SettingsRequest settingsRequest = SettingsRequest();

  //
  initialise() async {
    super.initialise();
    await loadAppSettings();
  }

  //

  //
  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();

      //START: WEBSOCKET SETTINGS
      if (appSettingsObject.body["websocket"] != null) {
        await WebsocketService().saveWebsocketDetails(
          appSettingsObject.body["websocket"],
        );
      }
      //END: WEBSOCKET SETTINGS

      //
      Map<String, dynamic> appGenSettings = appSettingsObject.body["strings"];
      //set the app name ffrom package to the app settings
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      appGenSettings["app_name"] = appName;
      //app settings
      await updateAppVariables(appGenSettings);
      //colors
      await updateAppTheme(appSettingsObject.body["colors"]);
      loadNextPage();
    } catch (error) {
      setError(error);
      print("Error loading app settings ==> $error");
    }
    setBusy(false);
  }

  //
  updateAppVariables(dynamic json) async {
    //
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    //
    await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
    //change theme
    // await AdaptiveTheme.of(viewContext).reset();
    AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    await AdaptiveTheme.of(viewContext).persist();
  }

  //
  loadNextPage() async {
    //
    await Utils.setJiffyLocale();
    //
    if (AuthServices.firstTimeOnApp()) {
      //choose language
      await Navigator.of(
        viewContext,
      ).push(MaterialPageRoute(builder: (ctx) => AppLanguageSelector()));
    }

    //
    if (AuthServices.firstTimeOnApp()) {
      Navigator.of(
        viewContext,
      ).pushNamedAndRemoveUntil(AppRoutes.welcomeRoute, (route) => false);
    } else if (!AuthServices.authenticated()) {
      Navigator.of(
        viewContext,
      ).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
    } else {
      await AuthServices().initData();

      // Initialize CustomVideoCall service now that user is authenticated and UI is ready
      try {
        await CustomVideoCallService.initialize();
        print(
          'Driver Custom Video Call service initialized successfully after auth',
        );
      } catch (e) {
        print(
          'Error initializing Driver Custom Video Call service after auth: $e',
        );
      }

      var inUseStatus = await Permission.locationWhenInUse.status;
      var alwaysUseStatus = await Permission.locationAlways.status;
      final bgPermissinGranted =
          Platform.isIOS ? true : await FlutterBackground.hasPermissions;

      // Check if user has already made decisions about overlay permission
      bool overlayPermissionHandled = false;
      if (Platform.isAndroid) {
        final prefs = await SharedPreferences.getInstance();
        final overlaySkipped =
            prefs.getBool('overlay_permission_skipped') ?? false;
        final overlayGranted =
            prefs.getBool('overlay_permission_granted') ?? false;
        final overlayPermanentlyDisabled =
            prefs.getBool('overlay_permission_permanently_disabled') ?? false;
        overlayPermissionHandled =
            overlaySkipped || overlayGranted || overlayPermanentlyDisabled;
      }

      if (bgPermissinGranted &&
          inUseStatus.isGranted &&
          alwaysUseStatus.isGranted &&
          (Platform.isIOS || overlayPermissionHandled)) {
        Navigator.of(
          viewContext,
        ).pushNamedAndRemoveUntil(AppRoutes.homeRoute, (route) => false);
      } else {
        viewContext.nextAndRemoveUntilPage(PermissionPage());
      }
    }

    // Firebase initial message handling disabled
    print("Firebase initial message handling disabled");
  }
}
