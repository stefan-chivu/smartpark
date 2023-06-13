import 'package:easy_park/models/day_schedule.dart';

const List<String> weekDays = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

const List<String> weekDaysShort = [
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat",
  "Sun"
];

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
    schedule = []..length = DateTime.daysPerWeek;
    schedule[DateTime.monday - 1] = monSched;
    schedule[DateTime.tuesday - 1] = tueSched;
    schedule[DateTime.wednesday - 1] = wedSched;
    schedule[DateTime.thursday - 1] = thuSched;
    schedule[DateTime.friday - 1] = friSched;
    schedule[DateTime.saturday - 1] = satSched;
    schedule[DateTime.sunday - 1] = sunSched;
  }

  @override
  String toString() {
    String result = "";

    result += weekDaysShort[0];
    int streakLen = 0;
    for (int i = 1; i <= DateTime.sunday; i++) {
      if (i < 6) {
        if (schedule[i - 1] == schedule[i]) {
          streakLen++;
          continue;
        } else {
          if (streakLen > 0) {
            result += "-${weekDaysShort[i - 1]}: ${schedule[i - 1].toString()}";
          } else {
            result += ": ${schedule[i - 1].toString()}";
          }
          result += "\n${weekDaysShort[i]}";
          streakLen = 0;
        }
      } else {
        // Sunday case
        if (schedule[i - 1] == schedule[i]) {
          result += "-${weekDaysShort[i]}";
          result += ": ${schedule[i - 1].toString()}";
        } else {
          if (streakLen > 0) {
            result += "-${weekDaysShort[i - 1]}: ${schedule[i - 1].toString()}";
          } else {
            result += ": ${schedule[i - 1].toString()}";
          }
          result += "\n${weekDaysShort[i]}: ${schedule[i].toString()}";
          streakLen = 0;
        }
        break;
      }
    }

    return result;
  }
}
