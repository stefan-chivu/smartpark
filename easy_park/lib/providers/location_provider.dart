import 'package:easy_park/services/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final locationProvider = FutureProvider<LatLng>((ref) async {
  final location = await LocationService.getCurrentLocation();
  return LatLng(location.latitude!, location.longitude!);
});
