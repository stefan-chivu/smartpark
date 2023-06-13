// parking info model
import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/zone.dart';

enum SpotState { free, occupied, reserved, freeingSoon, unknown }

class SpotInfo {
  int sensorId;
  double latitude;
  double longitude;
  bool isElectric;
  Address address;
  Zone zone;
  SpotState state;
  SpotInfo(this.sensorId, this.latitude, this.longitude, this.isElectric,
      this.address, this.zone, this.state);
}
