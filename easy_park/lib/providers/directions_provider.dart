import 'package:easy_park/services/directions.dart';
import 'package:easy_park/services/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//TODO: see if address can be required somewhere or if it should be removed
final directionsProvider = FutureProvider.autoDispose
    .family<DirectionsInformation, DirectionsInput>((ref, input) async {
  final locationData = await LocationService.getCurrentLocation();
  final location = LatLng(locationData.latitude!, locationData.longitude!);
  Directions directions = await GoogleDirectionsService.instance
      .getDirections(origin: location, destination: input.destination!);
  final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 3.2),
      "assets/images/car_pin.png");
  // Address startAddress = await LocationService.addressFromLatLng(
  //     location.latitude, location.longitude);
  // Address destinationAddress = await LocationService.addressFromLatLng(
  //     input.destination!.latitude, input.destination!.longitude);

  return DirectionsInformation(
      origin: location,
      destination: input.destination!,
      // originAddress: startAddress,
      // destinationAddress: destinationAddress,
      bitmapIcon: icon,
      directions: directions);
});

class DirectionsInformation {
  LatLng origin;
  LatLng destination;
  // Address originAddress;
  // Address destinationAddress;
  Directions directions;

  BitmapDescriptor bitmapIcon;

  DirectionsInformation(
      {required this.origin,
      required this.destination,
      // required this.originAddress,
      // required this.destinationAddress,
      required this.bitmapIcon,
      required this.directions});
}

class DirectionsInput {
  int? sensorId;
  LatLng? destination;

  DirectionsInput.empty();

  DirectionsInput({this.sensorId, this.destination});
}