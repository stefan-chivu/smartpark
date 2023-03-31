import 'package:easy_park/models/isar_car.dart';
import 'package:easy_park/screens/auth/onboarding_personal_data.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/sql.dart';
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
  bool isElectric = false;
  double pageWidthRatio = 1.25;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.navigate_next_rounded,
            size: AppFontSizes.XXL,
          ),
          onPressed: () async {
            if (_licensePlateFormKey.currentState!.validate()) {
              try {
                await SqlService.addUserCar(IsarCar(
                    ownerUid: IsarService.isarUser.uid,
                    licensePlate: _licensePlateController.text,
                    isElectric: isElectric));
                if (mounted) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const OnboardingPersonalData()));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: AppColors.orangeRed,
                      content: Text(
                        e.toString(),
                      )));
                }
              }
            }
          }),
      body: Form(
          key: _licensePlateFormKey,
          child: Column(children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: AppMargins.XXL),
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
                  width: MediaQuery.of(context).size.width / pageWidthRatio,
                  child: const Text(
                    'Please provide the license plate of the car you are going to use to navigate:',
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: AppMargins.M),
              SizedBox(
                  width: MediaQuery.of(context).size.width / pageWidthRatio,
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
                  )),
              const Padding(padding: EdgeInsets.all(AppMargins.XS)),
              SizedBox(
                  width: MediaQuery.of(context).size.width / pageWidthRatio,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                            value: isElectric,
                            onChanged: (value) {
                              setState(() {
                                isElectric = value ?? false;
                              });
                            }),
                        const Text("Electric vehicle"),
                      ])),
            ])
          ])),
    );
  }
}
