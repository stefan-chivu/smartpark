import 'dart:async';

import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/zone.dart';
import 'package:easy_park/providers/add_spot_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/screens/home/home.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_button.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddSensor extends ConsumerStatefulWidget {
  const AddSensor({super.key});

  @override
  ConsumerState<AddSensor> createState() => _AddSensorState();
}

class _AddSensorState extends ConsumerState<AddSensor> {
  final _sensorIdFormKey = GlobalKey<FormState>();
  final TextEditingController _sensorIdController = TextEditingController();
  int? _zoneID;
  LatLng? _sensorPosition;
  Address? _sensorAddress;
  Marker? _marker;
  bool isWaiting = false;
  List<DropdownMenuItem<int>> dropdownOptions = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    final providerData = ref.watch(addSensorProvider);

    return providerData.when(data: (providerData) {
      if (providerData.zones.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "No zones were fetched from the database",
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.orangeRed,
        ));
      }

      for (Zone zone in providerData.zones) {
        setState(() {
          dropdownOptions.add(DropdownMenuItem(
            value: zone.id,
            child: Text(
              zone.name,
              textAlign: TextAlign.center,
            ),
          ));
        });
      }

      _marker = Marker(
        draggable: true,
        markerId: const MarkerId("crtLocation"),
        position: _sensorPosition!,
        onDragEnd: (value) {
          _sensorPosition = _marker!.position;
        },
      );

      return Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: AppMargins.XXL,
            ),
            Padding(
              padding: const EdgeInsets.all(AppMargins.S),
              child: Form(
                key: _sensorIdFormKey,
                child: CustomTextField(
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  label: "Sensor ID",
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "An ID is required";
                    }
                    // TODO: Only allow int values
                    // Return null if the entered sensor is valid
                    return null;
                  },
                  controller: _sensorIdController,
                ),
              ),
            ),
            // TODO: replace FutureBuilder logic with FutureProvider
            Column(
              children: [
                Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: GoogleMap(
                        tiltGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        markers: {_marker!},
                        mapType: MapType.hybrid,
                        initialCameraPosition:
                            CameraPosition(target: _sensorPosition!, zoom: 19),
                        myLocationEnabled: true,
                        onCameraIdle: () async {
                          try {
                            _sensorAddress =
                                await LocationService.addressFromLatLng(
                                    _sensorPosition!.latitude,
                                    _sensorPosition!.longitude);
                            setState(() {});
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppColors.orangeRed,
                              ));
                            }
                          }
                        },
                        onCameraMove: (position) async {
                          _sensorPosition = position.target;
                          setState(() {});
                        },
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(AppMargins.S),
                  child: Expanded(
                      child: Text(
                    _sensorAddress.toString(),
                    textAlign: TextAlign.center,
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppMargins.S),
                  child: Text(
                    "${_sensorPosition!.latitude.toStringAsFixed(5)},  ${_sensorPosition!.longitude.toStringAsFixed(5)}",
                  ),
                ),
              ],
            ),
            Padding(
                padding: const EdgeInsets.all(AppMargins.M),
                child: DropdownButton(
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppFontSizes.XL)),
                  hint: const Text("Zone"),
                  isExpanded: true,
                  value: _zoneID,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: dropdownOptions,
                  onChanged: (int? newValue) {
                    setState(() {
                      _zoneID = newValue!;
                    });
                  },
                )),

            Padding(
                padding: const EdgeInsets.all(AppMargins.M),
                child: CustomButton(
                    onPressed: () async {
                      if (_zoneID == null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please select a zone")));
                        return;
                      }
                      if (_sensorIdFormKey.currentState!.validate()) {
                        setState(() {
                          isWaiting = true;
                        });
                        String result = await SqlService.addSensor(
                            _sensorIdController.text,
                            _sensorPosition!,
                            _sensorAddress!,
                            _zoneID!);
                        if (mounted) {
                          setState(() {
                            isWaiting = false;
                          });
                          if (!result.contains("success")) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(result)));
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(result)));
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Home()),
                            );
                          }
                        }
                      }
                    },
                    text: "Add Sensor")),
          ]),
        ),
        bottomNavigationBar: const CustomNavBar(),
      );
    }, error: ((error, stackTrace) {
      return ErrorPage(errorMsg: 'Error: ${error.toString()}');
    }), loading: () {
      return Container(
        color: Colors.white,
        child: const Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    });
  }
}
