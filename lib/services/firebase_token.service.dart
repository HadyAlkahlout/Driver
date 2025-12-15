import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/local_storage.service.dart';

class FirebaseTokenService {
  static const String DEVICE_TOKEN_STORE_KEY = "device_token";

  //
  static FirebaseTokenService? _instance;
  static FirebaseTokenService get instance {
    _instance ??= FirebaseTokenService._();
    return _instance!;
  }

  FirebaseTokenService._();

  //
  Future<String?> getDeviceToken() async {
    try {
      final firebaseMessaging = FirebaseMessaging.instance;
      final deviceToken = await firebaseMessaging.getToken();
      return deviceToken;
    } catch (error) {
      log("Error getting device token: $error");
      return null;
    }
  }

  syncDeviceTokenWithServer(String? deviceToken) async {
    try {
      final storagePref = await LocalStorageService.getPrefs();
      //check if saved token is same as current token
      String? savedToken = storagePref.getString(DEVICE_TOKEN_STORE_KEY);
      //if token is not saved or is different from current token
      if (savedToken == deviceToken) {
        return;
      }
      //save token
      await storagePref.setString(DEVICE_TOKEN_STORE_KEY, deviceToken!);
      //send token to server if the auth is logged in
      if (AuthServices.authenticated()) {
        await AuthRequest().updateDeviceToken(deviceToken);
      }
    } catch (error) {
      log("Error syncing device token with server: $error");
    }
  }

  //
  Future<void> setUpFirebaseMessaging() async {
    try {
      final deviceToken = await getDeviceToken();
      if (deviceToken != null) {
        print("FCM Token: $deviceToken");
        await syncDeviceTokenWithServer(deviceToken);
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("FCM Token refreshed: $newToken");
        syncDeviceTokenWithServer(newToken);
      });
    } catch (error) {
      log("Error setting up Firebase messaging: $error");
    }
  }
}
