import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/register/docs_page.dart';
import 'package:fuodz/views/pages/auth/register/earn_page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class EarnViewModel extends MyBaseViewModel {
  //
  AuthRequest authRequest = AuthRequest();
  TextEditingController cityTEC = TextEditingController();
  TextEditingController referralCodeTEC = TextEditingController();
  bool isLoading = false;

  EarnViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() {}

  continueToEarn(String name) async {
    if (!validate()) return;
    isLoading = true;
    notifyListeners();

    Map<String, dynamic> body = {
      "city": cityTEC.text,
      "referral_code": referralCodeTEC.text,
    };

    try {
      final apiResponse = await authRequest.continueToEarn(body);
      print('Test Hady apiResponse: $apiResponse');
      if (apiResponse.allGood) {
        isLoading = false;
        notifyListeners();
        if (apiResponse.body['success'] && apiResponse.body['code'] == 200) {
          showSnackBar(
            viewContext,
            apiResponse.message ?? "Verification successful".tr(),
          );
          Navigator.of(viewContext).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DocsPage(name: name, city: cityTEC.text),
            ),
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

  bool validate() {
    if (cityTEC.text.isEmpty) {
      showSnackBar(viewContext, "Please enter where you want to earn".tr());
      return false;
    }
    return true;
  }

  void showSnackBar(BuildContext viewContext, String s) {
    ScaffoldMessenger.of(viewContext).showSnackBar(
      SnackBar(
        content: Text(
          s,
          style: Theme.of(
            viewContext,
          ).textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
