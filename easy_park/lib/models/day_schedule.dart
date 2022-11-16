import 'package:flutter/material.dart';

class DaySchedule {
  late TimeOfDay startHour;
  late TimeOfDay stopHour;

  DaySchedule(this.startHour, this.stopHour);

  DaySchedule.empty() {
    startHour = const TimeOfDay(hour: 0, minute: 0);
    stopHour = const TimeOfDay(hour: 0, minute: 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaySchedule &&
          runtimeType == other.runtimeType &&
          startHour == other.startHour &&
          stopHour == other.stopHour;

  @override
  int get hashCode => startHour.hashCode + stopHour.hashCode;

  @override
  String toString() {
    String strStartHour = startHour.hour.toString().padLeft(2, '0');
    String strStartMin = startHour.minute.toString().padLeft(2, '0');
    String strStopHour = stopHour.hour.toString().padLeft(2, '0');
    String strStopMin = stopHour.minute.toString().padLeft(2, '0');
    return "$strStartHour:$strStartMin - $strStopHour:$strStopMin";
  }
}
