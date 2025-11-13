import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/requests/order.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/firestore.service.dart';
import 'package:fuodz/view_models/base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fuodz/extensions/context.dart';

class NewOrderAlertViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  NewOrder newOrder;
  bool canDismiss = false;
  CountDownController countDownTimerController = CountDownController();
  NewOrderAlertViewModel(this.newOrder, BuildContext context) {
    this.viewContext = context;
  }

  initialise() {
    //
    AppService().playNotificationSound();
    //
    countDownTimerController.start();
    
    // Mark this order as being processed to prevent duplicate notifications
    print("DEBUG: Initializing new order alert for order ${newOrder.id}");
  }

  bool _isProcessing = false;
  
  void processOrderAcceptance() async {
    // Prevent double taps
    if (_isProcessing || isBusy) {
      print("DEBUG: Order acceptance already in progress, ignoring duplicate tap");
      return;
    }
    
    _isProcessing = true;
    countDownTimerController.pause();
    setBusy(true);
    
    print("DEBUG: Starting order acceptance for order ${newOrder.id}");
    
    try {
      // Add timeout to prevent hanging
      final result = await orderRequest.acceptNewOrder(newOrder.id!)
          .timeout(
            const Duration(seconds: 15), // 15 second timeout
            onTimeout: () {
              throw TimeoutException('Order acceptance timed out', const Duration(seconds: 15));
            },
          );
      
      print("DEBUG: Order accepted successfully: ${newOrder.id}");
      
      // Stop notification sound immediately
      AppService().audioPlayer.stop();
      
      // Try to free Firestore node, but don't fail if it doesn't work
      try {
        await FirestoreService().freeDriverOrderNode()
            .timeout(const Duration(seconds: 5)); // 5 second timeout for cleanup
        print("DEBUG: Firestore cleanup completed");
      } catch (firestoreError) {
        print("DEBUG: Firestore cleanup failed (non-critical): $firestoreError");
        // Continue anyway - this is not critical for order acceptance
      }

      // Navigate away immediately
      viewContext.pop(true);
      return;
      
    } catch (error) {
      print("DEBUG: Order acceptance failed: $error");
      
      if (error is TimeoutException) {
        viewContext.showToast(
          msg: "Order acceptance timed out. Please try again.",
          bgColor: Colors.orange,
          textColor: Colors.white,
          textSize: 20,
        );
      } else {
        viewContext.showToast(
          msg: "$error",
          bgColor: Colors.red,
          textColor: Colors.white,
          textSize: 20,
        );
      }

      // Allow dismissal on error
      canDismiss = true;
    } finally {
      setBusy(false);
      _isProcessing = false;
      print("DEBUG: Order acceptance process completed");
    }
    
    // Dismiss if there was an error
    if (canDismiss) {
      AppService().audioPlayer.stop();
      viewContext.pop();
    }
  }

  void countDownCompleted(bool started) async {
    print('Countdown Ended');
    if (started) {
      if (isBusy) {
        canDismiss = true;
      } else {
        AppService().audioPlayer.stop();
        viewContext.pop();
        //STOP NOTIFICATION SOUND
        AppService().stopNotificationSound();
        
        // Try to free Firestore node, but don't fail if it doesn't work
        try {
          await FirestoreService().freeDriverOrderNode();
        } catch (firestoreError) {
          print("DEBUG: Firestore cleanup failed (non-critical): $firestoreError");
          // Continue anyway - this is not critical
        }
      }
    }
  }
}
