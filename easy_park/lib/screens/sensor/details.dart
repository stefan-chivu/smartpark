import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class SpotDetails extends StatelessWidget {
  final ParkingInfo spot;

  const SpotDetails({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        Text(
          spot.address.toString(),
          style: const TextStyle(fontSize: AppFontSizes.XL),
        ),
        ListTile(
          leading: Icon(Icons.circle_rounded,
              color: spot.occupied ? Colors.red : Colors.green),
          title: const Text("State"),
          subtitle: Text(spot.occupied ? "Occupied" : "Free"),
        ),
        // TODO: Add optional zone name & info
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text("Timetable"),
          subtitle: Text(spot.zone.schedule.toString()),
        ),
        ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text("Price"),
          subtitle: (spot.zone.dayRate == null)
              ? Text("${spot.zone.hourRate}${spot.zone.currency}/h")
              : Text("${spot.zone.hourRate}${spot.zone.currency}/h\n"
                  "${spot.zone.dayRate}${spot.zone.currency}/day"),
        ),
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
      ],
    );
  }
}
