import 'dart:async';
// Removed cloud_firestore import
import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/models/user.dart';
import 'package:fuodz/models/vehicle.dart';
import 'package:fuodz/requests/auth.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/appbackground.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:fuodz/services/order_assignment.service.dart';
import 'package:fuodz/services/order_manager.service.dart';
import 'package:fuodz/services/pending_notifications.service.dart';
import 'package:fuodz/services/update.service.dart';
import 'package:fuodz/services/custom_video_call.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:fuodz/widgets/bottomsheets/new_order_alert.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:georange/georange.dart';

class HomeViewModel extends MyBaseViewModel with UpdateService {
  //
  HomeViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  // bool isOnline = true;
  int currentIndex = 0;
  User? currentUser;
  Vehicle? driverVehicle;
  PageController pageViewController = PageController(initialPage: 0);
  StreamSubscription? homePageChangeStream;
  StreamSubscription? locationReadyStream;
  dynamic firebaseFirestore; // Removed FirebaseFirestore
  GeoRange georange = GeoRange();
  StreamSubscription? newOrderStream;
  AuthRequest authRequest = AuthRequest();

  @override
  void initialise() async {
    setBusy(true);

    try {
      //
      handleAppUpdate(viewContext);
      //
      currentUser = await AuthServices.getCurrentUser();
      driverVehicle = await AuthServices.getDriverVehicle();
      //
      AppService().driverIsOnline =
          LocalStorageService.prefs!.getBool(AppStrings.onlineOnApp) ?? false;

      //
      await OrderManagerService().monitorOnlineStatusListener();

      //
      locationReadyStream = LocationService().locationDataAvailable.stream
          .listen((event) {
            if (event) {
              print("abut call ==> listenToNewOrders");
              listenToNewOrders();
            }
          });

      //
      homePageChangeStream = AppService().homePageIndex.stream.listen((index) {
        //
        onTabChange(index);
      });

      //INCASE OF previous driver online state
      handleNewOrderServices();

      // Initialize pending notifications service
      PendingNotificationsService().startPeriodicCleanup();

      // Initialize video call service
      await _initializeVideoCallService();
    } finally {
      setBusy(false);
    }
  }

  // Initialize video call service
  Future<void> _initializeVideoCallService() async {
    try {
      if (AuthServices.authenticated()) {
        // Add a small delay to ensure the UI is fully ready
        await Future.delayed(Duration(milliseconds: 500));
        await CustomVideoCallService.initialize();
        debugPrint(
          'HomeViewModel: Driver video call service initialized successfully',
        );
      } else {
        debugPrint(
          'HomeViewModel: Driver not authenticated, skipping video call service initialization',
        );
      }
    } catch (e) {
      debugPrint(
        'HomeViewModel: Error initializing driver video call service: $e',
      );
    }
  }

  //
  dispose() {
    super.dispose();
    cancelAllListeners();
  }

  cancelAllListeners() async {
    homePageChangeStream?.cancel();
    newOrderStream?.cancel();
    // Stop pending notifications cleanup
    PendingNotificationsService().stopPeriodicCleanup();
  }

  //
  onPageChanged(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      notifyListeners();
    }
  }

  //
  onTabChange(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      pageViewController.animateToPage(
        currentIndex,
        duration: Duration(
          milliseconds: 200,
        ), // Fixed from microseconds to milliseconds
        curve:
            Curves.easeInOut, // Changed from bounceInOut for better performance
      );
      notifyListeners();
    }
  }

  bool _isTogglingStatus = false;

  void toggleOnlineStatus() async {
    // Prevent double clicks
    if (_isTogglingStatus || isBusy) {
      return;
    }

    _isTogglingStatus = true;
    setBusy(true);

    try {
      final newStatus = !AppService().driverIsOnline;
      //
      final apiResponse = await authRequest.updateOnlineStatus(
        isOnline: newStatus,
      );
      if (apiResponse.allGood) {
        //
        AppService().driverIsOnline = newStatus;
        await LocalStorageService.prefs!.setBool(
          AppStrings.onlineOnApp,
          AppService().driverIsOnline,
        );
        //
        viewContext.showToast(
          msg: "Updated Successfully".tr(),
          bgColor: Colors.green,
          textColor: Colors.white,
        );

        //
        handleNewOrderServices();
      } else {
        viewContext.showToast(
          msg: "${apiResponse.message}",
          bgColor: Colors.red,
        );
      }
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    } finally {
      setBusy(false);
      _isTogglingStatus = false;
    }
  }

  handleNewOrderServices() {
    if (AppService().driverIsOnline) {
      listenToNewOrders();
      AppbackgroundService().startBg();
    } else {
      //
      // LocationService().clearLocationFromFirebase();
      cancelAllListeners();
      AppbackgroundService().stopBg();
    }
  }

  //NEW ORDER STREAM
  listenToNewOrders() async {
    //close any previous listener
    newOrderStream?.cancel();
    //start the background service
    startNewOrderBackgroundService();
  }

  NewOrder? showingNewOrder;
  void showNewOrderAlert(NewOrder newOrder) async {
    //

    if (showingNewOrder == null || showingNewOrder!.docRef != newOrder.docRef) {
      showingNewOrder = newOrder;
      print("called showNewOrderAlert");
      final result = await showModalBottomSheet(
        context: AppService().navigatorKey.currentContext!,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return NewOrderAlertBottomSheet(newOrder);
        },
      );

      //
      if (result is bool && result) {
        AppService().refreshAssignedOrders.add(true);
      } else {
        await OrderAssignmentService.releaseOrderForotherDrivers(
          newOrder.toJson(),
          newOrder.docRef!,
        );
      }
    }
  }
}
