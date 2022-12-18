import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';

class UnsupportedPlatform extends StatelessWidget {
  const UnsupportedPlatform({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      const SizedBox(
        height: AppMargins.L,
      ),
      Image.asset(
        "assets/images/maintenance.png",
        width: 300,
      ),
      const Padding(
          padding: EdgeInsets.all(AppMargins.L),
          child: Text(
            "Uh oh! Looks like the page you're trying to reach isn't supported on this platform!",
            style: TextStyle(fontSize: AppFontSizes.L),
            textAlign: TextAlign.center,
          )),
    ]));
  }
}
