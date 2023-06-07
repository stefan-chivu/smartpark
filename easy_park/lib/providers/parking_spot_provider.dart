import 'package:easy_park/models/spot_info.dart';
import 'package:easy_park/screens/sensor/details.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final spotProvider =
    FutureProvider.family<SpotListData, SpotProviderInput>((ref, input) async {
  final locationData = await Geolocator.getCurrentPosition();
  input.position ??= LatLng(locationData.latitude, locationData.longitude);
  final parkingSpots = input.spots ??
      await SqlService.getParkingSpotsAroundPosition(
          input.position!.latitude, input.position!.longitude, 1);

  if (input.context != null) {
    int spotNo = parkingSpots
        .where((element) => element.state != SpotState.occupied)
        .length;
    ScaffoldMessenger.of(input.context!).showSnackBar(SnackBar(
      duration: const Duration(seconds: 5),
      content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          "Found $spotNo spots!",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: AppMargins.XS,
        ),
        const Icon(
          Icons.local_parking_outlined,
          color: AppColors.emerald,
        ),
      ]),
      backgroundColor: AppColors.pineTree,
    ));
  }

  return SpotListData(
      location: locationData,
      searchPosition: input.position!,
      spots: parkingSpots);
});

Set<Marker> getMarkers(
    BuildContext context, List<SpotInfo>? spots, LatLng location) {
  if (spots == null) {
    return {};
  }

  Set<Marker> markers = {};
  for (SpotInfo spot in spots) {
    markers.add(Marker(
        markerId: MarkerId(spot.sensorId.toString()),
        position: LatLng(spot.latitude, spot.longitude), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Spot #${spot.sensorId}',
          snippet: 'Price: ${spot.zone.hourRate}${spot.zone.currency}/h',
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
  List<SpotInfo> spots;
  Position location;

  SpotListData(
      {required this.location,
      required this.spots,
      required this.searchPosition});
}

class SpotProviderInput {
  BuildContext? context;
  LatLng? position;
  double sensorRangeKm;
  List<SpotInfo>? spots;

  SpotProviderInput(
      {this.context, this.position, this.sensorRangeKm = 1, this.spots});
}
