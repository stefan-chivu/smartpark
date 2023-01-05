import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/providers/location_provider.dart';
import 'package:easy_park/screens/sensor/details.dart';
import 'package:easy_park/services/sql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final homePageProvider =
    FutureProvider.family<HomePageInformation, HomePageProviderInput>(
        (ref, input) async {
  final location = await ref.watch(locationProvider.future);
  input.position ??= location;
  final parkingSpots = await SqlService.getParkingSpotsAroundPosition(
      input.position!.latitude, input.position!.longitude, 1);

  // ignore: use_build_context_synchronously
  final markers =
      getMarkers(input.context!, parkingSpots.values.toList(), location);

  return HomePageInformation(position: input.position!, markers: markers);
});

Set<Marker> getMarkers(
    BuildContext context, List<ParkingInfo>? spots, LatLng location) {
  if (spots == null) {
    return {};
  }

  Set<Marker> markers = {};
  for (ParkingInfo spot in spots) {
    markers.add(Marker(
        markerId: MarkerId(spot.sensorId.toString()),
        position: LatLng(spot.latitude, spot.longitude), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Spot #${spot.sensorId}',
          snippet: 'Price: ${spot.zone.hourRate}RON/h',
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Wrap(children: [
                    SpotDetails(
                      spot: spot,
                      location: location,
                    )
                  ]);
                });
          },
        ),
        icon: getMarkerIcon(spot.occupied)));
  }

  return markers;
}

BitmapDescriptor getMarkerIcon(bool occupied) {
  return occupied
      ? BitmapDescriptor.defaultMarker
      : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
}

class HomePageInformation {
  LatLng position;
  Set<Marker> markers;

  HomePageInformation({required this.position, required this.markers});
}

class HomePageProviderInput {
  BuildContext? context;
  LatLng? position;
  double sensorRange;

  HomePageProviderInput(
      {required this.context,
      required this.position,
      required this.sensorRange});
}
