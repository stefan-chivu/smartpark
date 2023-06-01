import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? errorMsg;
  const ErrorPage({super.key, this.errorMsg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          height: AppMargins.L,
        ),
        Image.asset(
          "assets/images/error.png",
          width: 300,
        ),
        const Padding(
            padding: EdgeInsets.all(AppMargins.L),
            child: Text(
              "We've run into some issues, please try again later",
              style: TextStyle(fontSize: AppFontSizes.L),
              textAlign: TextAlign.center,
            )),
        Text(errorMsg ?? "")
      ]),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
