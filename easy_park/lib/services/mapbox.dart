import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/arrival_confirmation_listtile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:geolocator/geolocator.dart';

class MapboxService {
  static void registerRouteListener(BuildContext context, SpotInfo spot) {
    MapBoxNavigation.instance.registerRouteEventListener((value) async {
      switch (value.eventType) {
        case MapBoxEvent.on_arrival:
          print("Arrived; Clearing reservation for spot ${spot.sensorId}");
          MapBoxNavigation.instance.finishNavigation();
          // TODO: investigate memory leak
          await SqlService.clearSpotReservation(spot.sensorId);

          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return ArrivalConfirmationListTile(
                  spot: spot,
                );
              });
          break;
        default:
          break;
      }
    });
  }

  static Future<void> navigate(BuildContext context, SpotInfo spot) async {
    Position position = await Geolocator.getCurrentPosition();
    WayPoint origin = WayPoint(
        name: 'Your location',
        latitude: position.latitude,
        longitude: position.longitude);
    WayPoint destination = WayPoint(
        name: spot.address.toString(),
        latitude: spot.latitude,
        longitude: spot.longitude);

    MapBoxNavigation.instance.setDefaultOptions(MapBoxOptions(
        initialLatitude: origin.latitude,
        initialLongitude: origin.longitude,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        mapStyleUrlDay: "Style.TRAFFIC_DAY",
        mapStyleUrlNight: "Style.TRAFFIC_NIGHT",
        units: VoiceUnits.metric,
        simulateRoute: true,
        enableFreeDriveMode: false,
        language: "en"));

    var wayPoints = <WayPoint>[];
    wayPoints.add(origin);
    wayPoints.add(destination);

    MapboxService.registerRouteListener(context, spot);

    await MapBoxNavigation.instance.startNavigation(wayPoints: wayPoints);
  }
}
