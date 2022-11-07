import 'dart:async';

import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/menu_button.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mysql_client/exception.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class _HomeState extends State<Home> {
  late CameraPosition _crtPosition;
  late List<ParkingInfo>? _parkingSpots = null;
  final Set<Marker> _markers = {};
  SqlService sqlService = SqlService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _getPosition();
    await _getParkingSpots();
  }

  Future<void> _getPosition() async {
    LocationData data = await LocationService().getCurrentLocation();

    if (data.latitude == null || data.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed fetching location data"),
        backgroundColor: AppColors.orangeRed,
      ));
      return Future.error('Fetching location data failed');
    }

    _crtPosition = CameraPosition(
        target: LatLng(data.latitude!, data.longitude!), zoom: 18);
  }

  Future<void> _getParkingSpots() async {
    _parkingSpots ??= await sqlService.getParkingSpots();

    if (_parkingSpots == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed fetching parking spot information"),
        backgroundColor: AppColors.orangeRed,
      ));
      return Future.error("Fetching sensor information failed");
    }
  }

  Future<void> _getMarkers(List<ParkingInfo>? spots) async {
    if (spots == null) {
      return;
    }
    if (_markers.isEmpty) {
      for (ParkingInfo spot in spots) {
        _markers.add(Marker(
            markerId: MarkerId(spot.sensorId.toString()),
            position: spot.position, //position of marker
            infoWindow: InfoWindow(
              //popup info
              title: 'Spot #${spot.sensorId}',
              snippet: 'Price: ${spot.zone.hourRate}RON/h',
            ),
            icon: getMarkerIcon(spot.occupied)));
      }
    } else {
      Set<Marker> newMarkers = {};
      for (Marker m in _markers) {
        bool? occupied =
            await sqlService.getSensorStatus(int.parse(m.markerId.value));
        if (occupied == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Failed updating sensor status"),
              backgroundColor: AppColors.orangeRed));
          return Future.error("Updating sensor information failed");
        }
        newMarkers.add(m.copyWith(iconParam: getMarkerIcon(occupied ?? false)));
      }
      _markers.removeAll(_markers.toSet());
      setState(() {
        _markers.addAll(newMarkers);
        _parkingSpots = _parkingSpots;
        _crtPosition = _crtPosition;
      });
    }
  }

  BitmapDescriptor getMarkerIcon(bool occupied) {
    return occupied
        ? BitmapDescriptor.defaultMarker
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showHome: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          if (_parkingSpots == null) {
            setState(() {});
            return;
          }
          _getMarkers(_parkingSpots!);
        },
        child: const Icon(
          Icons.refresh,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      // TODO: consider swapping to StreamBuilder
      body: FutureBuilder(
        future:
            Future.wait([_getPosition(), _getParkingSpots()], eagerError: true),
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
              if (snapshot.hasError) {
                return ErrorPage(errorMsg: 'Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                if (_parkingSpots == null) {
                  return ErrorPage(errorMsg: "Error: ${snapshot.error}");
                }
                if (_markers.isEmpty) {
                  _getMarkers(_parkingSpots!);
                }
                try {
                  return GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _crtPosition,
                    myLocationEnabled: true,
                    markers: _markers,
                  );
                } catch (e) {
                  return const ErrorPage();
                }
              } else {
                return const ErrorPage();
              }
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.slateGray,
        showUnselectedLabels: true,
        iconSize: AppFontSizes.XL,
        selectedFontSize: AppFontSizes.L,
        unselectedFontSize: AppFontSizes.L,
        items: const [
          BottomNavigationBarItem(
              backgroundColor: AppColors.slateGray,
              icon: Icon(Icons.history),
              label: "History"),
          BottomNavigationBarItem(
              backgroundColor: AppColors.slateGray,
              icon: Icon(Icons.payment),
              label: "Pay"),
          BottomNavigationBarItem(
              backgroundColor: AppColors.slateGray,
              icon: Icon(Icons.search),
              label: "Find"),
          BottomNavigationBarItem(
              backgroundColor: AppColors.slateGray,
              icon: Icon(Icons.list),
              label: "Spots")
        ],
        onTap: ((index) {
          switch (index) {
            case 0:
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Text('Parking history'),
                  actions: <TextButton>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    )
                  ],
                ),
              );
              break;
            case 1:
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Text('Pay for parking'),
                  actions: <TextButton>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    )
                  ],
                ),
              );
              break;
            case 2:
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Text('Find parking spots'),
                  actions: <TextButton>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    )
                  ],
                ),
              );
              break;
            case 3:
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: const Text('View parking spots'),
                  actions: <TextButton>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    )
                  ],
                ),
              );
              break;
          }
        }),
      ),
    );
  }
}
