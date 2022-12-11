import 'dart:async';

import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/zone.dart';
import 'package:easy_park/screens/home/home.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/custom_button.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class AddSensor extends StatefulWidget {
  const AddSensor({super.key});

  @override
  State<AddSensor> createState() => _AddSensorState();
}

class _AddSensorState extends State<AddSensor> {
  final SqlService sqlService = SqlService();
  final _sensorIdFormKey = GlobalKey<FormState>();
  final TextEditingController _sensorIdController = TextEditingController();
  int? _zoneID;
  LocationInfo? _sensorPosition;
  Marker? _marker;

  Future<LocationInfo>? _positionFuture;
  Future<List<DropdownMenuItem<int>>>? _dropdownFuture;

  @override
  void initState() {
    super.initState();
    _positionFuture = _getLatLng();
    _dropdownFuture = _getZones();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _positionFuture = _getLatLng();
  }

  Future<LocationInfo> _getLatLng() async {
    print("Fetching current location data");
    LocationData data = await LocationService().getCurrentLocation();
    print("Location data acquired successfully");

    if ((data.latitude == null || data.longitude == null) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed fetching location data"),
        backgroundColor: AppColors.orangeRed,
      ));
      return Future.error('Fetching location data failed');
    }

    LatLng crtLatLng = LatLng(data.latitude!, data.longitude!);

    Address address =
        await _getAddress(crtLatLng.latitude, crtLatLng.longitude);

    return LocationInfo(crtLatLng, address);
  }

  Future<Address> _getAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    Address address = Address(
        placemarks.first.street,
        placemarks.first.locality,
        placemarks.first.administrativeArea,
        placemarks.first.country);
    return address;
  }

  Future<List<DropdownMenuItem<int>>> _getZones() async {
    print("Awaiting SQL zone information");
    List<Zone>? _zones = await sqlService.getZones();
    print("Fetched zone information");
    List<DropdownMenuItem<int>>? dropdownOptions = List.empty(growable: true);
    // dropdownOptions.add(defaultDropdownItem);
    if (_zones == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "No zones were fetched from the database",
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.orangeRed,
      ));
      return Future.error("Fetching sensor information failed");
    }

    for (Zone zone in _zones!) {
      dropdownOptions.add(DropdownMenuItem(
        value: zone.id,
        child: Text(
          zone.name,
          textAlign: TextAlign.center,
        ),
      ));
    }
    return dropdownOptions;
  }

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
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: Column(children: [
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
          FutureBuilder(
              future: _positionFuture,
              builder:
                  ((BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
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
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else if (snapshot.hasData) {
                      _sensorPosition ??= snapshot.data;
                      _marker = Marker(
                        draggable: true,
                        markerId: const MarkerId("crtLocation"),
                        position: _sensorPosition!.latLng,
                        onDragEnd: (value) {
                          _sensorPosition!.latLng = _marker!.position;
                        },
                      );
                      return Column(
                        children: [
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: GoogleMap(
                                  tiltGesturesEnabled: false,
                                  zoomGesturesEnabled: false,
                                  rotateGesturesEnabled: false,
                                  markers: {_marker!},
                                  mapType: MapType.hybrid,
                                  initialCameraPosition: CameraPosition(
                                      target: _sensorPosition!.latLng,
                                      zoom: 19),
                                  myLocationEnabled: true,
                                  onCameraIdle: () async {
                                    _sensorPosition!.address =
                                        await _getAddress(
                                            _sensorPosition!.latLng.latitude,
                                            _sensorPosition!.latLng.longitude);
                                    setState(() {});
                                  },
                                  onCameraMove: (position) async {
                                    _sensorPosition!.latLng = position.target;
                                    setState(() {});
                                  },
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(AppMargins.S),
                            child: Expanded(
                                child: Text(
                              _sensorPosition!.address.toString(),
                              textAlign: TextAlign.center,
                            )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppMargins.S),
                            child: Text(
                              "${_sensorPosition!.latLng.latitude.toStringAsFixed(5)},  ${_sensorPosition!.latLng.longitude.toStringAsFixed(5)}",
                            ),
                          ),
                        ],
                      );
                    }
                }
                return const Text("Error updating coordinates");
              })),
          FutureBuilder(
            future: _dropdownFuture,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
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
                default:
                  try {
                    return Padding(
                        padding: const EdgeInsets.all(AppMargins.M),
                        child: DropdownButton(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(AppFontSizes.XL)),
                          hint: const Text("Zone"),
                          isExpanded: true,
                          value: _zoneID,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: snapshot.data,
                          onChanged: (int? newValue) {
                            setState(() {
                              _zoneID = newValue!;
                            });
                          },
                        ));
                  } catch (e) {
                    return const CustomTextField(
                      label: "Zone",
                      enabled: false,
                    );
                  }
              }
            },
          ),
          Padding(
              padding: const EdgeInsets.all(AppMargins.M),
              child: CustomButton(
                  onPressed: () async {
                    if (_zoneID == null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a zone")));
                      return;
                    }
                    if (_sensorIdFormKey.currentState!.validate()) {
                      String result = await sqlService.addSensor(
                          _sensorIdController.text,
                          _sensorPosition!.latLng,
                          _sensorPosition!.address,
                          _zoneID!);
                      if (mounted) {
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
        ]));
  }
}

class LocationInfo {
  LocationInfo(this.latLng, this.address);

  LatLng latLng;
  Address address;

  @override
  String toString() => 'LocationInfo[$latLng, $address]';
}
