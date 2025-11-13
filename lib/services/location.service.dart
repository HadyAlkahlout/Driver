import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/delivery_address.dart';
import 'package:fuodz/requests/driver.request.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/firestore.service.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georange/georange.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:singleton/singleton.dart';

class LocationService {
  /// Factory method that reuse same instance automatically
  factory LocationService() => Singleton.lazy(() => LocationService._());

  /// Private constructor
  LocationService._() {}

  //
  GeoFlutterFire geoFlutterFire = GeoFlutterFire();
  GeoRange georange = GeoRange();
  //  Geolocator location = Geolocator();
  //  LocationSettings locationSettings;
  Position? currentLocationData;
  DeliveryAddress? currentLocation;
  bool? serviceEnabled;
  FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  BehaviorSubject<bool> locationDataAvailable = BehaviorSubject<bool>.seeded(
    false,
  );
  BehaviorSubject<double> driverLocationEarthDistance =
      BehaviorSubject<double>.seeded(0.00);
  int lastUpdated = 0;
  StreamSubscription? locationUpdateStream;

  //
  Future<void> prepareLocationListener() async {
    //handle missing permission
    await handlePermissionRequest();
    _startLocationListner();
  }

  // Safer version that doesn't throw exceptions
  Future<bool> prepareLocationListenerSafely() async {
    try {
      //handle missing permission
      await handlePermissionRequest();
      _startLocationListner();
      return true;
    } catch (error) {
      print("Error preparing location listener: $error");
      return false;
    }
  }

  Future<bool?> handlePermissionRequest({bool background = false}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw "Location service is disabled. Please enable it and try again".tr();
    }

    var locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      // Cannot request runtime permission because location permission is denied forever.
      throw "Location permission denied permanetly. Please check on location permission on app settings"
          .tr();
    } else if (locationPermission == LocationPermission.denied) {
      // Ask the user for location permission.
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) {
        throw "Location permission denied. Please check on location permission on app settings"
            .tr();
      }
    }

    // Additional check to ensure we have at least whileInUse permission
    if (locationPermission != LocationPermission.whileInUse &&
        locationPermission != LocationPermission.always) {
      throw "Location permission is required for this app to function properly"
          .tr();
    }

    // // Location permission must always be allowed (LocationPermission.always)
    // // to collect location data in the background.
    // if (background == true &&
    //     locationPermission == LocationPermission.whileInUse) {
    //   return false;
    // }

    // Location services has been enabled and permission have been granted.
    return true;
  }

  Stream<dynamic> getNewLocationStream() {
    // return Geolocator.getPositionStream(
    //   locationSettings: LocationSettings(
    //     accuracy: LocationAccuracy.high,
    //     interval: AppStrings.timePassLocationUpdate * 1000,
    //     distanceFilter: (AppStrings.distanceCoverLocationUpdate ?? 5).toInt(),
    //   ),
    // );
    try {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: AppStrings.distanceCoverLocationUpdate.ceil(),
          //seconds to milliseconds
          // interval: AppStrings.timePassLocationUpdate * 1000,
          // distanceFilter: 0,
        ),
      );
    } catch (error) {
      return Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          // interval: AppStrings.timePassLocationUpdate * 1000,
          distanceFilter: (AppStrings.distanceCoverLocationUpdate).toInt(),
        ),
      );
    }
  }

  void _startLocationListner() async {
    //handle first time
    syncFirstTimeLocation();
    //listen
    locationUpdateStream?.cancel();
    locationUpdateStream = getNewLocationStream().listen((currentPosition) {
      //
      if (currentPosition != null) {
        print("Location changed ==> $currentPosition");
        // Use current location
        if (currentLocation == null) {
          currentLocation = DeliveryAddress();
          locationDataAvailable.add(true);
        }

        currentLocation?.latitude = currentPosition.latitude;
        currentLocation?.longitude = currentPosition.longitude;
        currentLocationData = Position.fromMap(currentPosition.toJson());
        //
        syncLocationWithFirebase(currentLocationData!);
      } else {
        print("Location changed ==> null");
      }
    });
  }

  syncFirstTimeLocation() async {
    try {
      //get current location
      Position currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (this.currentLocation == null) {
        this.currentLocation = DeliveryAddress();
        locationDataAvailable.add(true);
      }

      this.currentLocation?.latitude = currentLocation.latitude;
      this.currentLocation?.longitude = currentLocation.longitude;
      this.currentLocationData = Position.fromMap(currentLocation.toJson());
      //
      syncLocationWithFirebase(currentLocationData!);
    } catch (error) {
      print("Error getting first time location => $error");
    }
  }

  //
  syncCurrentLocFirebase() {
    syncLocationWithFirebase(currentLocationData!);
  }

  //
  syncLocationWithFirebase(Position currentLocation) async {
    //
    if (AppService().driverIsOnline) {
      // Throttle location updates - only update if 10 seconds have passed
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastUpdated < 10000) {
        // 10 seconds throttle
        return;
      }

      print("Send to fcm");
      //get distance to earth center
      Point driverLocation = Point(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      Point earthCenterLocation = Point(latitude: 0.00, longitude: 0.00);
      //
      var earthDistance = georange.distance(
        earthCenterLocation,
        driverLocation,
      );

      //if no using websocket
      bool useWebsocket = AppStrings.useWebsocketAssignment;
      if (!useWebsocket) {
        await FirestoreService().pushLocToFirestore(
          driverLocation: driverLocation,
          currentLocation: currentLocation,
          earthDistance: earthDistance,
        );
      } else {
        //
        await DriverRequest().syncLocation(
          lat: currentLocation.latitude,
          lng: currentLocation.longitude,
          rotation: currentLocation.heading,
        );
      }

      driverLocationEarthDistance.add(earthDistance);
      lastUpdated = now;
    }
  }

  //
  clearLocationFromFirebase() async {
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    await firebaseFireStore.collection("drivers").doc(driverId).delete();
  }
}
