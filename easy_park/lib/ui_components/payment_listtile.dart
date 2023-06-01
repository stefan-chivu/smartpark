import 'package:easy_park/models/parking_history.dart';
import 'package:easy_park/ui_components/label_icon_button.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentListTile extends StatelessWidget {
  final ParkingPayment parkingHistory;
  const PaymentListTile({super.key, required this.parkingHistory});

  @override
  Widget build(BuildContext context) {
    Duration parkingDuration =
        parkingHistory.parkingEnd.difference(parkingHistory.parkingStart);
    int minutes = parkingDuration.inMinutes % 60;
    int hours = parkingDuration.inHours % 24;
    int days = parkingDuration.inDays;

    String parkingDurationPrettyString =
        days > 0 ? "${days}d ${hours}h${minutes}m" : "${hours}h${minutes}m";
    String formattedTimestamp =
        DateFormat('MMMM d, y · H:m').format(parkingHistory.timestamp);
    return ListTile(
      leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_parking, color: AppColors.emerald)
          ]),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        Text("Invoice #${parkingHistory.id}")
      ]),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(parkingHistory.car.licensePlate),
          Text(formattedTimestamp),
          Text(
            "${parkingHistory.spot.zone.currency} ${parkingHistory.totalSum} · $parkingDurationPrettyString",
            style: const TextStyle(color: Colors.black),
          ),
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        ],
      ),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: AppMargins.XL,
            child: LabelIconButton(
              textColor: Colors.grey,
              text: 'Invoice',
              icon: Icons.save_alt,
              onTap: () {
                // TODO: generate pdf for invoice
                showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        content: Text('Download invoice'),
                      );
                    });
              },
              horizontal: false,
            ))
      ]),
    );
  }
}
