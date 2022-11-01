import 'dart:async';

import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:multi_split_view/multi_split_view.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  late Future<CameraPosition> _crtPosition;
  late Future<List<ParkingInfo>> _parkingSpots;
  Set<Marker> _markers = {};
  SqlService sqlService = SqlService();

  @override
  void initState() {
    super.initState();
    _crtPosition = _getPosition();
    _parkingSpots = _getParkingSpots();
  }

  Future<CameraPosition> _getPosition() async {
    LocationData data = await LocationService().getCurrentLocation();

    if (data.latitude == null || data.longitude == null) {
      return Future.error('Error fetching location data');
    }

    return CameraPosition(
        target: LatLng(data.latitude!, data.longitude!), zoom: 18);
  }

  Future<List<ParkingInfo>> _getParkingSpots() async {
    List<ParkingInfo> spots = await sqlService.getParkingSpots();

    return spots;
  }

  Future<void> _getMarkers(List<ParkingInfo> spots) async {
    if (_markers.isEmpty) {
      for (ParkingInfo s in spots) {
        _markers.add(Marker(
                //add first marker
                markerId: MarkerId(s.sensorId.toString()),
                position: s.position, //position of marker
                infoWindow: InfoWindow(
                  //popup info
                  title: 'Spot #${s.sensorId}',
                  snippet: 'Price: ${s.zone.hourRate}RON/h',
                ),
                // icon: getMarkerIcon()
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed))
            //Icon for Marker
            );
      }
    } else {
      Set<Marker> newMarkers = {};
      for (Marker m in _markers) {
        bool occupied =
            await sqlService.getSensorStatus(int.parse(m.markerId.value));
        newMarkers.add(m.copyWith(iconParam: getMarkerIcon(occupied)));
      }
      _markers.removeAll(_markers.toSet());
      setState(() {
        _markers.addAll(newMarkers);
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
        body: FutureBuilder(
          future: Future.wait([_crtPosition, _parkingSpots]),
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
                if (snapshot.hasData) {
                  if (_markers.isEmpty) {
                    _getMarkers(snapshot.data[1]);
                  }
                  return MultiSplitView(
                      axis: Axis.vertical,
                      resizable: false,
                      controller:
                          MultiSplitViewController(areas: [Area(weight: 0.7)]),
                      children: [
                        GoogleMap(
                            mapType: MapType.normal,
                            initialCameraPosition: snapshot.data[0],
                            myLocationEnabled: true,
                            markers: _markers,
                            onMapCreated: (GoogleMapController controller) {
                              if (!_controller.isCompleted) {
                                _controller.complete(controller);
                              }
                            }),
                        Scaffold(
                          floatingActionButton: FloatingActionButton(
                            onPressed: () {
                              _getMarkers(snapshot.data[1]);
                            },
                            child: Icon(Icons.refresh),
                          ),
                          floatingActionButtonLocation:
                              FloatingActionButtonLocation.centerFloat,
                        ),
                      ]);
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text('Unkown location error');
                }
            }
          },
        ));
  }
}
