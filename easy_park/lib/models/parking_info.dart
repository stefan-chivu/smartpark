// parking info model
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingInfo {
  int id;
  bool occupied;
  LatLng? position;
  ParkingInfo(this.id, this.occupied, double latitude, double longitude) {
    position = LatLng(latitude, longitude);
  }
}
