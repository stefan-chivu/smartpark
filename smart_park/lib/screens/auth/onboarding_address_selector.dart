import 'dart:convert';

import 'package:easy_park/models/address.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/search_address_textfield.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class OnboardingAddressSelector extends StatefulWidget {
  const OnboardingAddressSelector({super.key});

  @override
  State<OnboardingAddressSelector> createState() =>
      _OnboardingAddressSelectorState();
}

class _OnboardingAddressSelectorState extends State<OnboardingAddressSelector> {
  final _addressFormKey = GlobalKey<FormState>();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _workAddressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.check_rounded,
            size: AppFontSizes.XXL,
          ),
          onPressed: () async {
            if (_addressFormKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 2),
                content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        width: AppMargins.M,
                      ),
                      Text("Updating user data...")
                    ]),
                backgroundColor: AppColors.blueGreen,
              ));
              if (_workAddressController.text.isNotEmpty) {
                List<Location> workAddressLocations =
                    await locationFromAddress(_workAddressController.text);
                try {
                  Address workAddress = await LocationService.addressFromLatLng(
                      workAddressLocations.first.latitude,
                      workAddressLocations.first.longitude);
                  IsarService.isarUser.workAddress = jsonEncode(workAddress);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.orangeRed,
                    ));
                  }
                }
              }

              if (_homeAddressController.text.isNotEmpty) {
                List<Location> homeAddressLocations =
                    await locationFromAddress(_homeAddressController.text);

                try {
                  Address homeAddress = await LocationService.addressFromLatLng(
                      homeAddressLocations.first.latitude,
                      homeAddressLocations.first.longitude);
                  IsarService.isarUser.homeAddress = jsonEncode(homeAddress);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.orangeRed,
                    ));
                  }
                }
              }
              try {
                await SqlService.pushLocalUserData();
                await SqlService.markOnboardingCompleted();

                if (mounted) {
                  Navigator.pushNamed(context, '/');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.orangeRed,
                  ));
                }
              }
            }
          }),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          SizedBox(
            width: 150,
            height: 150,
            child: Icon(
              Icons.map,
              size: 130,
            ),
          )
        ]),
        const SizedBox(height: AppMargins.S),
        SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            child: Form(
                key: _addressFormKey,
                child: Column(children: [
                  SearchAddressTextField(
                      label: 'Work address (optional)',
                      controller: _workAddressController,
                      mapController: null),
                  const SizedBox(height: AppMargins.S),
                  SearchAddressTextField(
                      label: 'Home address (optional)',
                      controller: _homeAddressController,
                      mapController: null)
                ]))),
      ]),
    );
  }
}
