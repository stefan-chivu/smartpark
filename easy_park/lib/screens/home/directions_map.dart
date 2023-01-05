import 'dart:async';

import 'package:easy_park/providers/directions_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  final DirectionsInput providerInput = DirectionsInput.empty();

  MapScreen({super.key, required destination}) {
    providerInput.destination = destination;
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late GoogleMapController googleMapController;
  late Timer timer;

  @override
  void dispose() {
    googleMapController.dispose();
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
              initialCameraPosition:
                  CameraPosition(target: providerData.origin, zoom: 18),
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
                timer = Timer.periodic(
                  const Duration(seconds: 60),
                  (timer) {
                    widget.providerInput.destination = LatLng(
                        widget.providerInput.destination!.latitude,
                        widget.providerInput.destination!.longitude);
                    // ignore: unused_result
                    ref.refresh(directionsProvider(widget.providerInput));

                    controller.moveCamera(CameraUpdate.newLatLngBounds(
                        providerData.directions.bounds!, 20.0));
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
            )
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
