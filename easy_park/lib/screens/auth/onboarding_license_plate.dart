import 'package:easy_park/screens/auth/onboarding_personal_data.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class OnboardingLicensePlate extends StatefulWidget {
  const OnboardingLicensePlate({super.key});

  @override
  State<OnboardingLicensePlate> createState() => _OnboardingLicensePlateState();
}

class _OnboardingLicensePlateState extends State<OnboardingLicensePlate> {
  final _licensePlateFormKey = GlobalKey<FormState>();
  final TextEditingController _licensePlateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.navigate_next_rounded,
            size: AppFontSizes.XXL,
          ),
          onPressed: () {
            if (_licensePlateFormKey.currentState!.validate()) {
              IsarService.isarUser.licensePlate = _licensePlateController.text;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnboardingPersonalData()));
            }
          }),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          SizedBox(
            width: 150,
            height: 150,
            child: Icon(
              Icons.time_to_leave,
              size: 130,
            ),
          )
        ]),
        const SizedBox(height: AppMargins.S),
        SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            child: const Text(
              'Please provide the license plate of the car you are going to use to navigate:',
              textAlign: TextAlign.center,
            )),
        const SizedBox(height: AppMargins.M),
        SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            child: Form(
                key: _licensePlateFormKey,
                child: CustomTextField(
                  keyboardType: TextInputType.name,
                  label: 'License plate (required)',
                  controller: _licensePlateController,
                  icon: Icons.car_rental,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'A value is required';
                    }

                    if (val.length < 5 ||
                        val.length > 20 ||
                        !Constants.alNumRegExp.hasMatch(val)) {
                      return 'Invalid value';
                    }

                    return null;
                  },
                ))),
      ]),
    );
  }
}
