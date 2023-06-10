import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/zone.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final addSensorProvider =
    FutureProvider.autoDispose<AddSensorInfo>((ref) async {
  final List<Zone> zones = await SqlService.getZones() ?? [];
  Position position = await Geolocator.getCurrentPosition();
  LatLng crtPosition = LatLng(position.latitude, position.longitude);
  Address crtAddress = await LocationService.addressFromLatLng(
      crtPosition.latitude, crtPosition.longitude);
  return AddSensorInfo(
      zones: zones, crtPosition: crtPosition, crtAddress: crtAddress);
});

class AddSensorInfo {
  List<Zone> zones;
  LatLng crtPosition;
  Address crtAddress;
  AddSensorInfo(
      {required this.zones,
      required this.crtPosition,
      required this.crtAddress});
}
