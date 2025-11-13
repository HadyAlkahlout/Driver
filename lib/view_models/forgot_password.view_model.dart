import 'package:country_picker/country_picker.dart';
// Removed Firebase Auth import
import 'package:flutter/material.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ForgotPasswordViewModel extends MyBaseViewModel {
  //
  AuthRequest authRequest = AuthRequest();
  TextEditingController phoneTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  Country? selectedCountry;
  String? accountPhoneNumber;
  String? firebaseVerificationId;
  String? firebaseToken;

  ForgotPasswordViewModel(BuildContext context) {
    this.viewContext = context;
  }

  initialise() {
    // Initialize the view model
  }

  showCountryDialPicker() {
    // Show country picker
    toastError("Country picker disabled".tr());
  }

  processForgotPassword() async {
    setBusy(true);
    toastError("Password reset disabled - contact support".tr());
    setBusy(false);
  }

  // Firebase disabled methods
  processFirebaseForgotPassword(String phoneNumber) async {
    setBusy(true);
    toastError("Firebase password reset disabled - contact support".tr());
    setBusy(false);
  }

  showVerificationEntry() {
    // Show verification UI
  }

  showNewPasswordEntry() {
    // Show new password UI
  }

  verifyFirebaseOTP(String smsCode) async {
    setBusy(true);
    toastError("Firebase OTP verification disabled".tr());
    setBusy(false);
  }

  resetPassword() async {
    setBusy(true);
    toastError("Password reset disabled - contact support".tr());
    setBusy(false);
  }
}
