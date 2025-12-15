import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/auth/register/payment_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class TaxVM extends MyBaseViewModel {
  TaxVM(BuildContext context) {
    this.viewContext = context;
  }

  AuthRequest authRequest = AuthRequest();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController businessTEC = TextEditingController();
  TextEditingController ssnTEC = TextEditingController();
  TextEditingController addressTEC = TextEditingController();
  TextEditingController signatureTEC = TextEditingController();

  bool isFile = false;

  String taxFile = '';
  String taxFileName = '';

  bool certify = false;

  bool isLoading = false;

  void changCertify(bool val) {
    certify = val;
    notifyListeners();
  }

  void changeIsFile(bool val) {
    isFile = val;
    notifyListeners();
  }

  processTaxInfo(String name) async {
    if (!validate()) return;
    isLoading = true;
    notifyListeners();
    try {
      var apiResponse;
      if (isFile) {
        apiResponse = await authRequest.uploadTaxDoc(taxFile, taxFileName);
      } else {
        Map<String, dynamic> data = {};
        data["full_name"] = nameTEC.text;
        data["business_name"] = businessTEC.text;
        data["ssn"] = ssnTEC.text;
        data["address"] = addressTEC.text;

        apiResponse = await authRequest.sendTaxInfo(data);
      }

      if (apiResponse.allGood) {
        isLoading = false;
        notifyListeners();
        if (apiResponse.body['status'] && apiResponse.body['code'] == 200) {
          showSnackBar(apiResponse.message ?? "Success");
          print(apiResponse.body['url']);
          await LocalStorageService.prefs!.setInt(AppStrings.registerStage, 4);
          Navigator.of(viewContext).push(
            MaterialPageRoute(
              builder:
                  (context) => PaymentPage(
                    name: name,
                    paymentLink: apiResponse.body['url'],
                  ),
            ),
          );
        } else {
          toastError(apiResponse.message ?? 'Something went wrong'.tr());
        }
      } else {
        isLoading = false;
        notifyListeners();
        toastError(apiResponse.message ?? "Something went wrong".tr());
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showSnackBar(e.toString());
    }
  }

  bool validate() {
    if (!isFile) {
      if (nameTEC.text.isEmpty) {
        showSnackBar("Please enter your full name".tr());
        return false;
      }
      if (businessTEC.text.isEmpty) {
        showSnackBar("Please enter your business name".tr());
        return false;
      }
      if (ssnTEC.text.isEmpty) {
        showSnackBar("Please enter your SSN or ID".tr());
        return false;
      }
      if (addressTEC.text.isEmpty) {
        showSnackBar("Please enter your address".tr());
        return false;
      }
    } else {
      if (taxFile.isEmpty) {
        showSnackBar("Please select your tax file".tr());
        return false;
      }
    }
    return true;
  }

  void showSnackBar(String s) {
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

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String path = result.files.single.path!;
      String fileName = result.files.single.name;
      _onFileSelected(path, fileName);
      print("Picked file: $path");
    }
  }

  final ImagePicker _picker = ImagePicker();

  void pickImageFromGallery() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    String fileName = image!.name;
    _onFileSelected(image.path, fileName);
    print("Picked image from gallery: ${image.path}");
  }

  void pickImageFromCamera() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    String fileName = image!.name;
    _onFileSelected(image.path, fileName);
    print("Captured image from camera: ${image.path}");
  }

  void _onFileSelected(String path, String name) {
    taxFile = path;
    taxFileName = name;
    notifyListeners();
  }
}
