import 'package:easy_park/models/address.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

import 'custom_textfield.dart';

ExpansionPanel addressExpansionPanel(
    bool isExpanded,
    Address address,
    bool editable,
    TextEditingController streetController,
    TextEditingController cityController,
    TextEditingController regionController,
    TextEditingController countryController,
    {Widget? headerLeading,
    Widget? headerTitle}) {
  return ExpansionPanel(
      isExpanded: isExpanded,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: headerLeading,
          title: headerTitle,
        );
      },
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppMargins.S),
            child: CustomTextField(
              label: 'Street',
              enabled: editable,
              controller: streetController,
            ),
          ),
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppMargins.S),
            child: CustomTextField(
              label: 'City',
              enabled: editable,
              controller: cityController,
            ),
          ),
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppMargins.S),
            child: CustomTextField(
              label: 'Region',
              enabled: editable,
              controller: regionController,
            ),
          ),
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppMargins.S),
            child: CustomTextField(
              label: 'Country',
              enabled: editable,
              controller: countryController,
            ),
          ),
          const Padding(padding: EdgeInsets.all(AppMargins.S)),
        ],
      ));
}
