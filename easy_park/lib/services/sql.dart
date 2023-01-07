// ignore_for_file: avoid_print

import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/day_schedule.dart';
import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/models/schedule.dart';
import 'package:easy_park/models/zone.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mysql_client/mysql_client.dart';

const bool sensorStatusFree = false;
const bool sensorStatusOccupied = true;

class SqlService {
  static final pool = MySQLConnectionPool(
      host: Constants.sqlHost,
      port: 3306,
      userName: Constants.sqlUserName,
      password: Constants.sqlPassword,
      maxConnections: 10,
      databaseName: 'easypark',
      secure: true,
      timeoutMs: 2000);

  static final Map<int, Zone> _zones = {};
  static final Map<int, Address> _addresses = {};

  SqlService._privateConstructor();
  static final SqlService instance = SqlService._privateConstructor();

/* 
  TODO: only get available spots OR only display available spots
     by only displaying available spots instead of not fetching them at all
     some logic such as 'soon-to-be freed' spots might be added 
*/
  static Future<Map<int, ParkingInfo>> getParkingSpotsAroundPosition(
      double latitude, double longitude, double rangeKm) async {
    Map<int, ParkingInfo> parkingInfo = {};
    LatLongRangeLimits limits =
        LocationService.getPointRadiusKm(latitude, longitude, rangeKm);
    try {
      var result = await pool.execute(
          "SELECT * FROM Sensors WHERE latitude >= :minLat AND latitude <= :maxLat AND longitude >= :minLong AND longitude <= :maxLong",
          {
            "minLat": limits.minLat,
            "maxLat": limits.maxLat,
            "minLong": limits.minLong,
            "maxLong": limits.maxLong,
          });

      print(
          "Fetched Sensor SQL info within $rangeKm of ($latitude ; $longitude)");

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

        parkingInfo[sensorId] = (ParkingInfo(sensorId, position.latitude,
            position.longitude, address, zone, occupied));
      }
    } catch (e) {
      print(e.toString());
    }
    return parkingInfo;
  }

  static Future<bool?> getSensorStatus(int sensorId) async {
    print("Fetching sensor $sensorId status");
    try {
      var occupancyQuery = await pool.execute(
          "SELECT occupied FROM Occupancy WHERE sensor_id = :sensorId ORDER BY timestamp DESC LIMIT 1",
          {"sensorId": sensorId});
      ResultSetRow data = occupancyQuery.rows.first;
      bool occupied = data.typedColByName<bool>("occupied")!;

      var reservedQuery = await pool.execute(
          "SELECT reserved FROM Sensors WHERE sensor_id = :sensorId",
          {"sensorId": sensorId});
      data = reservedQuery.rows.first;
      bool reserved = data.typedColByName<bool>("reserved")!;
      return (occupied | reserved);
    } catch (e) {
      return null;
    }
  }

  static Future<LatLng?> getSensorPositionById(int sensorId) async {
    try {
      var latLngQuery = await pool.execute(
          "SELECT (latitude, longitude) FROM Sensors WHERE sensor_id = :sensorId LIMIT 1",
          {"sensorId": sensorId});
      ResultSetRow data = latLngQuery.rows.first;
      double latitude = data.typedColByName<double>("latitude")!;
      double longitude = data.typedColByName<double>("longitude")!;
      return LatLng(latitude, longitude);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> setParkingSpotStatus(int sensorId, bool status) async {
    try {
      var res = await pool.execute(
          "UPDATE Sensors SET reserved = :status WHERE sensor_id = :sensorId LIMIT 1",
          {"status": status});
      return res.affectedRows.toInt() == 1 ? true : false;
    } catch (e) {
      return false;
    }
  }

  static Future<ParkingInfo?> getNearestAvailableParkingSpotWithinRange(
      double latitude, double longitude, double rangeKm) async {
    LatLongRangeLimits limits =
        LocationService.getPointRadiusKm(latitude, longitude, rangeKm);
    try {
      var result = await pool.execute(
          "SELECT * FROM Sensors WHERE latitude >= :minLat AND latitude <= :maxLat AND longitude >= :minLong AND longitude <= :maxLong",
          {
            "minLat": limits.minLat,
            "maxLat": limits.maxLat,
            "minLong": limits.minLong,
            "maxLong": limits.maxLong,
          });

      print(
          "Fetched Sensor SQL info within $rangeKm of ($latitude ; $longitude)");

      for (var row in result.rows) {
        int sensorId = row.typedColByName<int>("sensor_id")!;
        bool? status = await getSensorStatus(sensorId) ?? true;
        if (status == sensorStatusOccupied) {
          continue;
        }
        double lat = row.typedColByName<double>("latitude")!;
        double long = row.typedColByName<double>("longitude")!;
        int addressId = row.typedColByName<int>("address_id")!;
        int zoneId = row.typedColByName<int>("zone_id")!;

        LatLng position = LatLng(lat, long);

        Address address = await getAddressById(addressId);
        Zone zone = await getZoneById(zoneId);

        bool occupied = await getSensorStatus(sensorId) ?? false;

        return (ParkingInfo(sensorId, position.latitude, position.longitude,
            address, zone, occupied));
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
    return null;
  }

  static Future<Address> getAddressById(int addressId) async {
    if (_addresses[addressId] == null) {
      var result = await pool.execute(
          "SELECT * FROM Addresses WHERE address_id = :addressId",
          {"addressId": addressId});
      ResultSetRow data = result.rows.first;

      String street = data.typedColByName<String>("street")!;
      String city = data.typedColByName<String>("city")!;
      String region = data.typedColByName<String>("region")!;
      String country = data.typedColByName<String>("country")!;

      _addresses[addressId] = Address(street, city, region, country);
    }

    return _addresses[addressId]!;
  }

  static Future<Zone> getZoneById(int zoneId) async {
    if (_zones[zoneId] == null) {
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
      dayIds[DateTime.monday - 1] =
          data.typedColByName<int>("mon_schedule_id")!;
      dayIds[DateTime.tuesday - 1] =
          data.typedColByName<int>("tue_schedule_id")!;
      dayIds[DateTime.wednesday - 1] =
          data.typedColByName<int>("wed_schedule_id")!;
      dayIds[DateTime.thursday - 1] =
          data.typedColByName<int>("thu_schedule_id")!;
      dayIds[DateTime.friday - 1] =
          data.typedColByName<int>("fri_schedule_id")!;
      dayIds[DateTime.saturday - 1] =
          data.typedColByName<int>("sat_schedule_id")!;
      dayIds[DateTime.sunday - 1] =
          data.typedColByName<int>("sun_schedule_id")!;

      Schedule schedule = await SqlService.buildSchedule(dayIds);

      _zones[zoneId] =
          Zone(id, name, hourRate, dayRate, isPrivate, totalSpots, schedule);
    }

    return _zones[zoneId]!;
  }

  static Future<Schedule> buildSchedule(List<int?> ids) async {
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
        TimeOfDay startHour = SqlService.parseTimeOfDay(
            data.typedColByName<String>("start_hour")!);
        TimeOfDay stopHour = SqlService.parseTimeOfDay(
            data.typedColByName<String>("stop_hour")!);

        daySchedules[ids[i]] = DaySchedule(startHour, stopHour);
        result[i] = daySchedules[ids[i]]!;
      }
    }
    return Schedule(result);
  }

  static TimeOfDay parseTimeOfDay(String time) {
    return TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
  }

  static Future<List<Zone>?> getZones() async {
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

  static Future<String> addSensor(
      String sensorId, LatLng latLng, Address address, int zoneId) async {
    int addressId = await SqlService.getAddressId(address);

    if (addressId == -1) {
      print("Failed to obtain address");
      addressId = await SqlService.createAddress(address);
      for (int attempts = 0; attempts < 3 && addressId == -1; attempts++) {
        print("Fetching new address. Attempt $attempts");
        addressId = await SqlService.getAddressId(address);
      }
    }

    if (addressId == -1) {
      return "Failed creating new address";
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

      res = await pool.execute(
        "INSERT INTO `Occupancy` (`sensor_id`) VALUES (:sensor_id)",
        {
          "sensor_id": int.parse(sensorId),
        },
      );
      print(res.affectedRows);
    } catch (e) {
      return e.toString();
    }
    return "Sensor added successfully";
  }

  static Future<int> getAddressId(Address address) async {
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
    } catch (e) {
      if (!e.toString().contains('Bad state: No element')) {
        return -1;
      }
    }
    return id;
  }

  static Future<int> createAddress(Address address) async {
    int id = -1;
    try {
      print("Inserting new addrress.");
      var result = await pool.execute(
          "INSERT INTO `Addresses` (`street`, `city`, `region`, `country`) VALUES (:street, :city, :region, :country)",
          {
            "street": address.street ?? "",
            "city": address.city ?? "",
            "region": address.region ?? "",
            "country": address.country ?? "",
          });

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
      print("Failed inserting new addrress: ${e.toString()}");
      id = -1;
    }

    return id;
  }

  static Future<bool> getUserAdminStatus(String uid) async {
    try {
      var result =
          await pool.execute("SELECT is_admin FROM Users WHERE uid = :uid", {
        "uid": uid,
      });
      ResultSetRow data = result.rows.first;
      bool isAdmin = data.typedColByName<bool>("is_admin")!;
      return isAdmin;
    } catch (e) {
      // TODO: add user as non-admin if it doesn't exist
      return false;
    }
  }
}
