import 'package:easy_park/models/address.dart';
import 'package:geocoding/geocoding.dart' as geocodingpkg;
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  static Future<void> init() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
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
