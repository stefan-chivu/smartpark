import 'package:easy_park/screens/auth/login_page.dart';
import 'package:easy_park/screens/home/home.dart';
import 'package:easy_park/services/auth.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool showHome;
  const CustomAppBar({Key? key, this.showHome = true}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.Yellow,
      toolbarHeight: 50,
      leading: showHome
          ? IconButton(
              icon: const Icon(
                Icons.home,
                size: 24,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            )
          : Container(),
      actions: [
        ElevatedButton.icon(
          onPressed: (() async {
            await AuthService().signOut();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          }),
          icon: const Icon(Icons.exit_to_app),
          label: Text("Sign-out"),
          style: ElevatedButton.styleFrom(

              // padding: const EdgeInsets.all(12),
              // shape: new RoundedRectangleBorder(
              //   borderRadius: new BorderRadius.circular(20.0),
              // ),
              ),
        ),
      ],
    );
  }
}
