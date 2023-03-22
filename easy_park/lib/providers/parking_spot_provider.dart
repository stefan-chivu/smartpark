import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/screens/sensor/details.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

final spotProvider =
    FutureProvider.family<SpotListData, SpotProviderInput>((ref, input) async {
  final locationData = await LocationService.getCurrentLocation();
  input.position ??= LatLng(locationData.latitude!, locationData.longitude!);
  final parkingSpots = input.spots ??
      await SqlService.getParkingSpotsAroundPosition(
          input.position!.latitude, input.position!.longitude, 1);

  return SpotListData(
      location: locationData,
      searchPosition: input.position!,
      spots: parkingSpots);
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
        icon: getMarkerIcon(spot.state)));
  }

  return markers;
}

BitmapDescriptor getMarkerIcon(SpotState state) {
  switch (state) {
    case SpotState.occupied:
      return BitmapDescriptor.defaultMarker;
    case SpotState.free:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    case SpotState.reserved:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    case SpotState.freeingSoon:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    default:
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
  }
}

class SpotListData {
  LatLng searchPosition;
  List<ParkingInfo> spots;
  LocationData location;

  SpotListData(
      {required this.location,
      required this.spots,
      required this.searchPosition});
}

class SpotProviderInput {
  BuildContext? context;
  LatLng? position;
  double sensorRange;
  List<ParkingInfo>? spots;

  // TODO: some of these might not need the required param
  SpotProviderInput(
      {required this.context,
      required this.position,
      required this.sensorRange,
      required this.spots});
}
