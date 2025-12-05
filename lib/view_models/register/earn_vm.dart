import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/register/earn_page.dart';

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
    canResend = false;// cancel previous timer if any
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
    String email,
    String name,
    String countryCode,
    String phoneCode,
    String phone,
    String password,
  ) async {
    if (!validate()) return;
    setBusy(true);
    isLoading = true;
    notifyListeners();
    try {
      final apiResponse = await authRequest.verifyOTP(
        phone,
        pinController.text,
      );
      print('Test Hady apiResponse: $apiResponse');
      print('Test Hady apiResponse data: ${apiResponse.data}');
      if (apiResponse.allGood) {
        setBusy(false);
        isLoading = false;
        notifyListeners();
        Navigator.of(viewContext).pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (context) => EarnPage(
                  email: email,
                  name: name,
                  countryCode: countryCode,
                  phoneCode: phoneCode,
                  phone: phone,
                  password: password,
                ),
          ),
          (route) => false,
        );
      } else {
        setBusy(false);
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? "Verification failed");
      }
    } catch (e) {
      setBusy(false);
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
        showSnackBar(viewContext, "OTP sent successfully");
        _startTimer();
        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? "Verification failed");
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showSnackBar(viewContext, e.toString());
    }
  }

  bool validate() {
    if (pinController.text.isEmpty) {
      showSnackBar(viewContext, "Please enter the pin code");
      return false;
    }
    return true;
  }

  void showSnackBar(BuildContext viewContext, String s) {
    ScaffoldMessenger.of(viewContext).showSnackBar(
      SnackBar(content: Text(s), duration: const Duration(seconds: 2)),
    );
  }
}
