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
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/requests/settings.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/custom_video_call.service.dart';
import 'package:fuodz/services/local_storage.service.dart';

import 'package:fuodz/services/websocket.service.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/auth/login.page.dart';
import 'package:fuodz/views/pages/auth/register/agreement_page.dart';
import 'package:fuodz/views/pages/auth/register/docs_page.dart';
import 'package:fuodz/views/pages/auth/register/earn_page.dart';
import 'package:fuodz/views/pages/auth/register/payment_page.dart';
import 'package:fuodz/views/pages/auth/register/pin_page.dart';
import 'package:fuodz/views/pages/auth/register/tax_page.dart';
import 'package:fuodz/views/pages/auth/register/waiting_page.dart';
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
      // Here make the driver check
      if (await LocalStorageService.prefs!.getBool(AppStrings.driverWaiting) ??
          false) {
        if ((await LocalStorageService.prefs!
            .getInt(AppStrings.registerStage) ?? 0) == 7) {
          AuthRequest authRequest = AuthRequest();
          final apiResponse = await authRequest.driverCheck();

          if (apiResponse.body['success'] && apiResponse.body['code'] == 200) {
            if (apiResponse.message != null) {
              ScaffoldMessenger.of(viewContext).showSnackBar(
                SnackBar(
                  content: Text(apiResponse.message!),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            if (apiResponse.body['data'] == 'UNDER_REVIEW') {
              Navigator.of(viewContext).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder:
                      (context) => WaitingPage(
                        name:
                            LocalStorageService.prefs!.getString(
                              AppStrings.driverName,
                            ) ??
                            'Driver',
                      ),
                ),
                (route) => false,
              );
            }
            else if(apiResponse.body['data'] == 'SOME_REJECTED'){
              Navigator.of(viewContext).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) =>
                    DocsPage(
                      name:
                      LocalStorageService.prefs!.getString(AppStrings.driverName) ??
                          'Driver',
                      city:
                      LocalStorageService.prefs!.getString(AppStrings.driverCity) ?? '',
                    )),
                    (route) => false,
              );
            }
            else {
              await LocalStorageService.prefs!.setBool(
                AppStrings.driverWaiting,
                false,
              );
              Navigator.of(
                viewContext,
              ).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
            }
          }
          else {
            Navigator.of(
              viewContext,
            ).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
          }
        } else {
          Navigator.of(viewContext).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => getRegisterStage()),
                (route) => false,
          );
        }
      }
      else {
        Navigator.of(
          viewContext,
        ).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
      }
    }
    else {
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

  Widget getRegisterStage() {
    int stage = LocalStorageService.prefs!.getInt(AppStrings.registerStage) ?? 0;
    switch (stage) {
      case 1:
        return PinPage(
          name:
              LocalStorageService.prefs!.getString(AppStrings.driverName) ??
              'Driver',
          countryCode:
              LocalStorageService.prefs!.getString(
                AppStrings.driverCountryCode,
              ) ??
              '',
          phoneCode:
              LocalStorageService.prefs!.getString(
                AppStrings.driverPhoneCode,
              ) ??
              '',
          phone:
              LocalStorageService.prefs!.getString(AppStrings.driverPhone) ??
              '',
        );
      case 2:
        return EarnPage(
          name:
              LocalStorageService.prefs!.getString(AppStrings.driverName) ??
              'Driver',
        );
      case 3:
        return DocsPage(
          name:
              LocalStorageService.prefs!.getString(AppStrings.driverName) ??
              'Driver',
          city:
              LocalStorageService.prefs!.getString(AppStrings.driverCity) ?? '',
        );
      case 4:
        return TaxPage(
          name:
              LocalStorageService.prefs!.getString(AppStrings.driverName) ??
              'Driver',
        );
      case 5:
        return PaymentPage(
          name:
              LocalStorageService.prefs!.getString(AppStrings.driverName) ??
              'Driver',
          paymentLink:
              LocalStorageService.prefs!.getString(AppStrings.paymentLink) ??
              '',
        );
      case 6:
        return AgreementPage(
          name:
              LocalStorageService.prefs!.getString(AppStrings.driverName) ??
              'Driver',
        );
      case 7:
        return WaitingPage(
          name:
              LocalStorageService.prefs!.getString(AppStrings.driverName) ??
              'Driver',
        );
      default:
        return LoginPage();
    }
  }
}
