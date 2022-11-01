// parking info model
import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/zone.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingInfo {
  int sensorId;
  LatLng position;
  Address address;
  Zone zone;
  bool occupied;
  ParkingInfo(
      this.sensorId, this.position, this.address, this.zone, this.occupied);
}
