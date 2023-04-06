import 'package:easy_park/models/parking_info.dart';
import 'package:easy_park/ui_components/label_icon_button.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class ArrivalConfirmationListTile extends StatelessWidget {
  final SpotInfo spot;
  const ArrivalConfirmationListTile({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(AppMargins.S),
        ),
        const Text(
          "You have arrived at your destination:",
          style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: AppFontSizes.L),
        ),
        const Padding(
          padding: EdgeInsets.all(AppMargins.XS),
        ),
        Text(
          "Spot #${spot.sensorId}, ${spot.address.toString()}",
          style: const TextStyle(fontSize: AppFontSizes.M),
        ),
        Padding(
          padding: const EdgeInsets.all(AppMargins.M),
          child: Expanded(
            child: LabelIconButton(
                color: AppColors.slateGray,
                icon: Icons.check_box,
                text: 'Confirm',
                onTap: () {
                  Navigator.pop(context);
                }),
          ),
        ),
      ],
    );
  }
}
