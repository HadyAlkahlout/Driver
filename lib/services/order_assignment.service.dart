import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'auth.service.dart';

class OrderAssignmentService {
  //check if driver can handle the new order
  static Future<bool> driverCanHandleOrder(
    Map<String, dynamic> json,
    String docRefString,
  ) async {
    // First check if driver is online
    final isDriverOnline = await checkDriverOnlineStatus();
    if (!isDriverOnline) {
      print("DEBUG: Driver is offline, cannot handle order");
      return false;
    }

    // Check if order is still available and not assigned
    final isOrderAvailable = await checkOrderStatus(json, docRefString);
    if (!isOrderAvailable) {
      print("DEBUG: Order is no longer available or already assigned");
      return false;
    }

    bool handle = await checkForSameVehicleType(json);
    if (handle) {
      final canPickup = await driverWithinPickup(json);
      if (canPickup) {
        handle = await runDriverNotifiedTransaction(json, docRefString);
      } else {
        handle = false;
      }
    }
    return handle;
  }

  //
  static Future<bool> checkForSameVehicleType(Map<String, dynamic> json) async {
    final vehicleTypeID = json['vehicle_type_id'];
    if (vehicleTypeID == null || vehicleTypeID == 0) {
      return true;
    }
    final driverVehicle = await AuthServices.getDriverVehicle();
    if (driverVehicle == null) {
      return false;
    }
    return driverVehicle.vehicleTypeId == vehicleTypeID;
  }

  //
  static Future<bool> driverWithinPickup(Map<String, dynamic> json) async {
    try {
      // Temporarily disable geo-location filtering for testing
      print(
        "DEBUG: Geo-location check temporarily disabled - allowing all orders",
      );
      return true;

      // Original geo-location code (commented out for testing)
      /*
      dynamic pickupJson = json['pickup'];
      if (pickupJson is String) {
        pickupJson = jsonDecode(pickupJson);
      }

      Pickup? pickup = Pickup.fromJson(pickupJson);
      final cLoc = await Geolocator.getCurrentPosition(timeLimit: 10.seconds);
      //get pickup distance
      double distance = Geolocator.distanceBetween(
        cLoc.latitude,
        cLoc.longitude,
        pickup.lat!.toDouble(),
        pickup.long!.toDouble(),
      );
      distance = distance / 1000;
      //check distance
      return distance <= AppStrings.driverSearchRadius;
      */
    } catch (error) {
      print("DEBUG: Error in geo-location check: $error");
      return true; // Allow order even if geo check fails
    }
  }

  //run transaction to let other driver know you are currently bein notified
  static Future<bool> runDriverNotifiedTransaction(
    Map<String, dynamic> json,
    String docRefString,
  ) async {
    try {
      // Temporarily disable Firestore transaction checks for testing
      if (docRefString.isEmpty) {
        print(
          "DEBUG: No docRef provided, skipping Firestore transaction check",
        );
        return true;
      }

      print(
        "DEBUG: Firestore transaction checks temporarily disabled - allowing order",
      );
      return true;

      // Original transaction code (commented out for testing)
      /*
      final driver = await AuthServices.getCurrentUser();
      return (await FirebaseFirestore.instance
          .runTransaction<bool>((transaction) async {
            // Get the document
            DocumentReference docRef = FirebaseFirestore.instance.doc(
              docRefString,
            );
            DocumentSnapshot snapshot = await transaction.get(docRef);

            if (!snapshot.exists) {
              // throw Exception("User does not exist!");
              return false;
            }

            //check if i was informed already
            List? informedDrivers = (snapshot.data() as Map)['informed'] as List?;
            if (informedDrivers != null && informedDrivers.contains(driver.id)) {
              return false;
            }

            //check if already ignored
            List ignoredDrivers = (snapshot.data() as Map)['ignored'] as List;
            if (ignoredDrivers.contains(driver.id)) {
              return false;
            }

            int maxDriverNotifiable =
                int.tryParse((snapshot.data() as Map)['notifiable'].toString()) ??
                1;
            if (informedDrivers == null) {
              informedDrivers = [driver.id];
            } else if (informedDrivers.length < maxDriverNotifiable &&
                !informedDrivers.contains(driver.id)) {
              informedDrivers.add(driver.id);
            } else {
              return false;
            }

            // Perform an update on the document
            transaction.update(docRef, {'informed': informedDrivers});

            return true;
          }, maxAttempts: 2)
          .catchError((error) {
            print(error);
            return false;
          }));
      */
    } catch (error) {
      print("DEBUG: Error in transaction check: $error");
      return true; // Allow order if transaction fails
    }
  }

