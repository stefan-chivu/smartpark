import 'package:easy_park/screens/auth/login_page.dart';
import 'package:easy_park/screens/home/home.dart';
import 'package:easy_park/screens/sensor/add_sensor.dart';
import 'package:easy_park/services/auth.dart';
import 'package:easy_park/ui_components/menu_button.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool showHome;
  const CustomAppBar({Key? key, this.showHome = true}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.slateGray,
      toolbarHeight: 50,
      leading: showHome
          ? MenuButton(
              icon: Icons.home,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
            )
          : Container(),
      actions: [
        MenuButton(
            icon: Icons.add_location_alt_outlined,
            text: "Add sensor",
            onTap: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddSensor()));
            }),
        Padding(padding: EdgeInsets.all(AppMargins.XS)),
        MenuButton(
            icon: Icons.exit_to_app,
            text: " Sign-out",
            onTap: () async {
              await AuthService().signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            }),
        Padding(padding: EdgeInsets.all(AppMargins.XS))
      ],
    );
  }
}
