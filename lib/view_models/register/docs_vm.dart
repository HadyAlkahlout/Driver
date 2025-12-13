import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/register/tax_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import '../../services/auth.service.dart';

class DocsVM extends MyBaseViewModel {
  //
  AuthRequest authRequest = AuthRequest();

  String driversLicense = '';
  String driversLicenseName = '';

  String vehicleRegistration = '';
  String vehicleRegistrationName = '';

  String insuranceDoc = '';
  String insuranceDocName = '';

  String selfiePhoto = '';
  String selfiePhotoName = '';

  String criminalRecords = '';
  String criminalRecordsName = '';

  String vehicleCheck = '';
  String vehicleCheckName = '';

  bool isLoading = false;

  DocsVM(BuildContext context) {
    this.viewContext = context;
  }

  int getProgressValue() {
    int value = 0;
    if (driversLicense.isNotEmpty) {
      value++;
    }
    if (vehicleRegistration.isNotEmpty) {
      value++;
    }
    if (insuranceDoc.isNotEmpty) {
      value++;
    }
    if (selfiePhoto.isNotEmpty) {
      value++;
    }
    if (criminalRecords.isNotEmpty) {
      value++;
    }
    return value;
  }

  void pickFile(int fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String path = result.files.single.path!;
      String fileName = result.files.single.name;
      _onFileSelected(path, fileName, fileType);
      print("Picked file: $path");
    }
  }

  final ImagePicker _picker = ImagePicker();

  void pickImageFromGallery(int fileType) async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    String fileName = image!.name;
    _onFileSelected(image.path, fileName, fileType);
    print("Picked image from gallery: ${image.path}");
  }

  void pickImageFromCamera(int fileType) async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    String fileName = image!.name;
    _onFileSelected(image.path, fileName, fileType);
    print("Captured image from camera: ${image.path}");
  }

  void _onFileSelected(String path, String name, int type) {
    if (type == 1) {
      driversLicense = path;
      driversLicenseName = name;
    } else if (type == 2) {
      vehicleRegistration = path;
      vehicleRegistrationName = name;
    } else if (type == 3) {
      insuranceDoc = path;
      insuranceDocName = name;
    } else if (type == 4) {
      selfiePhoto = path;
      selfiePhotoName = name;
    } else if (type == 5) {
      criminalRecords = path;
      criminalRecordsName = name;
    } else if (type == 6) {
      vehicleCheck = path;
      vehicleCheckName = name;
    }
    notifyListeners();
  }

  uploadDocs(String name) async {
    if (!validate()) return;
    isLoading = true;
    notifyListeners();

    final formData = FormData.fromMap({
      "driver_license": await MultipartFile.fromFile(
        driversLicense,
        filename: driversLicenseName,
      ),
      "vehicle_registration": await MultipartFile.fromFile(
        vehicleRegistration,
        filename: vehicleRegistrationName,
      ),
      "insurance_document": await MultipartFile.fromFile(
        insuranceDoc,
        filename: insuranceDocName,
      ),
      "selfie_photo_id": await MultipartFile.fromFile(
        selfiePhoto,
        filename: selfiePhotoName,
      ),
      if (vehicleCheck.isNotEmpty)
        "vehicle_check_report": await MultipartFile.fromFile(
          vehicleCheck,
          filename: vehicleCheckName,
        ),
    });

    try {
      String token = await AuthServices.getAuthBearerToken();
      final response = await Dio().post(
        "https://e2udelivery.com/api/partner/document",
        data: formData,
        options: Options(headers: {"Authorization": "$token"}),
      );
      final apiResponse = ApiResponse.fromResponse(response);
      print('Test Hady apiResponse: $apiResponse');
      print('Test Hady apiResponse M: ${apiResponse.message}');
      print('Test Hady apiResponse E: ${apiResponse.errors}');
      if (apiResponse.allGood) {
        isLoading = false;
        notifyListeners();
        showSnackBar(viewContext, apiResponse.message ?? 'Success');
        await LocalStorageService.prefs!.setInt(AppStrings.registerStage, 4);
        Navigator.of(viewContext).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TaxPage(name: name)),
          (route) => false,
        );
      } else {
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? 'Something went wrong'.tr());
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showSnackBar(viewContext, e.toString());
    }
  }

  bool validate() {
    if (driversLicense.isEmpty) {
      showSnackBar(viewContext, "Please select drivers license".tr());
      return false;
    }
    if (vehicleRegistration.isEmpty) {
      showSnackBar(viewContext, "Please select vehicle registration".tr());
      return false;
    }
    if (insuranceDoc.isEmpty) {
      showSnackBar(viewContext, "Please select insurance document".tr());
      return false;
    }
    if (selfiePhoto.isEmpty) {
      showSnackBar(viewContext, "Please select selfie photo".tr());
      return false;
    }
    // if (criminalRecords.isEmpty) {
    //   showSnackBar(viewContext, "Please select criminal records".tr());
    //   return false;
    // }
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