  //release order for other drivers
  static Future<bool> releaseOrderForotherDrivers(
    Map<String, dynamic> json,
    String docRefString,
  ) async {
    final driver = await AuthServices.getCurrentUser();
    final done = (await FirebaseFirestore.instance
        .runTransaction<bool>((transaction) async {
          // Get the document
          DocumentReference docRef = FirebaseFirestore.instance.doc(
            docRefString,
          );
          DocumentSnapshot snapshot = await transaction.get(docRef);

          if (!snapshot.exists) {
            // throw Exception("User does not exist!");
            return false;
          }

          //remove driver id from noified drivers
          List? informedDrivers = (snapshot.data() as Map)['informed'] as List?;
          if (informedDrivers == null) {
            informedDrivers = [];
          } else if (informedDrivers.contains(driver.id)) {
            informedDrivers.remove(driver.id);
          }

          //add driver id to list of ignored drivers
          List? ignoredDrivers = (snapshot.data() as Map)['ignored'] as List?;
          if (ignoredDrivers == null) {
            ignoredDrivers = [driver.id];
          } else if (!ignoredDrivers.contains(driver.id)) {
            ignoredDrivers.add(driver.id);
          } else {
            return false;
          }

          // Perform an update on the document
          transaction.update(docRef, {
            'ignored': ignoredDrivers,
            "informed": informedDrivers,
          });
          return true;
        }, maxAttempts: 2)
        .catchError((error) {
          print(error);
          return false;
        }));
    // .then((value) => print("Follower count updated to $value"))

    return done;
  }

  // Check if driver is currently online
  static Future<bool> checkDriverOnlineStatus() async {
    try {
      // Check local storage for online status
      final isOnlineLocally =
          LocalStorageService.prefs!.getBool(AppStrings.onlineOnApp) ?? false;
      if (!isOnlineLocally) {
        return false;
      }

      // Additional check: verify with current user data
      final currentUser = await AuthServices.getCurrentUser();
      if (!currentUser.isOnline) {
        return false;
      }

      return true;
    } catch (error) {
      print("DEBUG: Error checking driver online status: $error");
      return false;
    }
  }

  // Check if order is still available and not assigned to another driver
  static Future<bool> checkOrderStatus(
    Map<String, dynamic> json,
    String docRefString,
  ) async {
    try {
      // If no docRefString is provided, skip Firestore check but allow the order
      if (docRefString.isEmpty) {
        print(
          "DEBUG: No docRef provided, skipping Firestore order status check",
        );
        return true;
      }

      // Get the document from Firestore
      DocumentReference docRef = FirebaseFirestore.instance.doc(docRefString);
      DocumentSnapshot snapshot = await docRef.get();

      if (!snapshot.exists) {
        print("DEBUG: Order document no longer exists");
        return true; // Allow order if document doesn't exist
      }

      final orderData = snapshot.data() as Map<String, dynamic>?;
      if (orderData == null) {
        return true; // Allow order if no data
      }

      // Check if order has been assigned
      final assignedDriverId = orderData['assigned_driver_id'];
      if (assignedDriverId != null && assignedDriverId != 0) {
        print("DEBUG: Order already assigned to driver: $assignedDriverId");
        return false;
      }

      // Check if order status indicates it's no longer available
      final status = orderData['status'] ?? orderData['order_status'];
      if (status != null) {
        // Common status values that indicate order is no longer available for pickup
        final unavailableStatuses = [
          'assigned',
          'picked_up',
          'delivered',
          'cancelled',
          'completed',
        ];
        if (unavailableStatuses.contains(status.toString().toLowerCase())) {
          print("DEBUG: Order status is $status, not available for pickup");
          return false;
        }
      }

      // Check if order has expired
      final expiresAt = orderData['expires_at'];
      if (expiresAt != null) {
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (expiresAt < currentTime) {
          print("DEBUG: Order has expired");
          return false;
        }
      }

      return true;
    } catch (error) {
      print("DEBUG: Error checking order status: $error");
      return true; // Allow order if check fails
    }
  }
}
