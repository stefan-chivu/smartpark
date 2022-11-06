import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/day_schedule.dart';
import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/models/schedule.dart';
import 'package:easy_park/models/zone.dart';
import 'package:easy_park/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mysql_client/mysql_client.dart';

class SqlService {
  final pool = MySQLConnectionPool(
      host: Constants.sqlHost,
      port: 3306,
      userName: Constants.sqlUserName,
      password: Constants.sqlPassword,
      maxConnections: 10,
      databaseName: 'easypark',
      secure: true,
      timeoutMs: 2000);

  //TODO: Add more specific parameters
  // i.e. town for narrower query
  Future<List<ParkingInfo>> getParkingSpots() async {
    List<ParkingInfo> parkingInfo = List.empty(growable: true);
    print("Attempting SQL Connection");
    try {
      var result = await pool.execute("SELECT * FROM Sensors");

      print("Fetched Sensor SQL info");

      for (var row in result.rows) {
        int sensorId = row.typedColByName<int>("sensor_id")!;
        double lat = row.typedColByName<double>("latitude")!;
        double long = row.typedColByName<double>("longitude")!;
        int addressId = row.typedColByName<int>("address_id")!;
        int zoneId = row.typedColByName<int>("zone_id")!;

        LatLng position = LatLng(lat, long);

        Address address = await getAddressById(addressId);
        Zone zone = await getZoneById(zoneId);

        bool occupied = await getSensorStatus(sensorId);

        parkingInfo
            .add(ParkingInfo(sensorId, position, address, zone, occupied));
      }
    } catch (e) {
      print("Error");
    }
    return parkingInfo;
  }

  Future<bool> getSensorStatus(int sensorId) async {
    var statusQuery = await pool.execute(
        "SELECT occupied FROM Occupancy WHERE sensor_id = :sensorId ORDER BY timestamp DESC",
        {"sensorId": sensorId});
    ResultSetRow data = statusQuery.rows.first;
    print("Retrieved updated sensor status");
    return data.typedColByName<bool>("occupied")!;
  }

  Future<Address> getAddressById(int addressId) async {
    var result = await pool.execute(
        "SELECT * FROM Addresses WHERE address_id = :addressId",
        {"addressId": addressId});
    ResultSetRow data = result.rows.first;

    String street = data.typedColByName<String>("street")!;
    String city = data.typedColByName<String>("city")!;
    String region = data.typedColByName<String>("region")!;
    String country = data.typedColByName<String>("country")!;

    return Address(street, city, region, country);
  }

  Future<Zone> getZoneById(int zoneId) async {
    var zoneQuery = await pool.execute(
        "SELECT * FROM Zones WHERE zone_id = :zoneId", {"zoneId": zoneId});
    ResultSetRow data = zoneQuery.rows.first;

    String name = data.typedColByName<String>("zone_name")!;
    double hourRate = data.typedColByName<double>("hour_rate")!;
    double? dayRate = data.typedColByName<double>("day_rate");
    bool isPrivate = data.typedColByName<bool>("is_private")!;
    int? totalSpots = data.typedColByName<int>("total_spots");

    List<int?> dayIds = []..length = DateTime.daysPerWeek + 1;
    dayIds[DateTime.monday] = data.typedColByName<int>("mon_schedule_id")!;
    dayIds[DateTime.tuesday] = data.typedColByName<int>("tue_schedule_id")!;
    dayIds[DateTime.wednesday] = data.typedColByName<int>("wed_schedule_id")!;
    dayIds[DateTime.thursday] = data.typedColByName<int>("thu_schedule_id")!;
    dayIds[DateTime.friday] = data.typedColByName<int>("fri_schedule_id")!;
    dayIds[DateTime.saturday] = data.typedColByName<int>("sat_schedule_id")!;
    dayIds[DateTime.sunday] = data.typedColByName<int>("sun_schedule_id")!;

    Schedule schedule = await buildSchedule(dayIds);

    return Zone(name, hourRate, dayRate, isPrivate, totalSpots, schedule);
  }

  Future<Schedule> buildSchedule(List<int?> ids) async {
    Map<int?, DaySchedule> daySchedules = {};
    List<DaySchedule?> result =
        List.filled(DateTime.daysPerWeek + 1, DaySchedule.empty());
    for (int i = DateTime.monday; i <= DateTime.sunday; i++) {
      if (daySchedules.containsKey(ids[i])) {
        result[i] = daySchedules[ids[i]]!;
      } else {
        var zoneQuery = await pool.execute(
            "SELECT * FROM Schedules WHERE schedule_id = :id", {"id": ids[i]});
        ResultSetRow data = zoneQuery.rows.first;
        TimeOfDay startHour =
            parseTimeOfDay(data.typedColByName<String>("start_hour")!);
        TimeOfDay stopHour =
            parseTimeOfDay(data.typedColByName<String>("stop_hour")!);

        daySchedules[ids[i]] = DaySchedule(startHour, stopHour);
        result[i] = daySchedules[ids[i]]!;
      }
    }
    return Schedule(result);
  }

  TimeOfDay parseTimeOfDay(String time) {
    return TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
  }
}
