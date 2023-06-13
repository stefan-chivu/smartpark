import 'package:easy_park/screens/auth/onboarding_address_selector.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class OnboardingPersonalData extends StatefulWidget {
  const OnboardingPersonalData({super.key});

  @override
  State<OnboardingPersonalData> createState() => _OnboardingPersonalDataState();
}

class _OnboardingPersonalDataState extends State<OnboardingPersonalData> {
  final _personalDataFormKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.navigate_next_rounded,
            size: AppFontSizes.XXL,
          ),
          onPressed: () {
            if (_personalDataFormKey.currentState!.validate()) {
              IsarService.isarUser.firstName = _firstNameController.text;
              IsarService.isarUser.lastName = _lastNameController.text;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnboardingAddressSelector()));
            }
          }),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          SizedBox(
            width: 150,
            height: 150,
            child: Icon(
              Icons.person,
              size: 130,
            ),
          )
        ]),
        const SizedBox(height: AppMargins.S),
        SizedBox(
            width: MediaQuery.of(context).size.width / 1.25,
            child: Form(
                key: _personalDataFormKey,
                child: Column(children: [
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    label: 'First Name (optional)',
                    controller: _firstNameController,
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        if (val.length < 2 ||
                            val.length > 30 ||
                            !Constants.nameRegExp.hasMatch(val)) {
                          return 'Invalid value';
                        }
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: AppMargins.S),
                  CustomTextField(
                    keyboardType: TextInputType.emailAddress,
                    label: 'Last Name (optional)',
                    controller: _lastNameController,
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        if (val.length < 2 ||
                            val.length > 30 ||
                            !Constants.nameRegExp.hasMatch(val)) {
                          return 'Invalid value';
                        }
                      }

                      return null;
                    },
                  )
                ]))),
      ]),
    );
  }
}
