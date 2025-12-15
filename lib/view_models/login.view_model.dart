import 'package:country_picker/country_picker.dart';
// Removed Firebase Auth import
import 'package:flutter/material.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/firebase_token.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/register/agreement_page.dart';
import 'package:fuodz/views/pages/permission/permission.page.dart';
import 'package:fuodz/services/zego_video_call.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../views/pages/auth/register/register.page.dart';

class LoginViewModel extends MyBaseViewModel {
  //
  AuthRequest authRequest = AuthRequest();
  TextEditingController phoneTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  TextEditingController emailTEC = TextEditingController();
  Country? selectedCountry;
  String? accountPhoneNumber;
  String? firebaseVerificationId;
  String? otpCode;

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
  }

  showCountryDialPicker() {
    // Show country picker
    toastError("Country picker disabled".tr());
  }

  processLogin() async {
    setBusy(true);
    try {
      final apiResponse = await authRequest.loginRequest(
        email: emailTEC.text,
        password: passwordTEC.text,
      );

      if (apiResponse.allGood) {
        await AuthServices.saveUser(apiResponse.body["user"]);
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated(); // Set authentication flag

        // Sync FCM token with server after successful login
        try {
          final token = await FirebaseTokenService.instance.getDeviceToken();
          if (token != null) {
            await FirebaseTokenService.instance.syncDeviceTokenWithServer(
              token
            );
          }
        } catch (e) {
          print("Error syncing FCM token after login: $e");
        }

        // Initialize ZegoCloud with actual driver ID and name after successful login
        try {
          final user = User.fromJson(apiResponse.body["user"]);
          await ZegoVideoCallService.updateDriverInfo(
            user.id.toString(),
            user.name ?? 'Driver Account',
          );
          print('ZegoCloud initialized with driver ID: ${user.id}');
        } catch (e) {
          print('Error initializing ZegoCloud after login: $e');
        }

        viewContext.nextAndRemoveUntilPage(PermissionPage());
      } else {
        toastError(apiResponse.message ?? "Login failed");
      }
    } catch (error) {
      toastError("$error");
    }
    setBusy(false);
  }

  // Firebase disabled methods
  processFirebaseOTPVerification() async {
    setBusy(true);
    toastError("Firebase OTP verification disabled".tr());
    setBusy(false);
  }

  verifyFirebaseOTP(String smsCode) async {
    setBusy(true);
    toastError("Firebase OTP verification disabled".tr());
    setBusy(false);
  }

  finishOTPLogin(dynamic authCredential) async {
    setBusy(true);
    toastError("Firebase OTP login disabled".tr());
    setBusy(false);
  }

  otpLogin() async {
    setBusy(true);
    toastError("OTP login disabled".tr());
    setBusy(false);
  }

  // Additional missing methods
  openRegistrationlink() {
    // toastError("Registration disabled".tr());
    Navigator.of(
      viewContext,
    ).push(MaterialPageRoute(builder: (ctx) => RegisterPage()));
  }

  openForgotPassword() {
    toastError("Forgot password disabled".tr());
  }

  processOTPLogin() async {
    setBusy(true);
    toastError("OTP login disabled".tr());
    setBusy(false);
  }

  initateQrcodeLogin() {
    toastError("QR code login disabled".tr());
  }
}
