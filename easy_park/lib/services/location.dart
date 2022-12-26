import 'package:easy_park/models/address.dart';
import 'package:geocoding/geocoding.dart' as geocodingpkg;
import 'package:location/location.dart' as locationpkg;

class LocationService {
  Future<locationpkg.LocationData> getCurrentLocation() async {
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

  Future<Address> addressFromLatLng(double latitude, double longitude) async {
    List<geocodingpkg.Placemark> placemarks =
        await geocodingpkg.placemarkFromCoordinates(latitude, longitude);

    Address address = Address(
        placemarks.first.street,
        placemarks.first.locality,
        placemarks.first.administrativeArea,
        placemarks.first.country);
    return address;
  }
}
