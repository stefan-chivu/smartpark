import 'dart:math';

import 'package:easy_park/models/address.dart';
import 'package:geocoding/geocoding.dart' as geocodingpkg;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locationpkg;

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  static Future<locationpkg.LocationData> getCurrentLocation() async {
    locationpkg.Location location = locationpkg.Location();

    bool serviceEnabled;
    locationpkg.PermissionStatus permissionGranted;
    locationpkg.LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location service is turned off');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == locationpkg.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != locationpkg.PermissionStatus.granted) {
        return Future.error('Location permissions are denied');
      }
    }

    locationData = await location.getLocation();

    return locationData;
  }

  static Future<Address> addressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<geocodingpkg.Placemark> placemarks =
          await geocodingpkg.placemarkFromCoordinates(latitude, longitude);
      Address address = Address(
          placemarks.first.street,
          placemarks.first.locality,
          placemarks.first.administrativeArea,
          placemarks.first.country);
      return address;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  // Distance between two coordinates in kilometers
  static Future<double> distanceBetweenLatLng(
      double lat1, double lon1, double lat2, double lon2) async {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static LatLongRangeLimits getPointRadiusKm(
      double pointLat, double pointLong, double km) {
    return LatLongRangeLimits(
      minLat: pointLat - km * 0.008999,
      maxLat: pointLat + km * 0.008999,
      minLong: pointLong - km * 0.008999,
      maxLong: pointLat + km * 0.008999,
    );
  }
}

class LatLongRangeLimits {
  double minLat;
  double maxLat;
  double minLong;
  double maxLong;

  LatLongRangeLimits(
      {required this.minLat,
      required this.minLong,
      required this.maxLat,
      required this.maxLong});
}
