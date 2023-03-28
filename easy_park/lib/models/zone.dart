import 'package:easy_park/models/schedule.dart';

class Zone {
  int id;
  String name;
  double hourRate;
  double? dayRate;
  String currency;
  bool isPrivate = false;
  int? totalSpots;
  Schedule schedule;

  Zone(this.id, this.name, this.hourRate, this.dayRate, this.currency,
      this.isPrivate, this.totalSpots, this.schedule);
}
