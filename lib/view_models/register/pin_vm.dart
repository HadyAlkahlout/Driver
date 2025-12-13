import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/register/earn_page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../services/auth.service.dart';

class PinViewModel extends MyBaseViewModel {
  //
  AuthRequest authRequest = AuthRequest();
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  int _remainingSeconds = 30; // countdown time in seconds
  Timer? _timer;
  bool canResend = false;
  bool isLoading = false;

  PinViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    canResend = false;
    _remainingSeconds = 30;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    canResend = false; // cancel previous timer if any
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        canResend = true;
        notifyListeners();
      } else {
        _remainingSeconds--;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  String get remainingTime {
    return _formatTime(_remainingSeconds);
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  verifyPin(
    String name,
    String countryCode,
    String phoneCode,
    String phone,
  ) async {
    if (!validate()) return;
    isLoading = true;
    notifyListeners();
    try {
      final apiResponse = await authRequest.verifyOTP(
        phone,
        pinController.text,
      );
      print('Test Hady apiResponse: $apiResponse');
      if (apiResponse.allGood) {
        isLoading = false;
        notifyListeners();
        if (apiResponse.body['success'] && apiResponse.body['code'] == 200) {
          // print('Test Token: ${apiResponse.body['token']}');
          // await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
          await LocalStorageService.prefs!.setInt(AppStrings.registerStage, 2);
          showSnackBar(viewContext, apiResponse.message ?? "Verification successful".tr());
          Navigator.of(viewContext).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => EarnPage(name: name)),
                (route) => false,
          );
        } else {
          toastError(apiResponse.message ?? "Verification failed".tr());
        }
      } else {
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? "Verification failed".tr());
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showSnackBar(viewContext, e.toString());
    }
  }

  resendPin(String phone, String countryCode) async {
    isLoading = true;
    notifyListeners();
    try {
      final apiResponse = await authRequest.newSendOTP(phone, countryCode);

      if (apiResponse.allGood) {
        showSnackBar(viewContext, "OTP sent successfully".tr());
        _startTimer();
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? "Verification failed".tr());
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showSnackBar(viewContext, e.toString());
    }
  }

  bool validate() {
    if (pinController.text.isEmpty) {
      showSnackBar(viewContext, "Please enter the pin code".tr());
      return false;
    }
    return true;
  }

  void showSnackBar(BuildContext viewContext, String s) {
    ScaffoldMessenger.of(viewContext).showSnackBar(
      SnackBar(
          content: Text(s, style:
          Theme.of(viewContext).textTheme.bodyMedium!.copyWith(color: Colors.white)),
          duration: const Duration(seconds: 2),
      ),
    );
  }
}
