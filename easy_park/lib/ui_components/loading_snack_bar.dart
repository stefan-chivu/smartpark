import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

void showLoadingSnackBar(BuildContext context, String text,
    {Color color = Colors.black,
    Color textColor = Colors.white,
    int durationSeconds = 4}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: durationSeconds),
      backgroundColor: color,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: textColor,
          ),
          const SizedBox(width: AppMargins.M),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          )
        ],
      )));
}
