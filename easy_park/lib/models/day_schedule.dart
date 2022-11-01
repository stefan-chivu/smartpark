import 'package:flutter/material.dart';

class DaySchedule {
  late TimeOfDay startHour;
  late TimeOfDay stopHour;

  DaySchedule(this.startHour, this.stopHour);

  DaySchedule.empty() {
    startHour = const TimeOfDay(hour: 0, minute: 0);
    stopHour = const TimeOfDay(hour: 0, minute: 0);
  }
}
