// ignore_for_file: avoid_print

import 'dart:async';

import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/day_schedule.dart';
import 'package:easy_park/models/isar_car.dart';
import 'package:easy_park/models/isar_user.dart';
import 'package:easy_park/models/parking_history.dart';
import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/models/schedule.dart';
import 'package:easy_park/models/zone.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/isar.dart';
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

  static Future<List<SpotInfo>> getParkingSpotsAroundPosition(
      double latitude, double longitude, double rangeKm) async {
    List<SpotInfo> parkingInfo = [];
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
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));

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

        SpotState spotState = await getSensorStatus(sensorId);

        parkingInfo.add((SpotInfo(sensorId, position.latitude,
            position.longitude, address, zone, spotState)));
      }
    } catch (e) {
      print(e.toString());
    }
    return parkingInfo;
  }

  static Future<SpotState> getSensorStatus(int sensorId) async {
    print("Fetching sensor $sensorId status");
    try {
      var occupancyQuery = await pool.execute(
          "SELECT occupied FROM Occupancy WHERE sensor_id = :sensorId ORDER BY timestamp DESC LIMIT 1",
          {
            "sensorId": sensorId
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      ResultSetRow data = occupancyQuery.rows.first;
      bool occupied = data.typedColByName<bool>("occupied")!;

      var reservedQuery = await pool.execute(
          "SELECT * FROM Reservations WHERE spot_id = :sensorId", {
        "sensorId": sensorId
      }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));

      if (occupied) {
        return SpotState.occupied;
      }

      if (reservedQuery.rows.isNotEmpty) {
        return SpotState.reserved;
      }

      return SpotState.free;
    } catch (e) {
      return SpotState.unknown;
    }
  }

  static Future<LatLng?> getSensorPositionById(int sensorId) async {
    try {
      var latLngQuery = await pool.execute(
          "SELECT (latitude, longitude) FROM Sensors WHERE sensor_id = :sensorId LIMIT 1",
          {
            "sensorId": sensorId
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
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
          {
            "status": status
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      return res.affectedRows.toInt() == 1 ? true : false;
    } catch (e) {
      return false;
    }
  }

  static Future<SpotInfo?> getNearestAvailableParkingSpotWithinRange(
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
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));

      print(
          "Fetched Sensor SQL info within $rangeKm of ($latitude ; $longitude)");

      for (var row in result.rows) {
        int sensorId = row.typedColByName<int>("sensor_id")!;
        SpotState spotState = await getSensorStatus(sensorId);
        if (spotState != SpotState.free) {
          continue;
        }
        double lat = row.typedColByName<double>("latitude")!;
        double long = row.typedColByName<double>("longitude")!;
        int addressId = row.typedColByName<int>("address_id")!;
        int zoneId = row.typedColByName<int>("zone_id")!;

        LatLng position = LatLng(lat, long);

        Address address = await getAddressById(addressId);
        Zone zone = await getZoneById(zoneId);

        return (SpotInfo(sensorId, position.latitude, position.longitude,
            address, zone, spotState));
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
          "SELECT * FROM Addresses WHERE address_id = :addressId", {
        "addressId": addressId
      }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
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
          "SELECT * FROM Zones WHERE zone_id = :zoneId", {
        "zoneId": zoneId
      }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      ResultSetRow data = zoneQuery.rows.first;

      int id = data.typedColByName<int>("zone_id")!;
      String name = data.typedColByName<String>("zone_name")!;
      double hourRate = data.typedColByName<double>("hour_rate")!;
      double? dayRate = data.typedColByName<double>("day_rate");
      String currency = data.typedColByName<String>("currency")!;
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

      _zones[zoneId] = Zone(id, name, hourRate, dayRate, currency, isPrivate,
          totalSpots, schedule);
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
            "SELECT * FROM Schedules WHERE schedule_id = :id", {
          "id": ids[i]
        }).timeout(Constants.sqlTimeoutDuration,
            onTimeout: () =>
                throw TimeoutException(Constants.sqlTimeoutMessage));
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
      var zonesQuery = await pool.execute("SELECT * FROM Zones").timeout(
          Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      for (var row in zonesQuery.rows) {
        int id = row.typedColByName<int>("zone_id")!;
        String name = row.typedColByName<String>("zone_name")!;
        double hourRate = row.typedColByName<double>("hour_rate")!;
        double? dayRate = row.typedColByName<double>("day_rate");
        String currency = row.typedColByName<String>("currency")!;
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

        zones.add(Zone(id, name, hourRate, dayRate, currency, isPrivate,
            totalSpots, schedule));
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
      ).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      print(res.affectedRows);

      res = await pool.execute(
        "INSERT INTO `Occupancy` (`sensor_id`) VALUES (:sensor_id)",
        {
          "sensor_id": int.parse(sensorId),
        },
      ).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
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
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
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
            "street": address.street,
            "city": address.city,
            "region": address.region,
            "country": address.country,
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));

      result = await pool.execute(
          "SELECT address_id FROM `Addresses` WHERE `street` = ':street' AND `city` = ':city' AND `region` = ':region' AND `country` = ':country' ",
          {
            "street": address.street,
            "city": address.city,
            "region": address.region,
            "country": address.country,
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      ResultSetRow data = result.rows.first;
      id = data.typedColByName<int>("address_id")!;
    } catch (e) {
      print("Failed inserting new addrress: ${e.toString()}");
      id = -1;
    }

    return id;
  }

  static Future<IsarUser?> getUser(String uid, String email) async {
    try {
      var result = await pool.execute("SELECT * FROM Users WHERE uid = :uid", {
        "uid": uid,
      }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      ResultSetRow data = result.rows.first;
      bool isAdmin = data.typedColByName<bool>("is_admin")!;
      bool onboardingComplete =
          data.typedColByName<bool>("onboarding_complete")!;
      String email = data.typedColByName<String>("email")!;
      String firstName = data.typedColByName<String>("first_name") ?? '';
      String lastName = data.typedColByName<String>("last_name") ?? '';
      String homeAddress = data.typedColByName<String>("home_address") ?? '';
      String workAddress = data.typedColByName<String>("work_address") ?? '';
      return IsarUser(
          uid: uid,
          email: email,
          isAdmin: isAdmin,
          firstName: firstName,
          lastName: lastName,
          homeAddress: homeAddress,
          workAddress: workAddress,
          onboardingComplete: onboardingComplete);
    } catch (e) {
      return null;
    }
  }

  static Future<void> addUserToDatabase(
      String uid,
      String email,
      bool isAdmin,
      String firstName,
      String lastName,
      String licensePlate,
      String homeAddress,
      String workAddress) async {
    await pool.execute(
        "INSERT INTO `Users` (`uid`, `email`, `is_admin`, `first_name`, `last_name`, `license_plate`, `home_address`, `work_address`) VALUES (:uid, :email, :is_admin, :first_name, :last_name, :license_plate, :home_address, :work_address)",
        {
          "uid": uid,
          "email": email,
          "is_admin": isAdmin,
          "first_name": firstName,
          "last_name": lastName,
          "license_plate": licensePlate,
          "home_address": homeAddress,
          "work_address": workAddress,
        }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
  }

  static Future<List<IsarCar>?> getUserCars(String uid) async {
    List<IsarCar> cars = [];

    try {
      var result = await pool.execute(
          "SELECT car_id, license_plate, is_electric FROM `Cars` WHERE owner = :uid",
          {
            "uid": uid,
          }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
      for (ResultSetRow row in result.rows) {
        int? carId = row.typedColByName<int>("car_id");
        String licensePlate = row.typedColByName<String>("license_plate") ?? '';
        bool isElectric = row.typedColByName<bool>("is_electric")!;
        cars.add(IsarCar(
            carId: carId,
            ownerUid: uid,
            licensePlate: licensePlate,
            isElectric: isElectric));
      }
    } catch (e) {
      return null;
    }
    return cars;
  }

  static Future<void> reserveSpot(int spotId) async {
    await pool.execute(
        "INSERT INTO `Reservations` (`spot_id`, `reserved_by`) VALUES (:spot_id, :uid)",
        {
          "spot_id": spotId,
          "uid": IsarService.isarUser.uid,
        }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
  }

  static Future<void> clearSpotReservation(int spotId) async {
    await pool.execute(
        "DELETE FROM `Reservations` WHERE `spot_id` = :spot_id", {
      "spot_id": spotId,
      "uid": IsarService.isarUser.uid,
    }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
  }

  static Future<void> markOnboardingCompleted() async {
    await IsarService.markOnboardingCompleted();
    IsarUser isarUser = IsarService.isarUser;

    await pool.execute(
        "UPDATE `Users` SET onboarding_complete = :onboarding_complete WHERE uid = :uid LIMIT 1",
        {
          "uid": isarUser.uid,
          "onboarding_complete": isarUser.onboardingComplete
        }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
  }

  static Future<void> pushLocalUserData() async {
    IsarUser isarUser = IsarService.isarUser;
    await pool.execute(
        "UPDATE `Users` SET first_name = :first_name WHERE uid = :uid LIMIT 1",
        {
          "uid": isarUser.uid,
          "first_name": isarUser.firstName
        }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
    await pool.execute(
        "UPDATE `Users` SET last_name = :last_name WHERE uid = :uid LIMIT 1", {
      "uid": isarUser.uid,
      "last_name": isarUser.lastName
    }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
    await pool.execute(
        "UPDATE `Users` SET home_address = :home_address WHERE uid = :uid LIMIT 1",
        {
          "uid": isarUser.uid,
          "home_address": isarUser.homeAddress
        }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
    await pool.execute(
        "UPDATE `Users` SET work_address = :work_address WHERE uid = :uid LIMIT 1",
        {
          "uid": isarUser.uid,
          "work_address": isarUser.workAddress
        }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
  }

  static Future<void> addUserCar(IsarCar car) async {
    var result = await pool.execute(
        "SELECT owner FROM `Cars` WHERE license_plate = :license_plate", {
      "license_plate": car.licensePlate,
    }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
    if (result.rows.isNotEmpty) {
      String ownerUid = result.rows.first.typedColByName<String>("owner") ?? '';
      if (car.ownerUid == ownerUid) {
        throw Exception('You have already added this car');
      } else {
        throw Exception('Someone else has already claimed this vehicle');
      }
    } else {
      await pool.execute(
        "INSERT INTO `Cars` (`license_plate`, `owner`, `is_electric`) VALUES (:license_plate, :owner, :is_electric)",
        {
          "license_plate": car.licensePlate.toUpperCase(),
          "owner": car.ownerUid,
          "is_electric": car.isElectric,
        },
      ).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
    }

    await IsarService.addUserCar(car);
  }

  static Future<void> updateUserCar(IsarCar car) async {}

  static Future<void> deleteUserCar(IsarCar car) async {
    await pool.execute(
        "DELETE FROM `Cars` WHERE license_plate = :license_plate AND owner = :owner",
        {
          "owner": car.ownerUid,
          "license_plate": car.licensePlate,
        }).timeout(Constants.sqlTimeoutDuration,
        onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));
    await IsarService.deleteUserCar(car);
  }

  static Future<List<ParkingPayment>> getUserParkingHistory() async {
    List<ParkingPayment> parkingHistoryList = [];
    List<IsarCar> cars = await getUserCars(IsarService.isarUser.uid) ?? [];

    for (IsarCar car in cars) {
      if (car.carId == null) {
        car.carId = await getCarIdByLicensePlate(car.licensePlate);
        if (car.carId == null) {
          // This case means the car is not added in SQL
          // so an error might have occured somewhere
          continue;
        }
      }

      var result = await pool.execute(
          "SELECT * FROM `Payments` WHERE car_id = :car_id",
          {"car_id": car.carId});

      for (ResultSetRow row in result.rows) {
        int paymentId = row.typedColByName<int>('payment_id')!;
        int sensorId = row.typedColByName<int>('sensor_id')!;
        double totalSum = row.typedColByName<double>('total_sum')!;
        String timestamp = row.typedColByName<String>('timestamp')!;
        String parkingStart = row.typedColByName<String>('parking_start')!;
        String parkingEnd = row.typedColByName<String>('parking_end')!;

        SpotInfo? spot = await getSpotById(sensorId, fetchState: false);
        if (spot != null) {
          parkingHistoryList.add(ParkingPayment(
              id: paymentId,
              spot: spot,
              car: car,
              totalSum: totalSum,
              timestamp: DateTime.parse(timestamp),
              parkingStart: DateTime.parse(parkingStart),
              parkingEnd: DateTime.parse(parkingEnd)));
        }
      }
    }

    return parkingHistoryList;
  }

  static Future<int?> getCarIdByLicensePlate(String licensePlate) async {
    try {
      var result = await pool.execute(
          "SELECT car_id FROM `Cars` WHERE license_plate = :license_plate",
          {"license_plate": licensePlate});
      return result.rows.first.typedColByName<int>('car_id');
    } catch (e) {
      return null;
    }
  }

  static Future<SpotInfo?> getSpotById(int sensorId,
      {bool fetchState = true}) async {
    try {
      var result = await pool.execute(
          "SELECT * FROM Sensors WHERE sensor_id = :sensor_id", {
        "sensor_id": sensorId,
      }).timeout(Constants.sqlTimeoutDuration,
          onTimeout: () => throw TimeoutException(Constants.sqlTimeoutMessage));

      var row = result.rows.first;
      double lat = row.typedColByName<double>("latitude")!;
      double long = row.typedColByName<double>("longitude")!;
      int addressId = row.typedColByName<int>("address_id")!;
      int zoneId = row.typedColByName<int>("zone_id")!;

      LatLng position = LatLng(lat, long);

      Address address = await getAddressById(addressId);
      Zone zone = await getZoneById(zoneId);

      SpotState spotState =
          fetchState ? await getSensorStatus(sensorId) : SpotState.unknown;

      return ((SpotInfo(sensorId, position.latitude, position.longitude,
          address, zone, spotState)));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
