import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/register/rejected_files.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/register/tax_page.dart';
import 'package:fuodz/views/pages/auth/register/waiting_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../../services/auth.service.dart';

class DocsVM extends MyBaseViewModel {
  //
  AuthRequest authRequest = AuthRequest();

  bool isEdit = false;

  String driversLicense = '';
  bool showDriversLicense = true;
  String driversLicenseName = '';

  String vehicleRegistration = '';
  bool showVehicleRegistration = true;
  String vehicleRegistrationName = '';

  String insuranceDoc = '';
  bool showInsuranceDoc = true;
  String insuranceDocName = '';

  String selfiePhoto = '';
  bool showSelfiePhoto = true;
  String selfiePhotoName = '';

  String criminalRecords = '';
  bool showCriminalRecords = false;
  String criminalRecordsName = '';

  String vehicleCheck = '';
  bool showVehicleCheck = true;
  String vehicleCheckName = '';

  bool isLoading = false;

  DocsVM(BuildContext context, bool isEdit) {
    this.viewContext = context;
    this.isEdit = isEdit;
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
      if(showDriversLicense) "driver_license": await MultipartFile.fromFile(
        driversLicense,
        filename: driversLicenseName,
      ),
      if(showVehicleRegistration) "vehicle_registration": await MultipartFile.fromFile(
        vehicleRegistration,
        filename: vehicleRegistrationName,
      ),
      if(showInsuranceDoc) "insurance_document": await MultipartFile.fromFile(
        insuranceDoc,
        filename: insuranceDocName,
      ),
      if(showSelfiePhoto) "selfie_photo_id": await MultipartFile.fromFile(
        selfiePhoto,
        filename: selfiePhotoName,
      ),
      if (vehicleCheck.isNotEmpty)"vehicle_check_report": await MultipartFile.fromFile(
          vehicleCheck,
          filename: vehicleCheckName,
        ),
      "edit": isEdit,
    });
    print('Test Map files: ${formData.files}');
    print('Test Map fields: ${formData.fields}');
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
        if (!isEdit) {
          await LocalStorageService.prefs!.setInt(AppStrings.registerStage, 4);
        }
        Navigator.of(viewContext).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>
          isEdit ? WaitingPage(name: name) : TaxPage(name: name)),
          (route) => false,
        );
      } else {
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? 'Something went wrong'.tr());
      }
    } on DioException catch (e) {
      isLoading = false;
      notifyListeners();
      print('Test Hady error: ${e}');
      print('Test Hady error response: ${e.response}');
      print('Test Hady error response data: ${e}');
      if(e.response != null) {
        showSnackBar(viewContext, e.response!.data['message'] ?? 'Something went wrong'.tr());
      } else{
        showSnackBar(viewContext, 'Something went wrong'.tr());
      }
    }
  }

  bool validate() {
    if (driversLicense.isEmpty && showDriversLicense) {
      showSnackBar(viewContext, "Please select drivers license".tr());
      return false;
    }
    if (vehicleRegistration.isEmpty && showVehicleRegistration) {
      showSnackBar(viewContext, "Please select vehicle registration".tr());
      return false;
    }
    if (insuranceDoc.isEmpty && showInsuranceDoc) {
      showSnackBar(viewContext, "Please select insurance document".tr());
      return false;
    }
    if (selfiePhoto.isEmpty && showSelfiePhoto) {
      showSnackBar(viewContext, "Please select selfie photo".tr());
      return false;
    }
    // if (criminalRecords.isEmpty && showCriminalRecords) {
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

  void arrangeEdit(dynamic rejectedFiles){
    if(rejectedFiles != null) {
      RejectedFiles files = RejectedFiles.fromJson(rejectedFiles);
      showDriversLicense = files.driverLicense.isNotEmpty;
      showVehicleRegistration = files.vehicleRegistration.isNotEmpty;
      showInsuranceDoc = files.insuranceDocument.isNotEmpty;
      showSelfiePhoto = files.selfiePhotoId.isNotEmpty;
      showVehicleCheck = files.vehicleCheckReport.isNotEmpty;
      notifyListeners();
    }
  }
}
