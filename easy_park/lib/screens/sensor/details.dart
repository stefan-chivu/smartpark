import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class SensorDetails extends StatefulWidget {
  final ParkingInfo spot;
  const SensorDetails({super.key, required this.spot});

  @override
  State<SensorDetails> createState() => _SensorDetailsState();
}

class _SensorDetailsState extends State<SensorDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(showHome: true),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          onPressed: () {},
          child: const Icon(
            Icons.refresh,
          ),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Center(
            child: Image.asset(
              "assets/images/roadmap.png",
              width: 250,
            ),
          ),
          Text(
            "Spot no. ${widget.spot.sensorId}",
            style: TextStyle(fontSize: AppFontSizes.XL),
          ),
          ListTile(
            title: const Text("State"),
            subtitle: Text(widget.spot.occupied ? "Occupied" : "Free"),
          )
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        bottomNavigationBar: const CustomNavBar());
  }
}
