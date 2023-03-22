import 'dart:async';

import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/providers/directions_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  DirectionsInput providerInput = DirectionsInput.empty();

  MapScreen({super.key, required LatLng destination, required int sensorId}) {
    providerInput.destination = destination;
    providerInput.sensorId = sensorId;
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late GoogleMapController googleMapController;
  late Timer timer;
  bool _timerOpsCompleted = true;

  @override
  void dispose() {
    googleMapController.dispose();
    // TODO: Cancel reservation here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directionData = ref.watch(directionsProvider(widget.providerInput));

    return directionData.when(data: (providerData) {
      return Scaffold(
          appBar: const CustomAppBar(showHome: true),
          body: Stack(alignment: Alignment.center, children: [
            GoogleMap(
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: widget.providerInput.destination!, zoom: 18),
              // myLocationEnabled: true,
              markers: {
                Marker(
                    markerId: const MarkerId("destination"),
                    position: providerData.destination,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure)),
                Marker(
                    markerId: const MarkerId("origin"),
                    position: providerData.origin,
                    icon: providerData.bitmapIcon)
              },
              polylines: providerData.directions.polylines,
              cameraTargetBounds:
                  CameraTargetBounds(providerData.directions.bounds),
              onMapCreated: (controller) {
                googleMapController = controller;
                Timer(const Duration(milliseconds: 500), () async {
                  controller.animateCamera(CameraUpdate.newLatLngBounds(
                      providerData.directions.bounds!, 20.0));
                });
                // TODO: find alternative to polling
                timer = Timer.periodic(
                  const Duration(seconds: 15),
                  (timer) async {
                    if (_timerOpsCompleted) {
                      setState(() {
                        _timerOpsCompleted = false;
                      });

                      // TODO: check occupied by uid
                      SpotState status = await SqlService.getSensorStatus(
                          widget.providerInput.sensorId!);

                      if (status == SpotState.occupied) {
                        bool found = false;
                        ParkingInfo? newSensor;
                        // if the sensor that the user was currently going to gets occupied,
                        // route the user to the nearest sensor within a 330m, 660m, 990m range
                        for (double searchArea = 0.33;
                            searchArea < 1 && !found;
                            searchArea += 0.33) {
                          newSensor = await SqlService
                              .getNearestAvailableParkingSpotWithinRange(
                                  widget.providerInput.destination!.latitude,
                                  widget.providerInput.destination!.longitude,
                                  searchArea);
                          if (newSensor != null) {
                            break;
                          }
                        }

                        if (newSensor == null && mounted) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: ((context) {
                            return const ErrorPage(
                              errorMsg:
                                  "Uh oh! The spot you were going to got occupied and we couldn't find another one within 1km",
                            );
                          })));
                        } else {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Parking spot occupied!'),
                                  content: const Text(
                                      'The spot you were going to got occupied. Luckily, we found another one! Shall we go there?'),
                                  actions: [
                                    // The "Yes" button
                                    TextButton(
                                        onPressed: () async {
                                          setState(() {
                                            widget.providerInput =
                                                DirectionsInput(
                                                    sensorId:
                                                        newSensor!.sensorId,
                                                    destination: LatLng(
                                                        newSensor.latitude,
                                                        newSensor.longitude));
                                            // .sensorId =
                                            //     newSensor!.sensorId;
                                            // widget.providerInput.destination =
                                            //     LatLng(newSensor.latitude,
                                            //         newSensor.longitude);
                                          });
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Yes')),
                                    TextButton(
                                        onPressed: () {
                                          // TODO: push instead of double pop
                                          // Return to main page
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'))
                                  ],
                                );
                              });
                        }
                      }

                      print("refresh");
                      // TODO: find alternative to polling Directions API
                      // ignore: unused_result
                      ref.refresh(directionsProvider(widget.providerInput));

                      controller.moveCamera(CameraUpdate.newLatLngBounds(
                          providerData.directions.bounds!, 20.0));
                      setState(() {
                        _timerOpsCompleted = true;
                      });
                    } else {
                      print("Timer not completed");
                    }
                  },
                );
              },
            ),
            Positioned(
              top: 20.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                decoration: BoxDecoration(
                    color: AppColors.pineTree,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.pineTree,
                          offset: Offset(0, 2),
                          blurRadius: 6.0)
                    ]),
                child: Text(
                  '${providerData.directions.totalDistance}, ${providerData.directions.totalDuration}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            //TODO: remove if not necessary for
            // debugging purposes anymore
            // Positioned(
            //   bottom: 20.0,
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
            //     decoration: BoxDecoration(
            //         color: AppColors.pineTree,
            //         borderRadius: BorderRadius.circular(20.0),
            //         boxShadow: const [
            //           BoxShadow(
            //               color: AppColors.pineTree,
            //               offset: Offset(0, 2),
            //               blurRadius: 6.0)
            //         ]),
            //     child: Text(
            //       '${widget.providerInput.sensorId}: ${widget.providerInput.destination.toString()}',
            //       style: const TextStyle(color: Colors.white),
            //     ),
            //   ),
            // )
          ]));
    }, error: ((error, stackTrace) {
      return Scaffold(body: ErrorPage(errorMsg: 'Error: ${error.toString()}'));
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
