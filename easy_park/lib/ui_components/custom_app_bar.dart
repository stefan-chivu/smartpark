import 'package:easy_park/screens/home/home.dart';
import 'package:easy_park/services/auth.dart';
import 'package:easy_park/services/isar.dart';
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
        IsarService.getAdminStatus()
            ? MenuButton(
                icon: Icons.add_location_alt_outlined,
                text: "Add sensor",
                onTap: () async {
                  Navigator.pushNamed(context, '/add-sensor');
                })
            : Container(),
        const Padding(padding: EdgeInsets.all(AppMargins.XS)),
        MenuButton(
            icon: Icons.exit_to_app,
            text: " Sign-out",
            onTap: () async {
              await AuthService().signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushNamed(context, '/');
            }),
        const Padding(padding: EdgeInsets.all(AppMargins.XS))
      ],
    );
  }
}
