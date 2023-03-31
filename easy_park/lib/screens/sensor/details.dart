import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/ui_components/spot_status_listtile.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SpotDetails extends StatelessWidget {
  final ParkingInfo spot;
  final LatLng location;

  const SpotDetails({super.key, required this.spot, required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        SpotStatusListTile(
          spot: spot,
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text("Timetable"),
          subtitle: Text(spot.zone.schedule.toString()),
        ),
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
      ],
    );
  }
}
