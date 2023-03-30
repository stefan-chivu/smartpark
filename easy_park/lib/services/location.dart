import 'package:easy_park/models/address.dart';
import 'package:geocoding/geocoding.dart' as geocodingpkg;
import 'package:location/location.dart';
import 'dart:math';

class LocationService {
  static final Location location = Location();

  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  static Future<void> init() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location service is turned off');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.error('Location permissions are denied');
      }
    }
  }

  static Future<LocationData> getCurrentLocation() async {
    return await location.getLocation();
  }

  static Stream<LocationData> locationStream() {
    return location.onLocationChanged;
  }

  static Future<Address> addressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<geocodingpkg.Placemark> placemarks =
          await geocodingpkg.placemarkFromCoordinates(latitude, longitude);
      Address address = Address(
          placemarks.first.street ?? '',
          placemarks.first.locality ?? '',
          placemarks.first.administrativeArea ?? '',
          placemarks.first.country ?? '');
      return address;
    } catch (e) {
      return Future.error(e.toString());
    }
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

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // in km

  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadius * c;

  return distance;
}

double _toRadians(double degree) {
  return degree * pi / 180;
}
