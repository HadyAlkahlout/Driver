import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/app.service.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georange/georange.dart';

import 'package:singleton/singleton.dart';

class FirestoreService {
  //
  /// Factory method that reuse same instance automatically
  factory FirestoreService() => Singleton.lazy(() => FirestoreService._());

  /// Private constructor
  FirestoreService._() {}
  GeoFlutterFire geoFlutterFire = GeoFlutterFire();

  //
  FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;

  //
  freeDriverOrderNode() async {
    final driver = await AuthServices.getCurrentUser(force: true);
    String driverId = driver.id.toString();
    await firebaseFireStore
        .collection("driver_new_order")
        .doc(driverId)
        .delete();
  }

  //
  pushLocToFirestore({
    required Point driverLocation,
    required Position currentLocation,
    required double earthDistance,
  }) async {
    //
    final driverId = (await AuthServices.getCurrentUser()).id.toString();
    GeoFirePoint geoRepLocation = geoFlutterFire.point(
      latitude: driverLocation.latitude,
      longitude: driverLocation.longitude,
    );

    //
    final driverLocationDocs =
        await firebaseFireStore.collection("drivers").doc(driverId).get();

    //
    final docRef = driverLocationDocs.reference;

    if (driverLocationDocs.data() == null) {
      await docRef.set({
        "id": driverId,
        "lat": currentLocation.latitude,
        "long": currentLocation.longitude,
        "rotation": currentLocation.heading,
        "earth_distance": earthDistance,
        "range": AppStrings.driverSearchRadius,
        "coordinates": GeoPoint(
          currentLocation.latitude,
          currentLocation.longitude,
        ),
        "g": geoRepLocation.data,
        "online": AppService().driverIsOnline ? 1 : 0,
      });
    } else {
      await docRef.update({
        "id": driverId,
        "lat": currentLocation.latitude,
        "long": currentLocation.longitude,
        "rotation": currentLocation.heading,
        "earth_distance": earthDistance,
        "range": AppStrings.driverSearchRadius,
        "coordinates": GeoPoint(
          currentLocation.latitude,
          currentLocation.longitude,
        ),
        "g": geoRepLocation.data,
        "online": AppService().driverIsOnline ? 1 : 0,
      });
    }
  }
}
