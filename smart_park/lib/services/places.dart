import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_park/models/address.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/isar.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  String sessionToken;
  Timer? _timer;
  final Duration searchDelay = const Duration(milliseconds: 1500);
  late Completer<List<Suggestion>> _completer;
  AddressSearch({required this.sessionToken});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Suggestion.empty());
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (_timer?.isActive ?? false) _timer!.cancel();
    _completer = Completer<List<Suggestion>>();
    _timer = Timer(searchDelay, () async {
      final List<Suggestion> suggestions =
          await PlaceApiProvider.fetchSuggestions(query, 'en', sessionToken);
      _completer.complete(suggestions);
    });
    return FutureBuilder(
      future: _completer.future,
      builder: (context, AsyncSnapshot<List<Suggestion>> snapshot) => query ==
              ''
          ? ListView(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Type the address you are looking for'),
                ),
                IsarService.isarUser.homeAddress.isNotEmpty
                    ? ListTile(
                        leading: const Icon(Icons.home),
                        title: Text(Address.fromJson(
                                json.decode(IsarService.isarUser.homeAddress))
                            .toString()),
                        onTap: () async {
                          Address crtAddress = Address.fromJson(
                              json.decode(IsarService.isarUser.homeAddress));
                          Suggestion crtSuggestion =
                              Suggestion('home', crtAddress.toString());
                          List<Location> locations = await GeocodingPlatform
                              .instance
                              .locationFromAddress(crtSuggestion.description);
                          crtSuggestion.location = LatLng(
                              locations[0].latitude, locations[0].longitude);
                          // ignore: use_build_context_synchronously
                          close(context, crtSuggestion);
                        },
                      )
                    : const ListTile(),
                IsarService.isarUser.workAddress.isNotEmpty
                    ? ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(Address.fromJson(
                                json.decode(IsarService.isarUser.workAddress))
                            .toString()),
                        onTap: () async {
                          Address crtAddress = Address.fromJson(
                              json.decode(IsarService.isarUser.workAddress));
                          Suggestion crtSuggestion =
                              Suggestion('work', crtAddress.toString());
                          List<Location> locations = await GeocodingPlatform
                              .instance
                              .locationFromAddress(crtSuggestion.description);
                          crtSuggestion.location = LatLng(
                              locations[0].latitude, locations[0].longitude);
                          // ignore: use_build_context_synchronously
                          close(context, crtSuggestion);
                        },
                      )
                    : const ListTile(),
              ],
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    leading: snapshot.data![index].placeId == 'home'
                        ? const Icon(Icons.home)
                        : snapshot.data![index].placeId == 'work'
                            ? const Icon(Icons.work)
                            : const Icon(Icons.directions),
                    title: Text(snapshot.data![index].description),
                    onTap: () async {
                      Suggestion crtSuggestion = snapshot.data![index];
                      List<Location> locations = await GeocodingPlatform
                          .instance
                          .locationFromAddress(crtSuggestion.description);
                      crtSuggestion.location =
                          LatLng(locations[0].latitude, locations[0].longitude);
                      // ignore: use_build_context_synchronously
                      close(context, crtSuggestion);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

class Suggestion {
  final String placeId;
  final String description;

  LatLng? location;

  Suggestion(this.placeId, this.description);

  Suggestion.empty()
      : placeId = '',
        description = '';

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  static final client = Dio();

  PlaceApiProvider();

  static const String androidKey = Constants.googleMapsApiKey;
  static const String iosKey = Constants.googleMapsApiKey;
  static final apiKey = Platform.isAndroid ? androidKey : iosKey;

  static Future<List<Suggestion>> fetchSuggestions(
      String input, String lang, String sessionToken) async {
    List<Suggestion> suggestions = [];

    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&components=country:ro&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (IsarService.isarUser.homeAddress.isNotEmpty) {
      suggestions.add(Suggestion(
          'home',
          Address.fromJson(json.decode(IsarService.isarUser.homeAddress))
              .toString()));
    }

    if (IsarService.isarUser.workAddress.isNotEmpty) {
      suggestions.add(Suggestion(
          'work',
          Address.fromJson(json.decode(IsarService.isarUser.workAddress))
              .toString()));
    }

    if (response.statusCode == 200) {
      final result = response.data;
      if (result['status'] == 'OK') {
        suggestions.addAll(result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList());
      }
      return suggestions;
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

// TODO: might add support for more detailed addresses
// Future<Place> getPlaceDetailFromId(String placeId) async {
//   final request =
//       'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
//   final response = await client.get(request);

//   if (response.statusCode == 200) {
//     final result = json.decode(response.body);
//     if (result['status'] == 'OK') {
//       final components =
//           result['result']['address_components'] as List<dynamic>;
//       // build result
//       final place = Place();
//       components.forEach((c) {
//         final List type = c['types'];
//         if (type.contains('street_number')) {
//           place.streetNumber = c['long_name'];
//         }
//         if (type.contains('route')) {
//           place.street = c['long_name'];
//         }
//         if (type.contains('locality')) {
//           place.city = c['long_name'];
//         }
//         if (type.contains('postal_code')) {
//           place.zipCode = c['long_name'];
//         }
//       });
//       return place;
//     }
//     throw Exception(result['error_message']);
//   } else {
//     throw Exception('Failed to fetch suggestion');
//   }
// }
}

// class Place {
//   String streetNumber;
//   String street;
//   String city;
//   String zipCode;

//   Place({
//     this.streetNumber,
//     this.street,
//     this.city,
//     this.zipCode,
//   });

//   @override
//   String toString() {
//     return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
//   }
// }
