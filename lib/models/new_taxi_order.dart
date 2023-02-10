// To parse this JSON data, do
//
//     final newTaxiOrder = newTaxiOrderFromJson(jsonString);

import 'dart:convert';

import 'package:fuodz/constants/app_strings.dart';
import 'package:fuodz/models/new_order.dart';
import 'package:fuodz/services/location.service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supercharged/supercharged.dart';

NewTaxiOrder newTaxiOrderFromJson(String str) =>
    NewTaxiOrder.fromJson(json.decode(str));

String newTaxiOrderToJson(NewTaxiOrder data) => json.encode(data.toJson());

class NewTaxiOrder {
  NewTaxiOrder({
    this.pickup,
    this.status,
    this.driverId,
    this.id,
    this.code,
    this.vehicleTypeId,
    this.tripDistance,
    this.serverPickupDistance,
    this.dropoff,
    this.earthDistance,
    this.expiresAt,
    this.docRef,
  });

  Pickup pickup;
  String status;
  dynamic driverId;
  int id;
  String code;
  int vehicleTypeId;
  double tripDistance;
  double serverPickupDistance;
  Dropoff dropoff;
  double earthDistance;
  int expiresAt;
  String docRef;

  factory NewTaxiOrder.fromJson(Map<String, dynamic> json) => NewTaxiOrder(
        pickup: Pickup.fromJson(jsonDecode(json["pickup"])),
        status: json["status"].toString(),
        driverId: json["driver_id"].toString().toInt() ?? null,
        id: json["id"].toString().toInt(),
        code: json["code"].toString(),
        vehicleTypeId: json["vehicle_type_id"].toString().toInt(),
        tripDistance: json["trip_distance"].toString().toDouble(),
        serverPickupDistance: json["pickup_distance"] != null
            ? json["pickup_distance"].toString().toDouble()
            : null,
        dropoff: Dropoff.fromJson(jsonDecode(json["dropoff"])),
        earthDistance: json["earth_distance"].toString().toDouble(),
        expiresAt: json["expiresAt"] != null
            ? json["expiresAt"]
            : DateTime.now().millisecondsSinceEpoch +
                (AppStrings.alertDuration * 1000),
      );

  double get pickupDistance {
    return serverPickupDistance ??
        Geolocator.distanceBetween(
              LocationService().currentLocation?.latitude ?? 0.00,
              LocationService().currentLocation?.longitude ?? 0.00,
              pickup.lat.toDouble(),
              pickup.long.toDouble(),
            ) /
            1000;
  }

  Map<String, dynamic> toJson() => {
        "pickup": jsonEncode(pickup.toJson()),
        "status": status,
        "driver_id": driverId,
        "id": id,
        "code": code,
        "vehicle_type_id": vehicleTypeId,
        "trip_distance": tripDistance,
        "pickup_distance": serverPickupDistance,
        "dropoff": jsonEncode(dropoff.toJson()),
        "earth_distance": earthDistance,
        "expiresAt": expiresAt,
      };

  //
  int get initialAlertDuration {
    int duration = 0;
    if (expiresAt != null) {
      final timePast = expiresAt - DateTime.now().millisecondsSinceEpoch;
      if (timePast > 0) {
        duration = AppStrings.alertDuration - (timePast ~/ 1000);
      } else {
        duration = AppStrings.alertDuration - 1;
      }
    }
    return duration;
  }
}
