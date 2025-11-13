import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AssignedOrdersViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  RefreshController refreshController = RefreshController();
  StreamSubscription? refreshOrderStream;
  StreamSubscription? addOrderToListStream;

  AssignedOrdersViewModel(BuildContext context) {
    this.viewContext = context;
    print(
      'DEBUG: AssignedOrdersViewModel constructor - viewContext set: ${viewContext != null}',
    );
  }

  void initialise() async {
    //
    refreshOrderStream = AppService().refreshAssignedOrders.listen((refresh) {
      if (refresh) {
        fetchOrders();
      }
    });
    //add order to list of already shown assigned orders
    addOrderToListStream = AppService().addToAssignedOrders.listen((order) {
      orders.insert(0, order);
    });

    //
    await fetchOrders();
  }

  dispose() {
    super.dispose();

    refreshOrderStream?.cancel();
    addOrderToListStream?.cancel();
  }

  //
  fetchOrders() async {
    orders.clear();
    refreshController.refreshCompleted();
    setBusy(true);
    try {
      orders = await orderRequest.getOrders(page: null, type: "assigned");
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  //
  openPaymentPage(Order order) async {
    launchUrlString(order.paymentLink);
  }

  //
  openOrderDetails(Order order) async {
    print('DEBUG: openOrderDetails called for order ${order.code}');
    print('DEBUG: viewContext mounted: ${viewContext.mounted}');

    if (!viewContext.mounted) {
      print('ERROR: Navigator context is not mounted!');
      return;
    }

    print('DEBUG: Navigating to order details using viewContext...');
    final result = await Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.orderDetailsRoute, arguments: order);

    //
    if (result != null && (result is Order || result is bool)) {
      fetchOrders();
    }
  }
}
