import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:image_picker/image_picker.dart';

class DocsVM extends MyBaseViewModel {

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

  bool canNext = false;

  DocsVM(BuildContext context) {
    this.viewContext = context;
  }

  int getProgressValue(){
    int value = 0;
    if(driversLicense.isNotEmpty){
      value++;
    }
    if(vehicleRegistration.isNotEmpty){
      value++;
    }
    if(insuranceDoc.isNotEmpty){
      value++;
    }
    if(selfiePhoto.isNotEmpty){
      value++;
    }
    if(criminalRecords.isNotEmpty){
      value++;
    }
    canNext = value > 4;
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

  void _onFileSelected(String path, String name, int type){
    if(type == 1){
      driversLicense = path;
      driversLicenseName = name;
    }else if(type == 2){
      vehicleRegistration = path;
      vehicleRegistrationName = name;
    }else if(type == 3){
      insuranceDoc = path;
      insuranceDocName = name;
    }else if(type == 4){
      selfiePhoto = path;
      selfiePhotoName = name;
    }else if(type == 5){
      criminalRecords = path;
      criminalRecordsName = name;
    }else if(type == 6){
      vehicleCheck = path;
      vehicleCheckName = name;
    }
    notifyListeners();
  }

}