import 'package:easy_park/models/schedule.dart';

class Zone {
  String name;
  double hourRate;
  double? dayRate;
  bool isPrivate = false;
  int? totalSpots;
  Schedule schedule;

  Zone(this.name, this.hourRate, this.dayRate, this.isPrivate, this.totalSpots,
      this.schedule);
}
