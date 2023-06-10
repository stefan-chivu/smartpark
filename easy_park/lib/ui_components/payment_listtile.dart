import 'dart:io';

import 'package:checkout_screen_ui/checkout_page.dart';
import 'package:easy_park/models/parking_history.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/sql.dart';
import 'package:easy_park/ui_components/label_icon_button.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentListTile extends StatelessWidget {
  final ParkingPayment parkingHistory;
  const PaymentListTile({super.key, required this.parkingHistory});

  @override
  Widget build(BuildContext context) {
    int minutes = parkingHistory.parkingDuration.inMinutes % 60;
    int hours = parkingHistory.parkingDuration.inHours % 24;
    int days = parkingHistory.parkingDuration.inDays;

    String parkingDurationPrettyString =
        days > 0 ? "${days}d ${hours}h${minutes}m" : "${hours}h${minutes}m";
    String formattedTimestamp = DateFormat('MMMM d, y · H:m')
        .format(parkingHistory.timestamp ?? parkingHistory.parkingStart);
    String checkoutTimestamp =
        "${DateFormat('MMMM d, y').format(parkingHistory.timestamp ?? parkingHistory.parkingStart)}\n$parkingDurationPrettyString";

    return ListTile(
      leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.local_parking, color: _getStateColor(parkingHistory.state))
      ]),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        Text(_getStateMessage(parkingHistory.state))
      ]),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(parkingHistory.car.licensePlate),
          Text(formattedTimestamp),
          Text(
            "${parkingHistory.spot.zone.currency} ${parkingHistory.totalSum.toStringAsFixed(2)} · $parkingDurationPrettyString",
            style: const TextStyle(color: Colors.black),
          ),
          const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        ],
      ),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: AppMargins.XL,
            child: LabelIconButton(
              textColor: _getStateColor(parkingHistory.state),
              text: _getTrailingIconText(parkingHistory.state),
              icon: _getTrailingIcon(parkingHistory.state),
              onTap: () async {
                switch (parkingHistory.state) {
                  case PaymentState.ongoing:
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text(
                                'You will be able to pay after you leave the spot'),
                          );
                        });
                    break;
                  case PaymentState.due:
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CheckoutPage(
                            displayTestData: true,
                            initEmail: IsarService.isarUser.email,
                            countriesOverride: const ['Romania'],
                            priceItems: [
                              PriceItem(
                                  name:
                                      "Parking in ${parkingHistory.spot.zone.name}",
                                  description: checkoutTimestamp,
                                  quantity: 1,
                                  totalPriceCents:
                                      (parkingHistory.totalSum * 100).toInt()),
                            ],
                            payToName: 'SmartPark',
                            displayNativePay: true,
                            onNativePay: () async {
                              print('Native Pay Clicked');
                              try {
                                await SqlService.handlePayment(parkingHistory);

                                // ignore: use_build_context_synchronously
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/', (route) => false);
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        backgroundColor: AppColors.orangeRed,
                                        content: Text(
                                          "An error occured while processing your payment",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )));
                              }
                            },
                            isApple: Platform.isIOS,
                            onCardPay: (results) async {
                              print(
                                  'Credit card form submitted with results: $results');
                              try {
                                await SqlService.handlePayment(parkingHistory);

                                // ignore: use_build_context_synchronously
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/', (route) => false);
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        backgroundColor: AppColors.orangeRed,
                                        content: Text(
                                          "An error occured while processing your payment",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )));
                              }
                            },
                            onBack: () => Navigator.of(context).pop(),
                          );
                          ;
                        });

                    break;
                  case PaymentState.paid:
                    // TODO: generate pdf for invoice
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            content: Text('Download invoice'),
                          );
                        });
                    break;
                }
              },
              horizontal: false,
            ))
      ]),
    );
  }

  Color _getStateColor(PaymentState state) {
    switch (state) {
      case PaymentState.paid:
        return AppColors.emerald;
      case PaymentState.due:
        return AppColors.orangeRed;
      case PaymentState.ongoing:
        return AppColors.sandyBrown;
    }
  }

  String _getStateMessage(PaymentState state) {
    switch (state) {
      case PaymentState.paid:
        return "Invoice #${parkingHistory.id}";
      case PaymentState.due:
        return "Payment is due";
      case PaymentState.ongoing:
        return "Ongoing parking";
    }
  }

  String _getTrailingIconText(PaymentState state) {
    switch (state) {
      case PaymentState.paid:
        return "Invoice";
      case PaymentState.due:
        return "Pay";
      case PaymentState.ongoing:
        return "Ongoing";
    }
  }

  IconData _getTrailingIcon(PaymentState state) {
    switch (state) {
      case PaymentState.paid:
        return Icons.file_download_outlined;
      case PaymentState.due:
        return Icons.payment_rounded;
      case PaymentState.ongoing:
        return Icons.watch_later;
    }
  }
}
