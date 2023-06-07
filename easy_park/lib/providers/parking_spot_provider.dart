import 'dart:ui';

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

  if (input.context != null && input.initialized != null) {
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

  Set<Marker> markers =
      await getMarkers(input.context!, parkingSpots, input.position!);

  return SpotListData(
      location: locationData,
      searchPosition: input.position!,
      spots: parkingSpots,
      markers: markers);
});

Future<Set<Marker>> getMarkers(
    BuildContext context, List<SpotInfo>? spots, LatLng location) async {
  if (spots == null) {
    return {};
  }

  Set<Marker> markers = {};
  for (SpotInfo spot in spots) {
    BitmapDescriptor icon = await getMarkerIcon(spot);
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
        icon: icon));
  }

  return markers;
}

Future<BitmapDescriptor> getMarkerIcon(SpotInfo spot) async {
  IconData iconData = Icons.local_parking_rounded;
  if (spot.isElectric) {
    iconData = Icons.electrical_services_rounded;
  }
  Color iconColor;
  switch (spot.state) {
    case SpotState.occupied:
      iconColor = AppColors.orangeRed;
      break;
    case SpotState.free:
      iconColor = AppColors.emerald;
      break;
    case SpotState.reserved:
      iconColor = AppColors.sandyBrown;
      break;
    case SpotState.freeingSoon:
      iconColor = Colors.purple[600]!;
      break;
    default:
      iconColor = Colors.blue[800]!;
      break;
  }

  final pictureRecorder = PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final textPainter = TextPainter(textDirection: TextDirection.ltr);
  final iconStr = String.fromCharCode(iconData.codePoint);
  textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: 96.0,
        fontFamily: iconData.fontFamily,
        color: iconColor,
      ));
  textPainter.layout();
  textPainter.paint(canvas, const Offset(0.0, 0.0));
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(96, 96);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}

class SpotListData {
  LatLng searchPosition;
  List<SpotInfo> spots;
  Position location;
  Set<Marker> markers;

  SpotListData(
      {required this.location,
      required this.spots,
      required this.searchPosition,
      required this.markers});
}

class SpotProviderInput {
  BuildContext? context;
  LatLng? position;
  double sensorRangeKm;
  List<SpotInfo>? spots;
  bool? initialized = false;

  SpotProviderInput(
      {this.context,
      this.position,
      this.sensorRangeKm = 1,
      this.spots,
      this.initialized});
}
