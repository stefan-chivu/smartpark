import 'package:easy_park/models/parking_info.dart';
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
  double? _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController? _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  dynamic prevEvent;
  late Position origin;
  late LatLng destination;
  late SpotInfo spot;

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
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible: _isNavigating,
          child: SizedBox.fromSize(
              size: const Size.fromHeight(AppMargins.XXXL),
              child: Expanded(
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
                      : Container(),
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
              ))),
        ),
        if (_options != null)
          Expanded(
            flex: 1,
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
                size: Size.fromWidth(MediaQuery.of(context).size.width * 0.3),
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
                            fontSize: AppFontSizes.L),
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
                size: Size.fromWidth(MediaQuery.of(context).size.width * 0.4),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _durationRemaining != null
                                ? "${(_durationRemaining! / 60).round()} min"
                                : "",
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
                size: Size.fromWidth(MediaQuery.of(context).size.width * 0.3),
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
    _distanceRemaining = await _controller!.distanceRemaining;
    _durationRemaining = await _controller!.durationRemaining;
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
                ? showDistanceRemaining(progressEvent.distance ?? 0)
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
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller!.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
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
