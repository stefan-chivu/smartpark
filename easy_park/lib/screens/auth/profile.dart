import 'dart:convert';

import 'package:easy_park/models/address.dart';
import 'package:easy_park/models/isar_car.dart';
import 'package:easy_park/services/auth.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/address_expansion_panel.dart';
import 'package:easy_park/ui_components/car_expansion_panel.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:easy_park/ui_components/loading_snack_bar.dart';
import 'package:easy_park/ui_components/label_icon_button.dart';
import 'package:easy_park/ui_components/profile_picture.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _firstNameController =
      TextEditingController(text: IsarService.isarUser.firstName);
  final TextEditingController _lastNameController =
      TextEditingController(text: IsarService.isarUser.lastName);
  final TextEditingController _licensePlateController = TextEditingController();
  bool editable = false;
  late final Address homeAddress;
  late final Address workAddress;
  late final List<AddressPanelItem> _addresses;
  final List<CarPanelItem> _cars = [];

  double widgetWidthRatio = 1.25;
  @override
  void initState() {
    super.initState();
    if (IsarService.isarUser.homeAddress.isNotEmpty) {
      homeAddress =
          Address.fromJson(jsonDecode(IsarService.isarUser.homeAddress));
    } else {
      homeAddress = Address.empty();
    }
    if (IsarService.isarUser.workAddress.isNotEmpty) {
      workAddress =
          Address.fromJson(jsonDecode(IsarService.isarUser.workAddress));
    } else {
      workAddress = Address.empty();
    }
    _addresses = [
      AddressPanelItem(
          address: workAddress,
          headerLeading: const Icon(Icons.work),
          headerTitle: const Text("Work Address"),
          isExpanded: false),
      AddressPanelItem(
          address: homeAddress,
          headerLeading: const Icon(Icons.house_rounded),
          headerTitle: const Text("Home Address"),
          isExpanded: false)
    ];

    for (IsarCar car in IsarService.isarCars) {
      _cars.add(CarPanelItem(car: car, isExpanded: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [ProfilePicture()],
            ),
            const Padding(padding: EdgeInsets.all(AppMargins.XS)),
            IsarService.isarUser.isAdmin
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.verified_user,
                        color: AppColors.sandyBrown,
                      ),
                      Text(' ADMIN')
                    ],
                  )
                : Container(),
            const Padding(padding: EdgeInsets.all(AppMargins.XS)),
            SizedBox(
                width: MediaQuery.of(context).size.width / widgetWidthRatio,
                child: TextField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  controller:
                      TextEditingController(text: IsarService.isarUser.email),
                )),
            IsarService.isarUser.isAdmin
                ? Column(
                    children: [
                      const Padding(padding: EdgeInsets.all(AppMargins.S)),
                      Title(
                        color: Colors.black,
                        child: const Text(
                          'Admin panel',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppFontSizes.L),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(AppMargins.S)),
                      LabelIconButton(
                          color: AppColors.slateGray,
                          icon: Icons.add_location_alt_outlined,
                          text: "Add sensor",
                          onTap: () async {
                            Navigator.pushNamed(context, '/add-sensor');
                          }),
                      const TextField(
                        enabled: false,
                      ),
                      const Padding(padding: EdgeInsets.all(AppMargins.M)),
                    ],
                  )
                : Container(),
            SizedBox(
                width: MediaQuery.of(context).size.width / widgetWidthRatio,
                child: CustomTextField(
                    label: 'First Name',
                    enabled: editable,
                    controller: _firstNameController)),
            const Padding(padding: EdgeInsets.all(AppMargins.S)),
            SizedBox(
                width: MediaQuery.of(context).size.width / widgetWidthRatio,
                child: CustomTextField(
                    label: 'Last Name',
                    enabled: editable,
                    controller: _lastNameController)),
            const Padding(padding: EdgeInsets.all(AppMargins.S)),
            SizedBox(
                width: MediaQuery.of(context).size.width / widgetWidthRatio,
                child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _addresses[index].isExpanded = !isExpanded;
                      });
                    },
                    children:
                        _addresses.map<ExpansionPanel>((AddressPanelItem item) {
                      return addressExpansionPanel(
                          item.isExpanded,
                          item.address,
                          editable,
                          item.streetController,
                          item.cityController,
                          item.regionController,
                          item.countryController,
                          headerLeading: item.headerLeading,
                          headerTitle: item.headerTitle);
                    }).toList())),
            const Padding(padding: EdgeInsets.all(AppMargins.S)),
            SizedBox(
              width: MediaQuery.of(context).size.width / widgetWidthRatio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (editable) {
                              _firstNameController.text =
                                  IsarService.isarUser.firstName;
                              _lastNameController.text =
                                  IsarService.isarUser.lastName;
                              _addresses[0].streetController.text =
                                  workAddress.street;
                              _addresses[0].cityController.text =
                                  workAddress.city;
                              _addresses[0].regionController.text =
                                  workAddress.region;
                              _addresses[0].countryController.text =
                                  workAddress.country;

                              _addresses[1].streetController.text =
                                  homeAddress.street;
                              _addresses[1].cityController.text =
                                  homeAddress.city;
                              _addresses[1].regionController.text =
                                  homeAddress.region;
                              _addresses[1].countryController.text =
                                  homeAddress.country;
                            }
                            editable = !editable;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: editable
                                ? AppColors.orangeRed
                                : AppColors.orangeYellow),
                        icon: Icon(
                          editable ? Icons.cancel : Icons.edit_document,
                          color: Colors.black,
                        ),
                        label: Text(
                          editable ? 'Cancel' : 'Edit',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                  ),
                  editable
                      ? const Padding(padding: EdgeInsets.all(AppMargins.XS))
                      : Container(),
                  editable
                      ? Expanded(
                          child: ElevatedButton.icon(
                              onPressed: () async {
                                showLoadingSnackBar(context, "Saving...",
                                    color: AppColors.blueGreen,
                                    durationSeconds: 2);

                                setState(() {
                                  editable = !editable;
                                });

                                Address newWorkAddress = Address(
                                    _addresses[0].streetController.text,
                                    _addresses[0].cityController.text,
                                    _addresses[0].regionController.text,
                                    _addresses[0].countryController.text);

                                Address newHomeAddress = Address(
                                    _addresses[1].streetController.text,
                                    _addresses[1].cityController.text,
                                    _addresses[1].regionController.text,
                                    _addresses[1].countryController.text);

                                IsarService.isarUser.firstName =
                                    _firstNameController.text;
                                IsarService.isarUser.lastName =
                                    _lastNameController.text;
                                IsarService.isarUser.workAddress =
                                    jsonEncode(newWorkAddress);
                                IsarService.isarUser.homeAddress =
                                    jsonEncode(newHomeAddress);

                                await IsarService.updateUser();
                                await SqlService.pushLocalUserData();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emerald),
                              icon: const Icon(
                                Icons.save,
                                color: Colors.black,
                              ),
                              label: const Text(
                                'Save',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )))
                      : Container()
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(AppMargins.M)),
            SizedBox(
              width: MediaQuery.of(context).size.width / widgetWidthRatio,
              child: TextField(
                controller: TextEditingController(text: 'Your cars'),
                enabled: false,
              ),
            ),
            const Padding(padding: EdgeInsets.all(AppMargins.S)),
            SizedBox(
                width: MediaQuery.of(context).size.width / widgetWidthRatio,
                child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _cars[index].isExpanded = !isExpanded;
                      });
                    },
                    children: _cars.map<ExpansionPanel>((CarPanelItem item) {
                      return carExpansionPanel(
                        context,
                        item.isExpanded,
                        item.car,
                        editable,
                        headerLeading: const Icon(
                          Icons.info,
                          color: AppColors.pineTree,
                        ),
                        headerTitle: Center(
                          child: Text(
                            item.car.licensePlate,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        headerTrailing: item.car.isElectric
                            ? const Icon(
                                Icons.electric_car_rounded,
                                color: AppColors.emerald,
                              )
                            : const Icon(
                                Icons.time_to_leave_rounded,
                                color: AppColors.slateGray,
                              ),
                      );
                    }).toList())),
            const Padding(padding: EdgeInsets.all(AppMargins.S)),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slateGray),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AddCarDialog(
                          controller: _licensePlateController,
                        );
                      });
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            const TextField(
              enabled: false,
            ),
            const Padding(padding: EdgeInsets.all(AppMargins.S)),
            SizedBox(
              width: MediaQuery.of(context).size.width / widgetWidthRatio,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                    child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeRed),
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await AuthService().signOut();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    }
                  },
                  label: const Text(
                    'Sign-out',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                )),
              ]),
            ),
            const Padding(padding: EdgeInsets.all(AppMargins.L)),
          ])),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}

class AddressPanelItem {
  Address address;
  Widget? headerLeading;
  Widget? headerTitle;
  bool isExpanded = false;
  TextEditingController streetController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  AddressPanelItem(
      {required this.isExpanded,
      required this.address,
      this.headerTitle,
      this.headerLeading}) {
    streetController.text = address.street;
    cityController.text = address.city;
    regionController.text = address.region;
    countryController.text = address.country;
  }
}
