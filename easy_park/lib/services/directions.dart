import 'package:dio/dio.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleDirectionsService {
  GoogleDirectionsService._privateConstructor();
  static final GoogleDirectionsService instance =
      GoogleDirectionsService._privateConstructor();

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  static final Dio _dio = Dio();

  Future<Directions> getDirections(
      {required LatLng origin, required LatLng destination}) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': Constants.googleMapsApiKey,
    });

    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }

    return Directions.empty();
  }
}

class Directions {
  LatLngBounds? bounds;
  List<PointLatLng>? polylinePoints;
  Set<Polyline> polylines = {};
  String? totalDistance;
  String? totalDuration;

  Directions.empty();

  Directions(
      {required this.bounds,
      required this.polylinePoints,
      required this.totalDistance,
      required this.totalDuration,
      required this.polylines});

  factory Directions.fromMap(Map<String, dynamic> map) {
    // Check if route is not available
    if ((map['routes'] as List).isEmpty) return Directions.empty();

    // Get route information
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    // Distance & Duration
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    List<PointLatLng> polylinePoints =
        PolylinePoints().decodePolyline(data['overview_polyline']['points']);

    final List<LatLng> polylineCoordinates = [];
    if (polylinePoints.isNotEmpty) {
      for (PointLatLng point in polylinePoints) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    const id = PolylineId('directions');

    Polyline polyline = Polyline(
        polylineId: id,
        color: AppColors.pineTree,
        points: polylineCoordinates,
        width: 3);

    return Directions(
      bounds: bounds,
      polylinePoints: polylinePoints,
      polylines: {polyline},
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
