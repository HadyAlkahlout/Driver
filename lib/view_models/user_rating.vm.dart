import 'package:fuodz/services/alert.service.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/order.request.dart';

import 'package:fuodz/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class UserRatingViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  Order order;
  int rating = 1;
  Function onsubmitted;
  TextEditingController reviewTEC = TextEditingController();

  //
  UserRatingViewModel(BuildContext context, this.order, this.onsubmitted) {
    this.viewContext = context;
  }

  void updateRating(String value) {
    rating = double.parse(value).ceil();
  }

  submitRating() async {
    setBusy(true);
    //
    final apiResponse = await orderRequest.rateUser(
      order.id,
      order.userId,
      rating.toDouble(),
      reviewTEC.text,
    );
    setBusy(false);

    //
    AlertService.dynamic(
      type: apiResponse.allGood ? AlertType.success : AlertType.error,
      title: "Rider Rating".tr(),
      text: apiResponse.message,
      onConfirm:
          apiResponse.allGood
              ? () {
                onsubmitted();
              }
              : null,
    );
  }
}
