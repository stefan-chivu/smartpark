import 'dart:io';

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
      timeoutMs: 10000);

  //TODO: Add more specific parameters
  // i.e. town for narrower query
  Future<List<ParkingInfo>?> getParkingSpots() async {
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

        bool occupied = await getSensorStatus(sensorId) ?? false;

        parkingInfo
            .add(ParkingInfo(sensorId, position, address, zone, occupied));
      }
    } catch (e) {
      return null;
    }
    return parkingInfo;
  }

  Future<bool?> getSensorStatus(int sensorId) async {
    try {
      var statusQuery = await pool.execute(
          "SELECT occupied FROM Occupancy WHERE sensor_id = :sensorId ORDER BY timestamp DESC",
          {"sensorId": sensorId});
      ResultSetRow data = statusQuery.rows.first;
      print("Retrieved updated sensor status");
      return data.typedColByName<bool>("occupied")!;
    } catch (e) {
      print(e.toString());
      return null;
    }
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

    int id = data.typedColByName<int>("zone_id")!;
    String name = data.typedColByName<String>("zone_name")!;
    double hourRate = data.typedColByName<double>("hour_rate")!;
    double? dayRate = data.typedColByName<double>("day_rate");
    bool isPrivate = data.typedColByName<bool>("is_private")!;
    int? totalSpots = data.typedColByName<int>("total_spots");

    List<int?> dayIds = []..length = DateTime.daysPerWeek + 1;
    dayIds[DateTime.monday - 1] = data.typedColByName<int>("mon_schedule_id")!;
    dayIds[DateTime.tuesday - 1] = data.typedColByName<int>("tue_schedule_id")!;
    dayIds[DateTime.wednesday - 1] =
        data.typedColByName<int>("wed_schedule_id")!;
    dayIds[DateTime.thursday - 1] =
        data.typedColByName<int>("thu_schedule_id")!;
    dayIds[DateTime.friday - 1] = data.typedColByName<int>("fri_schedule_id")!;
    dayIds[DateTime.saturday - 1] =
        data.typedColByName<int>("sat_schedule_id")!;
    dayIds[DateTime.sunday - 1] = data.typedColByName<int>("sun_schedule_id")!;

    Schedule schedule = await buildSchedule(dayIds);

    return Zone(id, name, hourRate, dayRate, isPrivate, totalSpots, schedule);
  }

  Future<Schedule> buildSchedule(List<int?> ids) async {
    Map<int?, DaySchedule> daySchedules = {};
    List<DaySchedule?> result =
        List.filled(DateTime.daysPerWeek, DaySchedule.empty());
    for (int i = 0; i < DateTime.sunday; i++) {
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

  Future<List<Zone>?> getZones() async {
    List<Zone> zones = List.empty(growable: true);

    try {
      var zonesQuery = await pool.execute("SELECT * FROM Zones");
      for (var row in zonesQuery.rows) {
        int id = row.typedColByName<int>("zone_id")!;
        String name = row.typedColByName<String>("zone_name")!;
        double hourRate = row.typedColByName<double>("hour_rate")!;
        double? dayRate = row.typedColByName<double>("day_rate");
        bool isPrivate = row.typedColByName<bool>("is_private")!;
        int? totalSpots = row.typedColByName<int>("total_spots");

        List<int?> dayIds = []..length = DateTime.daysPerWeek + 1;
        dayIds[DateTime.monday - 1] =
            row.typedColByName<int>("mon_schedule_id")!;
        dayIds[DateTime.tuesday - 1] =
            row.typedColByName<int>("tue_schedule_id")!;
        dayIds[DateTime.wednesday - 1] =
            row.typedColByName<int>("wed_schedule_id")!;
        dayIds[DateTime.thursday - 1] =
            row.typedColByName<int>("thu_schedule_id")!;
        dayIds[DateTime.friday - 1] =
            row.typedColByName<int>("fri_schedule_id")!;
        dayIds[DateTime.saturday - 1] =
            row.typedColByName<int>("sat_schedule_id")!;
        dayIds[DateTime.sunday - 1] =
            row.typedColByName<int>("sun_schedule_id")!;

        Schedule schedule = await buildSchedule(dayIds);

        zones.add(
            Zone(id, name, hourRate, dayRate, isPrivate, totalSpots, schedule));
      }
    } catch (e) {
      print(e.toString());
      if (!e.toString().contains("errno = 103")) {
        return null;
      }
    }

    return zones;
  }

  Future<String> addSensor(
      String sensorId, LatLng latLng, Address address, int zoneId) async {
    int addressId = await findOrCreateAddress(address);

    if (addressId == -1) {
      return "Failed to obtain address";
    }

    try {
      print('Address id: $addressId');
      var res = await pool.execute(
        "INSERT INTO `Sensors` (`sensor_id`, `latitude`, `longitude`, `address_id`, `zone_id`) VALUES (:sensor_id, :latitude, :longitude, :address_id, :zone_id)",
        {
          "sensor_id": int.parse(sensorId),
          "latitude": latLng.latitude,
          "longitude": latLng.longitude,
          "address_id": addressId,
          "zone_id": zoneId,
        },
      );

      print(res.affectedRows);
    } catch (e) {
      return e.toString();
    }
    return "Sensor added successfully";
  }

  Future<int> findOrCreateAddress(Address address) async {
    int id = -1;
    try {
      var result = await pool.execute(
          "SELECT address_id FROM Addresses WHERE street = :street AND city = :city AND region = :region AND country = :country",
          {
            "street": address.street,
            "city": address.city,
            "region": address.region,
            "country": address.country,
          });
      ResultSetRow data = result.rows.first;
      id = data.typedColByName<int>("address_id")!;
      return id;
    } catch (e) {
      if (!e.toString().contains('Bad state: No element')) {
        return -1;
      }
      try {
        print("Address not found. Inserting new addrress.");
        var result = await pool.execute(
            "INSERT INTO `Addresses` (`street`, `city`, `region`, `country`) VALUES (:street, :city, :region, :country)",
            {
              "street": address.street ?? "",
              "city": address.city ?? "",
              "region": address.region ?? "",
              "country": address.country ?? "",
            });

        sleep(const Duration(milliseconds: 500));

        result = await pool.execute(
            "SELECT address_id FROM `Addresses` WHERE `street` = ':street' AND `city` = ':city' AND `region` = ':region' AND `country` = ':country' ",
            {
              "street": address.street,
              "city": address.city,
              "region": address.region,
              "country": address.country,
            });
        ResultSetRow data = result.rows.first;
        id = data.typedColByName<int>("address_id")!;
      } catch (e) {
        print("Failed inserting new addrress: " + e.toString());
        id = -1;
      }

      return id;
    }
  }

  Future<bool> getUserAdminStatus(String uid) async {
    try {
      var result =
          await pool.execute("SELECT is_admin FROM Users WHERE uid = :uid", {
        "uid": uid,
      });
      ResultSetRow data = result.rows.first;
      bool isAdmin = data.typedColByName<bool>("is_admin")!;
      return isAdmin;
    } catch (e) {
      return false;
    }
  }
}
