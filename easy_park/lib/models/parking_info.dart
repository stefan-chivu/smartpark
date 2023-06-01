// parking info model
import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/zone.dart';

enum SpotState { free, occupied, reserved, freeingSoon, unknown }

class SpotInfo {
  int sensorId;
  double latitude;
  double longitude;
  Address address;
  Zone zone;
  SpotState state;
  SpotInfo(this.sensorId, this.latitude, this.longitude, this.address,
      this.zone, this.state);
}
