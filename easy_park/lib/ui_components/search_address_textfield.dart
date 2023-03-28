import 'package:easy_park/services/places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class SearchAddressTextField extends StatefulWidget {
  final TextEditingController controller;
  final GoogleMapController? mapController;

  const SearchAddressTextField(
      {super.key, required this.controller, required this.mapController});

  @override
  State<SearchAddressTextField> createState() => _SearchAddressTextFieldState();
}

class _SearchAddressTextFieldState extends State<SearchAddressTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: 'Search...',
        border: OutlineInputBorder(
          borderSide: const BorderSide(width: 1), //<-- SEE HERE
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      onTap: () async {
        final sessionToken = const Uuid().v4();
        final Suggestion? result = await showSearch(
          context: context,
          delegate: AddressSearch(sessionToken: sessionToken),
        );

        if (result != null && result.description.isNotEmpty) {
          setState(() {
            widget.controller.text = result.description;
            if (widget.mapController != null && result.location != null) {
              widget.mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(result.location!, 16.5));
            }
          });
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, '/error');
        }
      },
    );
  }
}
