import 'dart:async';

import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox/flutter_mapbox.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // TODO: check unused vars
  String? _instruction = "";
  String? _instructionDistance =
      ""; // TODO make this actually display the distance to the next step
  MapBoxNavigation? _directions;
  MapBoxOptions? _options;

  bool _isMultipleStop = false;
  double _distanceRemaining = -1;
  double _durationRemaining = -1;
  MapBoxNavigationViewController? _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  dynamic prevEvent;
  late Position origin;
  late LatLng destination;
  late SpotInfo spot;

  late Timer timer;
  bool _timerOpsCompleted = true;

  @override
  void initState() {
    super.initState();
    Future((() => initialize()));
  }

  Future<void> initialize() async {
    try {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;

      origin = arguments['origin'];
      destination = arguments['destination'];
      spot = arguments['spot'];
      if (!mounted) return;

      _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
      var options = MapBoxOptions(
          initialLatitude: origin.latitude,
          initialLongitude: origin.longitude,
          // avoid: ["motorway", "toll"],
          zoom: 13.0,
          tilt: 0.0,
          bearing: 0.0,
          enableRefresh: true,
          alternatives: true,
          voiceInstructionsEnabled: true,
          bannerInstructionsEnabled: true,
          allowsUTurnAtWayPoints: true,
          mode: MapBoxNavigationMode.drivingWithTraffic,
          units: VoiceUnits.metric,
          simulateRoute: false,
          longPressDestinationEnabled: false,
          // pois: _pois,
          mapStyleUrlDay: "mapbox://styles/mapbox/navigation-day-v1",
          mapStyleUrlNight: "mapbox://styles/mapbox/navigation-night-v1",
          language: "en");

      setState(() {
        _options = options;
      });
      await SqlService.reserveSpot(spot.sensorId);
    } catch (err) {
      print(err);
    }
  }

  // TODO: handle app closing scenario
  @override
  void dispose() {
    super.dispose();
    SqlService.clearSpotReservation(spot.sensorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible: _isNavigating,
          child: SizedBox.fromSize(
              size: const Size.fromHeight(AppMargins.XXXL),
              child: Container(
                color: AppColors.pineTree,
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _instructionDistance != null
                      ? Text(
                          _instructionDistance!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppFontSizes.XL,
                              color: Colors.white),
                        )
                      : const Text(""),
                  Text(
                    _instruction ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSizes.XL,
                        color: AppColors.blueGreen),
                  ),
                  const SizedBox(
                    height: AppMargins.M,
                  ),
                ]),
              )),
        ),
        if (_options != null)
          Expanded(
            child: MapBoxNavigationView(
                options: _options,
                onRouteEvent: _onEmbeddedRouteEvent,
                onCreated: (MapBoxNavigationViewController controller) async {
                  _controller = controller;
                  _controller!.initialize();
                  _controller!.buildRoute(wayPoints: [
                    WayPoint(
                        name: 'Origin',
                        latitude: origin.latitude,
                        longitude: origin.longitude),
                    WayPoint(
                        name: 'Destination',
                        latitude: destination.latitude,
                        longitude: destination.longitude)
                  ]);
                }),
          )
        else
          const Center(child: CircularProgressIndicator()),
        Visibility(
          visible: !_isNavigating,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_controller != null) {
                _controller!.startNavigation(options: _options);
              }

              timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
                if (_timerOpsCompleted) {
                  setState(() {
                    _timerOpsCompleted = false;
                  });
                  SpotState status =
                      await SqlService.getSensorStatus(spot.sensorId);

                  if (status == SpotState.occupied) {
                    timer.cancel();
                    SqlService.clearSpotReservation(spot.sensorId);

                    bool found = false;
                    SpotInfo? newSpot;
                    // if the sensor that the user was currently going to gets occupied,
                    // route the user to the nearest sensor within a 330m, 660m, 990m range
                    for (double searchArea = 0.33;
                        searchArea < 1 && !found;
                        searchArea += 0.33) {
                      newSpot = await SqlService
                          .getNearestAvailableParkingSpotWithinRange(
                              destination.latitude,
                              destination.longitude,
                              searchArea);
                      if (newSpot != null) {
                        break;
                      }
                    }

                    if (newSpot == null && mounted) {
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
                                      Position crtLocation =
                                          await Geolocator.getCurrentPosition();
                                      setState(() {
                                        destination = LatLng(newSpot!.latitude,
                                            newSpot.longitude);
                                        spot = newSpot;
                                        _controller!.finishNavigation();

                                        setState(() {
                                          _isNavigating = false;
                                          origin = crtLocation;
                                        });
                                        _controller!.buildRoute(wayPoints: [
                                          WayPoint(
                                              name: 'Origin',
                                              latitude: origin.latitude,
                                              longitude: origin.longitude),
                                          WayPoint(
                                              name: 'Destination',
                                              latitude: destination.latitude,
                                              longitude: destination.longitude)
                                        ]);
                                      });
                                      await SqlService.reserveSpot(
                                          spot.sensorId);

                                      // Close the dialog
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Yes')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/', (route) => false);
                                    },
                                    child: const Text('No'))
                              ],
                            );
                          });
                    }
                  }

                  setState(() {
                    _timerOpsCompleted = true;
                  });
                } else {
                  print("Timer not completed");
                }
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                minimumSize: const Size.fromHeight(AppMargins.XL)),
            icon: const Icon(
              Icons.directions,
              size: AppFontSizes.XXL,
            ),
            label: const Text(
              'Navigate',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: AppFontSizes.L),
            ),
          ),
        ),
        SizedBox.fromSize(
          size: const Size.fromHeight(AppMargins.XL),
          child: Expanded(
              child: DecoratedBox(
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: AppColors.slateGray.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3))
                ],
                color: Colors.white,
                border: const Border(
                    top: BorderSide(width: 0.1, color: AppColors.slateGray))),
            child: Row(children: [
              SizedBox.fromSize(
                size: Size.fromWidth(MediaQuery.of(context).size.width * 0.25),
                child: Padding(
                  padding: const EdgeInsets.all(AppMargins.S),
                  child: Visibility(
                    visible: _isNavigating,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                              side: const BorderSide(color: Colors.red)),
                          backgroundColor: AppColors.orangeRed),
                      child: const Text(
                        'Stop',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppFontSizes.M),
                      ),
                      onPressed: () async {
                        _controller!.finishNavigation();
                        Position crtLocation =
                            await Geolocator.getCurrentPosition();
                        setState(() {
                          _isNavigating = false;
                          origin = crtLocation;
                        });
                        _controller!.buildRoute(wayPoints: [
                          WayPoint(
                              name: 'Origin',
                              latitude: origin.latitude,
                              longitude: origin.longitude),
                          WayPoint(
                              name: 'Destination',
                              latitude: destination.latitude,
                              longitude: destination.longitude)
                        ]);
                      },
                    ),
                  ),
                ),
              ),
              SizedBox.fromSize(
                size: Size.fromWidth(MediaQuery.of(context).size.width * 0.5),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${(_durationRemaining / 60).round()} min",
                            style: const TextStyle(
                              fontSize: AppFontSizes.L,
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: AppFontSizes.L,
                            ),
                          ),
                          Text(
                            _distanceRemaining != null
                                ? showDistanceRemaining(_distanceRemaining!)
                                : "",
                            style: const TextStyle(
                              fontSize: AppFontSizes.L,
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
              SizedBox.fromSize(
                size: Size.fromWidth(MediaQuery.of(context).size.width * 0.25),
                child: Container(),
              )
            ]),
          )),
        ),
      ]),
      bottomNavigationBar: const CustomNavBar(),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    if (_controller != null) {
      _distanceRemaining = await _controller!.distanceRemaining;
      _durationRemaining = await _controller!.durationRemaining;
    }
    print(e.eventType);

    if (prevEvent == null) {
      prevEvent = e.eventType;
    } else if (prevEvent == e.eventType) {
      return;
    }

    switch (e.eventType) {
      case MapBoxEvent.annotation_tapped:
        var annotation = _controller!.selectedAnnotation;
        print(annotation);
        break;
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) {
          setState(() {
            _instruction = progressEvent.currentStepInstruction;
            _instructionDistance = progressEvent.currentLeg != null
                ? progressEvent.currentLeg!.steps != null
                    ? progressEvent.currentLeg!.steps!.isNotEmpty
                        ? showDistanceRemaining(
                            progressEvent.currentLeg!.steps!.first.distance ??
                                0)
                        : ""
                    : ""
                : "";
          });
        }
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        print("Navigation running event received");
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          // TODO: show arrival message
          await Future.delayed(const Duration(seconds: 3));
          await _controller!.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        print("Navigation stopped event received");
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {
      prevEvent = e.eventType;
    });
  }

  String showDistanceRemaining(double meters) {
    String km = (meters / 1000).toStringAsFixed(1);
    int m = meters.round() % 1000;

    return meters > 1000 ? '$km km' : '$m m';
  }
}
