import 'dart:convert';

import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:georange/georange.dart';

NewOrder newOrderFromJson(String str) => NewOrder.fromJson(json.decode(str));

String newOrderToJson(NewOrder data) => json.encode(data.toJson());

class NewOrder {
  NewOrder({
    this.id,
    required this.amount,
    required this.total,
    required this.dropoff,
    required this.pickup,
    required this.range,
    this.distance,
    required this.earthDistance,
    required this.vendorId,
    required this.isParcel,
    required this.packageType,
    required this.expiresAt,
    this.docRef,
    this.assignmentId,
  });

  String amount;
  String total;
  Dropoff? dropoff;
  int? id;
  Pickup? pickup;
  double range;
  double? distance;
  double? orderDistance;
  double? earthDistance;
  int? vendorId;
  bool isParcel;
  String packageType;
  int expiresAt;
  String? docRef;
  int? assignmentId;

  factory NewOrder.fromJson(Map<String, dynamic> json, {bool clean = false}) {
    NewOrder model = NewOrder(
      amount: json["amount"] == null ? "" : json["amount"],
      total: json["total"] == null ? "" : json["total"].toString(),
      earthDistance: json["earth_distance"] == null
          ? 0
          : double.parse(json["earth_distance"].toString()),
      dropoff: json["dropoff"] == null
          ? null
          : Dropoff.fromJson(
              clean ? json["dropoff"] : jsonDecode(json["dropoff"])),
      id: json["id"] == null ? null : int.parse(json["id"].toString()),
      pickup: json["pickup"] == null
          ? null
          : Pickup.fromJson(
              clean ? json["pickup"] : jsonDecode(json["pickup"])),
      range: json["range"] == null ? 0 : double.parse(json["range"].toString()),
      vendorId: json["vendor_id"] == null
          ? null
          : int.parse(json["vendor_id"].toString()),
      isParcel: _parseBool(json["is_parcel"]),
      packageType: json["package_type"] ?? "",
      expiresAt: json["expiresAt"] != null
          ? json["expiresAt"]
          : DateTime.now().millisecondsSinceEpoch +
              (AppStrings.alertDuration * 1000),
      assignmentId: json["assignment_id"] != null
          ? int.parse(json["assignment_id"].toString())
          : null,
    );

    //if pickup and dropoff distance is not available, calculate it
    if (model.pickup?.distance == null) {
      final location1 = Point(
        latitude: model.pickup!.lat!,
        longitude: model.pickup!.long!,
      );
      final location2 = Point(
        latitude: LocationService().currentLocation?.latitude ?? 0.00,
        longitude: LocationService().currentLocation?.longitude ?? 0.00,
      );
      model.pickup?.distance = GeoRange().distance(location1, location2);
    }

    //if pickup and dropoff distance is not available, calculate it
    if (model.dropoff?.distance == null) {
      final location1 = Point(
        latitude: model.pickup!.lat!,
        longitude: model.pickup!.long!,
      );
      final location2 = Point(
        latitude: model.dropoff!.lat!,
        longitude: model.dropoff!.long!,
      );
      model.dropoff?.distance = GeoRange().distance(location1, location2);
    }

    return model;
  }

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "total": total,
        "earth_distance": earthDistance,
        "dropoff": dropoff == null ? null : dropoff?.toJson(),
        "id": id == null ? null : id,
        "pickup": pickup == null ? null : pickup?.toJson(),
        "range": range,
        "vendor_id": vendorId == null ? null : vendorId,
        "is_parcel": isParcel,
        "package_type": packageType,
        "expiresAt": expiresAt,
        "assignment_id": assignmentId,
      };

  //
  int get initialAlertDuration {
    int duration = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final timePast = expiresAt - now;
    print("expiresAt ==> $expiresAt");
    print("now ==> $now");
    print("timePast ==> $timePast");
    if (timePast > 0) {
      duration = AppStrings.alertDuration - (timePast ~/ 1000);
    } else {
      duration = AppStrings.alertDuration - 1;
    }
    return duration;
  }

  // Helper method to parse boolean values from various formats
  static bool _parseBool(dynamic value) {
    print("DEBUG: Parsing boolean value: '$value' (type: ${value.runtimeType})");
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final str = value.toLowerCase().trim();
      final result = str == 'true' || str == '1' || str == 'yes';
      print("DEBUG: String '$str' parsed to boolean: $result");
      return result;
    }
    if (value is int) return value != 0;
    print("DEBUG: Unknown type, defaulting to false");
    return false;
  }
}

class Dropoff {
  Dropoff({
    this.address,
    this.distance,
    this.country,
    this.state,
    this.city,
    this.lat,
    this.long,
  });

  String? address;
  String? city;
  String? country;
  String? state;
  double? lat;
  double? long;
  double? distance;

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
        distance: json["distance"] == null
            ? 0.00
            : double.parse(
                json["distance"].toString().replaceAll(",", ""),
              ),
        address: json["address"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        lat: json["lat"] == null ? null : double.parse(json["lat"].toString()),
        long:
            json["long"] == null ? null : double.parse(json["long"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "distance": distance,
        "country": country,
        "city": city,
        "state": state,
        "lat": lat == null ? null : lat,
        "long": long == null ? null : long,
      };
}

class Pickup {
  Pickup({
    this.address,
    this.distance,
    this.city,
    this.state,
    this.country,
    this.lat,
    this.long,
  });

  String? address;
  String? city;
  String? state;
  String? country;
  double? lat;
  double? long;
  double? distance;

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
        address: json["address"] == null ? null : json["address"],
        distance: json["distance"] == null
            ? 0.0
            : double.parse(
                json["distance"].toString().replaceAll(",", ""),
              ),
        city: json["city"],
        state: json["state"],
        country: json["country"],
        lat: json["lat"] == null ? null : double.parse(json["lat"].toString()),
        long: json["long"] == null
            ? json["lng"] == null
                ? null
                : double.parse(json["lng"].toString())
            : double.parse(json["long"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "distance": distance,
        "country": country,
        "state": state,
        "city": city,
        "lat": lat,
        "long": long,
      };
}
