import 'dart:io';
// Removed firestore_chat import
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_routes.dart';
import 'package:fuodz/constants/app_strings.dart';

import 'package:fuodz/models/api_response.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/models/order.dart';
import 'package:fuodz/models/order_stop.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/services/app.service.dart';

import 'package:fuodz/services/zego_video_call.service.dart';
import 'package:fuodz/services/order_details_websocket.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/views/pages/order/widgets/photo_verification.page.dart';
import 'package:fuodz/views/pages/order/widgets/scanner_verification_dialog.dart';
import 'package:fuodz/views/pages/order/widgets/signature_verification.page.dart';
import 'package:fuodz/views/pages/order/widgets/verification_dialog.dart';
import 'package:fuodz/widgets/dialogs/collect_cash_info.dialog.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuodz/extensions/context.dart';

class OrderDetailsViewModel extends MyBaseViewModel {
  //
  Order order;
  OrderRequest orderRequest = OrderRequest();
  bool changed = false;

  //
  OrderDetailsViewModel(BuildContext context, this.order) {
    this.viewContext = context;
  }

  initialise() async {
    await fetchOrderDetails();
    //handle order update through websocket
    handleWebsocketOrderEvent();
  }

  @override
  void dispose() {
    if (AppStrings.useWebsocketAssignment) {
      OrderDetailsWebsocketService().disconnect();
    }
    super.dispose();
  }

  openPaymentPage() {
    launchUrlString(order.paymentLink);
  }

  void callVendor() {
    launchUrlString("tel:${order.vendor?.phone}");
  }

  void callCustomer() async {
    try {
      // Use ZegoCloud video calling service
      // Customer app registers with format: customer_{id}, so we need to match that
      final customerId = 'customer_${order.user.id}';
      await ZegoVideoCallService.makeVideoCall(customerId, order.user.name);
      print('Making video call to customer: $customerId');
    } catch (e) {
      print('Video call failed: $e');
      // Fallback to phone call
      launchUrlString("tel:${order.user.phone}");
    }
  }

  // Proper video call method for order details
  Future<void> makeVideoCallToCustomer(
    String customerId,
    String customerName,
  ) async {
    try {
      // Use ZegoCloud video calling service
      await ZegoVideoCallService.makeVideoCall(customerId, customerName);
      print('Making video call to customer: $customerId');
    } catch (e) {
      print('Video call failed: $e');
      rethrow; // Let the UI handle the error
    }
  }

  void callRecipient() {
    launchUrlString("tel:${order.recipientPhone}");
  }

  chatVendor() {
    print("Vendor chat disabled - Firebase chat removed");
    toastError("Chat feature disabled".tr());
  }

  chatCustomer() {
    //
    Navigator.of(viewContext).pushNamed(AppRoutes.chatRoute, arguments: order);
  }

  Future<void> fetchOrderDetails() async {
    setBusy(true);
    try {
      order = await orderRequest.getOrderDetails(id: order.id);
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      toastError("$error");
    }
    setBusy(false);
  }

  handleWebsocketOrderEvent() {
    //start websocket listening to ordr events
    if (AppStrings.useWebsocketAssignment) {
      OrderDetailsWebsocketService().connectToOrderChannel("${order.id}", (
        data,
      ) {
        fetchOrderDetails();
      });
    }
  }

  //
  void initiateOrderCompletion() async {
    if (AppStrings.enableProofOfDelivery) {
      //code verification code
      if (!AppStrings.signatureVerify && !AppStrings.verifyOrderByPhoto) {
        showModalBottomSheet(
          context: AppService().navigatorKey.currentContext!,
          isScrollControlled: true,
          builder: (context) {
            return OrderVerificationDialog(
              order: order,
              onValidated: () {
                AppService().navigatorKey.currentContext?.pop();
                processOrderCompletion();
              },
              openQRCodeScanner: () {
                AppService().navigatorKey.currentContext?.pop();
                showQRCodeScanner();
              },
            );
          },
        );
      }
      //verification via photo
      else if (AppStrings.verifyOrderByPhoto) {
        final result = await viewContext.push(
          (context) => PhotoVerificationPage(order: order),
        );
        //
        if (result is Order) {
          order = result;
          notifyListeners();
        } else if (result != null && result) {
          processOrderCompletion();
        }
      }
      //verification via signature
      else {
        final result = await viewContext.push(
          (context) => SignatureVerificationPage(order: order),
        );
        //
        if (result is Order) {
          order = result;
          notifyListeners();
        } else if (result != null && result) {
          processOrderCompletion();
        }
      }
    } else {
      processOrderCompletion();
    }
  }

  //
  showQRCodeScanner() async {
    showDialog(
      context: AppService().navigatorKey.currentContext!,
      builder: (context) {
        return Dialog(
          child: ScanOrderVerificationDialog(
            order: order,
            onValidated: () {
              // AppService().navigatorKey.currentContext.pop();
              processOrderCompletion();
            },
          ),
        );
      },
    );
  }

  void processOrderCompletion() async {
    setBusyForObject(order, true);
    try {
      order = await orderRequest.updateOrder(id: order.id, status: "delivered");
      //beaware a change as occurred
      changed = true;
      clearErrors();
      //show successful toast
      toastSuccessful("Order completed successfully".tr());
      //show a cash collection dialog if is cash order
      if (order.paymentMethod?.slug == "cash") {
        showDialog(
          barrierDismissible: false,
          context: viewContext,
          builder: (context) {
            return CollectCashInfoDialog(order);
          },
        );
      }
    } catch (error) {
      print("Error ==> $error");
      setErrorForObject(order, error);
      toastError("$error");
    }
    setBusyForObject(order, false);
  }

  //
  void processOrderEnroute() async {
    setBusyForObject(order, true);
    try {
      order = await orderRequest.updateOrder(id: order.id, status: "enroute");
      //beaware a change as occurred
      changed = true;
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setErrorForObject(order, error);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    setBusyForObject(order, false);
  }

  onBackPressed() {
    //
    AppService().navigatorKey.currentContext?.pop(changed ? order : null);
  }

  //
  routeToLocation(DeliveryAddress deliveryAddress) async {
    try {
      final coords = Coords(
        deliveryAddress.latitude!,
        deliveryAddress.longitude!,
      );
      final title = deliveryAddress.name;
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: AppService().navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap:
                            () => map.showMarker(
                              coords: coords,
                              title: title ?? "",
                            ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  //
  verifyStop(OrderStop stop) async {
    //code verification code
    if (AppStrings.verifyOrderByPhoto) {
      await viewContext.push(
        (context) => PhotoVerificationPage(
          order: order,
          onsubmit: (photo) {
            processOrderStopVerification(stop, photo);
            viewContext.pop();
          },
        ),
      );
    }
    //verification via signature
    else {
      await viewContext.push(
        (context) => SignatureVerificationPage(
          order: order,
          onsubmit: (photo) {
            processOrderStopVerification(stop, photo);
            viewContext.pop();
          },
        ),
      );
    }
  }

  void processOrderStopVerification(OrderStop stop, File photo) async {
    setBusyForObject(stop, true);
    try {
      ApiResponse apiResponse = await orderRequest.verifyOrderStopRequest(
        id: stop.id,
        signature: photo,
      );
      clearErrors();
      //
      order = Order.fromJson(apiResponse.body["order"]);
      notifyListeners();
      toastSuccessful(apiResponse.body["message"]);
    } catch (error) {
      print("Error ==> $error");
      toastError("$error");
    }
    setBusyForObject(stop, false);
  }
}
