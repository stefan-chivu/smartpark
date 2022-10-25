import 'dart:async';

import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
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
  Completer<GoogleMapController> _controller = Completer();
  late Future<CameraPosition> _crtPosition;
  late Future<List<ParkingInfo>> _parkingSpots;
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
        target: LatLng(data.latitude!, data.longitude!), zoom: 19);
  }

  Future<List<ParkingInfo>> _getParkingSpots() async {
    List<ParkingInfo> spots = await sqlService.getParkingSpots();

    return spots;
  }

  Set<Marker> _getMarkers(List<ParkingInfo> spots) {
    Set<Marker> markers = {};
    for (ParkingInfo s in spots) {
      if (s.position != null) {
        markers.add(Marker(
          //add first marker
          markerId: MarkerId(s.id.toString()),
          position: s.position!, //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: 'Spot #${s.id}',
            snippet: 'Price: 5RON/h',
          ),
          icon: (s.occupied)
              ? BitmapDescriptor.defaultMarker
              : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen), //Icon for Marker
        ));
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(showHome: false),
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
                  print(snapshot.data[0]);
                  Set<Marker> markers = _getMarkers(snapshot.data[1]);
                  print(markers);
                  return GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: snapshot.data[0],
                      myLocationEnabled: true,
                      markers: markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      });
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
