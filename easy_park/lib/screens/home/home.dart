import 'dart:async';

import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
      return Future.error('Error fetching location data');
    }

    _crtPosition = CameraPosition(
        target: LatLng(data.latitude!, data.longitude!), zoom: 18);
  }

  Future<void> _getParkingSpots() async {
    _parkingSpots ??= await sqlService.getParkingSpots();

    if (_parkingSpots == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed fetching current parking spot information"),
        backgroundColor: AppColors.orangeRed,
      ));
    }
  }

  Future<void> _getMarkers(List<ParkingInfo>? spots) async {
    if (spots == null) {
      return;
    }
    if (_markers.isEmpty) {
      for (ParkingInfo spot in spots!) {
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
            print("Refreshing all page");
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
      body: FutureBuilder(
        future: Future.wait([_getPosition(), _getParkingSpots()]),
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
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                if (_markers.isEmpty) {
                  if (_parkingSpots == null) {
                    return const ErrorPage();
                  }
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
                  return Text(e.toString());
                }
              } else {
                return const ErrorPage();
              }
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        children: [IconButton(onPressed: (() {}), icon: Icon(Icons.menu))],
      )),
    );
  }
}
