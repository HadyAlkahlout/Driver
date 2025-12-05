import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/services/firebase_token.service.dart';
import 'package:fuodz/services/http.service.dart';

class AuthRequest extends HttpService {
  //
  Future<ApiResponse> loginRequest({
    required String email,
    required String password,
  }) async {
    final apiResult = await post(Api.login, {
      "email": email,
      "password": password,
      "role": "driver",
      "tokens": await FirebaseTokenService.instance.getDeviceToken(),
    });

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> newRegisterRequest({
    required Map<String, dynamic> vals,
  }) async {
    final apiResult = await post(Api.newAccount, vals);
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> verifyPinRequest({
    required Map<String, dynamic> vals,
  }) async {
    final apiResult = await post(Api.newAccount, vals);
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> registerRequest({
    required Map<String, dynamic> vals,
    List<File>? docs,
  }) async {
    final postBody = {...vals};

    FormData formData = FormData.fromMap(postBody);
    if ((docs ?? []).isNotEmpty) {
      for (File file in docs!) {
        formData.files.addAll([
          MapEntry("documents[]", await MultipartFile.fromFile(file.path)),
        ]);
      }
    }

    final apiResult = await postCustomFiles(
      Api.newAccount,
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> verifyFirebaseToken(
    String phoneNumber,
    String firebaseVerificationId,
  ) async {
    //
    final apiResult = await post(Api.verifyFirebaseOtp, {
      "phone": phoneNumber,
      "firebase_id_token": firebaseVerificationId,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  //
  Future<ApiResponse> qrLoginRequest({required String code}) async {
    final apiResult = await post(Api.qrlogin, {"code": code, "role": "driver"});

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> resetPasswordRequest({
    required String phone,
    required String password,
    String? firebaseToken,
    String? customToken,
  }) async {
    final apiResult = await post(Api.forgotPassword, {
      "phone": phone,
      "password": password,
      "firebase_id_token": firebaseToken,
      "verification_token": customToken,
    });

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> logoutRequest() async {
    final apiResult = await get(Api.logout);
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> updateOnlineStatus({required bool isOnline}) async {
    final apiResult = await post(Api.updateProfile, {
      "_method": "PUT",
      "is_online": isOnline ? 1 : 0,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateProfile({
    File? photo,
    String? name,
    String? email,
    String? phone,
  }) async {
    final apiResult = await postWithFiles(Api.updateProfile, {
      "_method": "PUT",
      "name": name,
      "email": email,
      "phone": phone,

      "photo": photo != null ? await MultipartFile.fromFile(photo.path) : null,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updatePassword({
    required String password,
    required String new_password,
    required String new_password_confirmation,
  }) async {
    final apiResult = await post(Api.updatePassword, {
      "_method": "PUT",
      "password": password,
      "new_password": new_password,
      "new_password_confirmation": new_password_confirmation,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> verifyPhoneAccount(String phone) async {
    final apiResult = await get(
      Api.verifyPhoneAccount,
      queryParameters: {"phone": phone},
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> sendOTP(
    String phoneNumber, {
    bool isLogin = true,
  }) async {
    final apiResult = await post(Api.sendOtp, {
      "phone": phoneNumber,
      "is_login": isLogin,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> newSendOTP(
    String phoneNumber,
    String countryCode, {
    String isLogin = 'yes',
  }) async {
    final apiResult = await post(Api.sendOtp, {
      "phone": phoneNumber,
      "country_code": countryCode,
      "is_login": isLogin,
    }, includeHeaders: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> verifyOTP(
    String phoneNumber,
    String code, {
    bool isLogin = true,
  }) async {
    final apiResult = await post(Api.verifyOtp, {
      "phone": phoneNumber,
      "code": code,
      "is_login": isLogin,
    }, includeHeaders: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<User> getMyDetails() async {
    //
    final apiResult = await get(Api.myProfile);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return User.fromJson(apiResponse.body);
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> deleteProfile({
    required String password,
    String? reason,
  }) async {
    final apiResult = await post(Api.accountDelete, {
      "_method": "DELETE",
      "password": password,
      "reason": reason,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> submitDocumentsRequest({required List<File> docs}) async {
    FormData formData = FormData.fromMap({});
    for (File file in docs) {
      formData.files.addAll([
        MapEntry("documents[]", await MultipartFile.fromFile(file.path)),
      ]);
    }

    final apiResult = await postCustomFiles(
      Api.documentSubmission,
      null,
      formData: formData,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateDeviceToken(String token) async {
    late String deviceId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.manufacturer;
      deviceId += "-";
      deviceId += androidInfo.model;
      deviceId += "-";
      deviceId += androidInfo.id;
    }
    final apiResult = await post(Api.tokenSync, {
      "token": token,
      "deviceId": deviceId,
    });
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> continueToEarn(Map<String, dynamic> vals) async {
    final apiResult = await post(Api.continueToEarn, vals, includeHeaders: true, isRegister: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> uploadDriverDocs(FormData formData) async {
    final apiResult = await postCustomFiles(
      Api.driverDocs,
      null,
      formData: formData,
      includeHeaders: true,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> sendTaxInfo(Map<String, dynamic> vals) async {
    final apiResult = await post(Api.driverTax, vals, includeHeaders: true, isRegister: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> uploadTaxDoc(String path, String name) async {
    FormData formData = FormData.fromMap({
      "tax_file": await MultipartFile.fromFile(path, filename: name),
    });
    final apiResult = await postCustomFiles(
      Api.driverTax,
      null,
      formData: formData,
      includeHeaders: true,
      isRegister: true,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> driverCheck() async {
    final apiResult = await post(
      Api.driverCheck,
      null,
      includeHeaders: true,
      isRegister: true,
    );
    return ApiResponse.fromResponse(apiResult);
  }


}
