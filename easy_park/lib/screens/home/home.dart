import 'dart:async';

import 'package:easy_park/services/location.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  late Future<CameraPosition> _crtPosition;

  @override
  void initState() {
    super.initState();
    _crtPosition = _getPosition();
  }

  Future<CameraPosition> _getPosition() async {
    LocationData data = await LocationService().getCurrentLocation();

    if (data.latitude == null || data.longitude == null) {
      return Future.error('Error fetching location data');
    }

    return CameraPosition(
        target: LatLng(data.latitude!, data.longitude!), zoom: 19);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(showHome: false),
        body: FutureBuilder(
          future: _crtPosition,
          builder:
              (BuildContext context, AsyncSnapshot<CameraPosition> snapshot) {
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
                  return GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: snapshot.data!,
                      myLocationEnabled: true,
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
