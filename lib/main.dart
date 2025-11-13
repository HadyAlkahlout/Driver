import 'dart:async';
import 'dart:io';

// Removed Firebase imports
import 'package:flutter/material.dart';
import 'package:fuodz/my_app.dart';
import 'package:fuodz/services/lifecycle_event_handler.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/firebase.service.dart';
import 'package:fuodz/services/location_watcher.service.dart';
import 'package:fuodz/services/notification.service.dart';
import 'package:fuodz/services/overlay.service.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'constants/app_languages.dart';
import 'views/overlays/floating_app_bubble.view.dart';

/// 1.1.1 define a navigator key for ZegoCloud
final navigatorKey = GlobalKey<NavigatorState>();

//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FloatingAppBubble(),
    ),
  );
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      LifecycleEventHandler().startListening();

      /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

      // Set navigator key in AppService for navigation
      AppService().setNavigatorKey(navigatorKey);

      // Initialize ZegoCloud properly with signaling plugin
      await ZegoUIKit().initLog();
      ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
        ZegoUIKitSignalingPlugin(),
      ]);

      // Initialize Firebase for notifications only
      await FirebaseService().setUpFirebaseMessaging();
      //
      await translator.init(
        localeType: LocalizationDefaultType.asDefined,
        languagesList: AppLanguages.codes,
        assetsDirectory: 'assets/lang/',
      );
      //
      await LocalStorageService.getPrefs();
      await NotificationService.clearIrrelevantNotificationChannels();
      await NotificationService.initializeAwesomeNotification();
      await NotificationService.listenToActions();
      // Firebase messaging setup removed
      LocationServiceWatcher.listenToDelayLocationUpdate();
      //
      OverlayService().closeFloatingBubble();

      //prevent ssl error
      HttpOverrides.global = new MyHttpOverrides();
      // Firebase Crashlytics removed

      // Run app!
      runApp(LocalizedApp(child: MyApp(navigatorKey: navigatorKey)));
    },
    (error, stackTrace) {
      // Firebase Crashlytics error recording removed
    },
  );
}
