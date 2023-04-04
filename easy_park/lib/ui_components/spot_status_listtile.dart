import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/screens/spots/directions_map.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class SpotStatusListTile extends StatelessWidget {
  final SpotInfo spot;
  final LocationData? location;
  const SpotStatusListTile({super.key, required this.spot, this.location});

  @override
  Widget build(BuildContext context) {
    double? distance;
    if (location != null) {
      distance = calculateDistance(spot.latitude, spot.longitude,
          location!.latitude!, location!.longitude!);
    }
    Color spotColor;
    String spotStatus;
    IconData spotIcon;
    switch (spot.state) {
      case SpotState.free:
        spotColor = Colors.green;
        spotIcon = Icons.time_to_leave;
        spotStatus = 'Available';
        break;
      case SpotState.reserved:
        spotColor = Colors.orange;
        spotIcon = Icons.lock_clock_rounded;
        spotStatus = 'Reserved';
        break;
      case SpotState.freeingSoon:
        spotColor = Colors.purple;
        spotIcon = Icons.timer;
        spotStatus = 'Freeing soon';
        break;
      case SpotState.occupied:
        spotColor = Colors.red;
        spotIcon = Icons.event_busy;
        spotStatus = 'Occupied';
        break;
      default:
        spotColor = Colors.blue;
        spotIcon = Icons.question_mark_rounded;
        spotStatus = 'Unknown';
        break;
    }
    return ListTile(
      leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(spotIcon, color: spotColor)]),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        Text("Spot #${spot.sensorId}")
      ]),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spot.address.toString()),
          Row(children: [
            const Icon(Icons.attach_money),
            // const Text("Price"),
            Text(" ${spot.zone.hourRate}${spot.zone.currency}/h"),
            spot.zone.dayRate != null
                ? Text(" · ${spot.zone.dayRate}${spot.zone.currency}/day ")
                : Container(),
          ]),
          Row(
            children: [
              Text(
                spotStatus,
                style: TextStyle(color: spotColor),
              ),
              distance != null
                  ? Text(
                      " · ${distance.toStringAsFixed(2)} km away ",
                      style: const TextStyle(color: Colors.black),
                    )
                  : Container()
            ],
          ),
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
          if (spot.state == SpotState.free ||
              spot.state == SpotState.unknown ||
              spot.state == SpotState.freeingSoon)
            FloatingActionButton.extended(
              heroTag: UniqueKey(),
              isExtended: true,
              elevation: 0,
              backgroundColor: spotColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        destination: LatLng(spot.latitude, spot.longitude),
                        sensorId: spot.sensorId,
                      ),
                    ));
              },
              icon: const Icon(Icons.directions),
              label: const Text("Directions"),
            ),
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        ],
      ),
    );
  }
}
