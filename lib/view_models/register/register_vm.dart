import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/firebase_token.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/utils/utils.dart';
import 'package:fuodz/views/pages/auth/register/pin_page.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../constants/app_strings.dart';
import '../../services/local_storage.service.dart';

class RegisterViewModel extends MyBaseViewModel {
  //
  AuthRequest authRequest = AuthRequest();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController phoneTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  String dobTxt = 'Date of Birth'.tr();
  String? accountPhoneNumber;
  String? firebaseVerificationId;
  Country? selectedCountry;
  String? otpCode;
  bool agreed = false;
  int userType = 1;

  bool isLoading = false;

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    // Initialize selected country
    try {
      String countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
    } catch (error) {
      this.selectedCountry = Country.parse("us");
    }
    notifyListeners();
  }

  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: (value) => countryCodeSelected(value),
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  processRegister() async {
    if (!validate()) return;
    isLoading = true;
    notifyListeners();
    try {
      String fcmToken = await FirebaseTokenService.instance.getDeviceToken() ?? "";
      print("FCM Token: $fcmToken");

      Map<String, dynamic> data = {};
      data["phone"] = phoneTEC.text;
      data["country_code"] = selectedCountry?.countryCode ?? "";
      data["email"] = emailTEC.text;
      data["name"] = nameTEC.text;
      data["password"] = passwordTEC.text;
      data["dob"] = dobTxt;
      data["fcm_token"] = fcmToken;


      final apiResponse = await authRequest.newRegisterRequest(vals: data);

      if (apiResponse.allGood) {
        isLoading = false;
        notifyListeners();
        if (apiResponse.body['status'] && apiResponse.body['code'] == 200) {
          print('Test Message: ${apiResponse.body['message']}');
          print('Test Token: ${apiResponse.body['temp_token']}');
          await AuthServices.setAuthBearerToken(apiResponse.body["temp_token"]);

          await LocalStorageService.prefs!.setBool(AppStrings.driverWaiting, true);
          await LocalStorageService.prefs!.setInt(AppStrings.registerStage, 1);
          await LocalStorageService.prefs!.setString(
            AppStrings.driverName,
            nameTEC.text,
          );
          await LocalStorageService.prefs!.setString(
            AppStrings.driverPhone,
            phoneTEC.text,
          );
          await LocalStorageService.prefs!.setString(
            AppStrings.driverPhoneCode,
            selectedCountry?.phoneCode ?? "",
          );
          await LocalStorageService.prefs!.setString(
            AppStrings.driverCountryCode,
            selectedCountry?.countryCode ?? "",
          );

          showSnackBar(
              apiResponse.message ?? "Account created successfully".tr());
          Navigator.of(viewContext).push(
            MaterialPageRoute(
              builder:
                  (context) =>
                  PinPage(
                    name: nameTEC.text,
                    countryCode: selectedCountry?.countryCode ?? "",
                    phoneCode: selectedCountry?.phoneCode ?? "",
                    phone: phoneTEC.text,
                  ),
            ),
          );
        } else {
          toastError(apiResponse.message ?? "Creating account failed".tr());
        }
      } else {
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? "Creating account failed".tr());
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showSnackBar(e.toString());
    }
  }

  bool validate() {
    if (nameTEC.text.isEmpty) {
      showSnackBar("Please enter your name".tr());
      return false;
    }
    if (emailTEC.text.isEmpty) {
      showSnackBar("Please enter your email".tr());
      return false;
    }
    if (phoneTEC.text.isEmpty) {
      showSnackBar("Please enter your phone number".tr());
      return false;
    }
    if (passwordTEC.text.isEmpty) {
      showSnackBar("Please enter your password".tr());
      return false;
    }
    if (dobTxt == 'Date of Birth'.tr()) {
      showSnackBar("Please select your date of birth".tr());
      return false;
    }
    if (!agreed) {
      showSnackBar("Please agree to the terms and conditions".tr());
      return false;
    }
    return true;
  }

  void showSnackBar(String s) {
    ScaffoldMessenger.of(viewContext).showSnackBar(
      SnackBar(
        content: Text(s, style: Theme
            .of(viewContext)
            .textTheme
            .bodyMedium!.copyWith(color: Colors.white)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void showMyDatePicker() {
    showDatePicker(
      context: viewContext,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        dobTxt = DateFormat('yyyy-MM-dd').format(value);
        notifyListeners();
      }
    });
  }

}
