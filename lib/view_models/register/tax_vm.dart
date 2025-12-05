import 'package:flutter/material.dart';
import 'package:fuodz/view_models/base.view_model.dart';

class TaxVM extends MyBaseViewModel {
  TaxVM(BuildContext context) {
    this.viewContext = context;
  }

  TextEditingController nameTEC = TextEditingController();
  TextEditingController businessTEC = TextEditingController();
  TextEditingController ssnTEC = TextEditingController();
  TextEditingController addressTEC = TextEditingController();
  TextEditingController signatureTEC = TextEditingController();

  bool certify = false;

  void changCertify(bool val) {
    certify = val;
    notifyListeners();
  }
}
