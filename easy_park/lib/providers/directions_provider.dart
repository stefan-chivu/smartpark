import 'package:easy_park/services/directions.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/sql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final directionsProvider = FutureProvider.autoDispose
    .family<DirectionsInformation, DirectionsInput>((ref, input) async {
  final locationData = await Geolocator.getCurrentPosition();
  final location = LatLng(locationData.latitude, locationData.longitude);
  Directions directions = await GoogleDirectionsService.instance
      .getDirections(origin: location, destination: input.destination!);
  final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 3.2),
      "assets/images/car_pin.png");

  await SqlService.reserveSpot(IsarService.getUid(), input.sensorId!);
  return DirectionsInformation(
      origin: location,
      destination: input.destination!,
      bitmapIcon: icon,
      directions: directions);
});

class DirectionsInformation {
  LatLng origin;
  LatLng destination;
  Directions directions;

  BitmapDescriptor bitmapIcon;

  DirectionsInformation(
      {required this.origin,
      required this.destination,
      required this.bitmapIcon,
      required this.directions});
}

class DirectionsInput {
  int? sensorId;
  LatLng? destination;

  DirectionsInput.empty();

  DirectionsInput({this.sensorId, this.destination});
}
