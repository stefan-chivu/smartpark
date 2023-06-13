import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/spot_info.dart';
import 'package:easy_park/providers/parking_spot_provider.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/places.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/loading_snack_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class _HomeState extends ConsumerState<Home> {
  SpotProviderInput providerInput = SpotProviderInput();
  bool showRefresh = false;
  LatLng? tmpPosition;
  final TextEditingController _controller = TextEditingController();
  GoogleMapController? _mapController;
  bool _enableMapGestures = true;

  @override
  void dispose() {
    super.dispose();
    if (_mapController != null) {
      _mapController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    providerInput.context = context;
    final providerData = ref.watch(spotProvider(providerInput));

    return providerData.when(data: (providerData) {
      return Scaffold(
          floatingActionButton: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: showRefresh ? 1.0 : 0.0,
            child: FloatingActionButton.extended(
              isExtended: true,
              backgroundColor: Colors.blueGrey,
              onPressed: () async {
                Address newAddress = await LocationService.addressFromLatLng(
                    tmpPosition!.latitude, tmpPosition!.longitude);
                if (mounted) {
                  showLoadingSnackBar(
                      context, "Finding parking spots around here...",
                      color: AppColors.blueGreen, durationSeconds: 2);
                }
                setState(() {
                  providerInput.context = context;
                  providerInput.position = tmpPosition;
                  providerInput.initialized = true;
                  showRefresh = false;
                  _controller.text = newAddress.toString();
                });
                ref.refresh(spotProvider(providerInput));
              },
              label: const Text("Search this area"),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterFloat,
          body: Stack(alignment: AlignmentDirectional.topStart, children: [
            GoogleMap(
              scrollGesturesEnabled: _enableMapGestures,
              zoomGesturesEnabled: _enableMapGestures,
              tiltGesturesEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(providerData.location.latitude,
                      providerData.location.longitude),
                  zoom: 18),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController!.setMapStyle(Constants.mapStyleString);
              },
              onCameraMoveStarted: () {
                if (_enableMapGestures) {
                  setState(() {
                    showRefresh = true;
                  });
                }
              },
              onCameraMove: (position) {
                setState(() {
                  tmpPosition = position.target;
                });
              },
              myLocationEnabled: true,
              markers: providerData.markers,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppMargins.S, vertical: AppMargins.L),
                child: TextField(
                  controller: _controller,
                  readOnly: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Search...",
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1), //<-- SEE HERE
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onTap: () async {
                    final sessionToken = const Uuid().v4();
                    final Suggestion? result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken: sessionToken),
                    );

                    if (result != null && result.description.isNotEmpty) {
                      bool found = false;
                      SpotInfo? closestSpot;
                      // route the user to the nearest sensor within a 330m, 660m, 990m range
                      for (double searchArea = 0.33;
                          searchArea < 1 && !found;
                          searchArea += 0.33) {
                        closestSpot = await SqlService
                            .getNearestAvailableParkingSpotWithinRange(
                                result.location!.latitude,
                                result.location!.longitude,
                                searchArea);
                        if (closestSpot != null) {
                          break;
                        }
                      }

                      if (_mapController != null && result.location != null) {
                        setState(() {
                          _controller.text = result.description;
                          _mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                  result.location!, 16.5));
                        });
                        if (closestSpot != null) {
                          setState(() {
                            _enableMapGestures = false;
                            showRefresh = false;
                          });

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: AppColors.blueGreen,
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Getting you to the nearest available spot',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: AppFontSizes.M),
                                    )
                                  ],
                                )));
                          }
                          providerInput.position = LatLng(
                              closestSpot.latitude, closestSpot.longitude);
                          ref.refresh(spotProvider(providerInput));
                          await Future.delayed(
                              const Duration(milliseconds: 3000));

                          setState(() {
                            providerInput.position = result.location!;
                            _mapController!.animateCamera(
                                CameraUpdate.newLatLng(LatLng(
                                    closestSpot!.latitude,
                                    closestSpot.longitude)));
                            _mapController!.showMarkerInfoWindow(
                                MarkerId(closestSpot.sensorId.toString()));
                            _enableMapGestures = true;
                          });
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: AppColors.sandyBrown,
                                content: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: const [
                                    Text(
                                      'No spots were found within 1km of the address you entered',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: AppFontSizes.M),
                                    )
                                  ],
                                )));
                          }
                        }
                      }
                    }
                  },
                )),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppMargins.S, vertical: AppMargins.L),
                child: Material(
                  shape: const CircleBorder(side: BorderSide.none),
                  elevation: 8,
                  child: Ink(
                    decoration: const ShapeDecoration(
                      color: AppColors.slateGray,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () async {
                        if (_mapController != null) {
                          Position userLocation =
                              await Geolocator.getCurrentPosition();
                          _mapController!.animateCamera(CameraUpdate.newLatLng(
                              LatLng(userLocation.latitude,
                                  userLocation.longitude)));
                        }
                      },
                      icon: const Icon(
                        Icons.my_location_rounded,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
          bottomNavigationBar: CustomNavBar(
              position: tmpPosition,
              spots: !showRefresh ? providerData.spots : null));
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
