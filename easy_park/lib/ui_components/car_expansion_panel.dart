import 'package:easy_park/models/isar_car.dart';
import 'package:easy_park/services/constants.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class CarPanelItem {
  IsarCar car;
  bool isExpanded = false;
  CarPanelItem({
    required this.car,
    required this.isExpanded,
  });
}

ExpansionPanel carExpansionPanel(
    BuildContext context, bool isExpanded, IsarCar car, bool editable,
    {Widget? headerLeading, Widget? headerTitle, Widget? headerTrailing}) {
  return ExpansionPanel(
      isExpanded: isExpanded,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: headerLeading,
          title: headerTitle,
          trailing: headerTrailing,
        );
      },
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppMargins.S),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeYellow),
                      onPressed: () {},
                      icon:
                          const Icon(Icons.edit_document, color: Colors.black),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      )),
                ),
                const Padding(padding: EdgeInsets.all(AppMargins.XS)),
                Expanded(
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeRed),
                        onPressed: () async {
                          try {
                            await SqlService.deleteUserCar(car);
                            await IsarService.deleteUserCar(car);
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            // ignore: use_build_context_synchronously
                            Future.delayed(Duration.zero, () {
                              Navigator.pushReplacementNamed(
                                  context, '/profile');
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: AppColors.orangeRed,
                                content: Text(
                                  e.toString(),
                                )));
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.black),
                        label: const Text(
                          'Remove',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )))
              ])),
          const Padding(padding: EdgeInsets.all(AppMargins.S)),
        ],
      ));
}

class AddCarDialog extends StatefulWidget {
  final TextEditingController controller;

  const AddCarDialog({super.key, required this.controller});

  @override
  State<AddCarDialog> createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  final formKey = GlobalKey<FormState>();
  bool isElectric = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Add a new car'),
        content: Form(
            key: formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A value is required';
                      }

                      if (value.length < 5 ||
                          value.length > 20 ||
                          !Constants.alNumRegExp.hasMatch(value)) {
                        return 'Invalid value';
                      }
                      return null;
                    },
                    controller: widget.controller,
                    label: "License plate",
                  ),
                  const Padding(padding: EdgeInsets.all(AppMargins.XS)),
                  Row(children: [
                    Checkbox(
                        value: isElectric,
                        onChanged: (value) {
                          setState(() {
                            isElectric = value ?? false;
                          });
                        }),
                    const Text("Electric vehicle"),
                  ]),
                  const Padding(padding: EdgeInsets.all(AppMargins.S)),
                  Row(
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeRed),
                          icon: const Icon(Icons.cancel),
                          label: const Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        width: AppMargins.S,
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              IsarCar car = IsarCar(
                                  ownerUid: IsarService.isarUser.uid,
                                  licensePlate: widget.controller.text,
                                  isElectric: isElectric);
                              try {
                                await SqlService.addUserCar(car);

                                if (mounted) {
                                  Navigator.pop(context);
                                  Navigator.pushReplacementNamed(
                                      context, '/profile');
                                }
                              } catch (e) {
                                if (mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: AppColors.orangeRed,
                                          content: Text(
                                            e.toString(),
                                          )));
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald),
                          icon: const Icon(Icons.check_box),
                          label: const Text(
                            "Confirm",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                    ],
                  )
                ])));
  }
}
