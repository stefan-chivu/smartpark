// parking info model
import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/zone.dart';

class ParkingInfo {
  int sensorId;
  double latitude;
  double longitude;
  Address address;
  Zone zone;
  bool occupied;
  ParkingInfo(this.sensorId, this.latitude, this.longitude, this.address,
      this.zone, this.occupied);
}
