import 'package:easy_park/models/day_schedule.dart';

class Schedule {
  late List<DaySchedule?> schedule;

  Schedule(this.schedule);

  Schedule.fromIndividualSchedules(
      DaySchedule monSched,
      DaySchedule tueSched,
      DaySchedule wedSched,
      DaySchedule thuSched,
      DaySchedule friSched,
      DaySchedule satSched,
      DaySchedule sunSched) {
    schedule = []..length = DateTime.daysPerWeek + 1;
    schedule[DateTime.monday] = monSched;
    schedule[DateTime.tuesday] = tueSched;
    schedule[DateTime.wednesday] = wedSched;
    schedule[DateTime.thursday] = thuSched;
    schedule[DateTime.friday] = friSched;
    schedule[DateTime.saturday] = satSched;
    schedule[DateTime.sunday] = sunSched;
  }
}
