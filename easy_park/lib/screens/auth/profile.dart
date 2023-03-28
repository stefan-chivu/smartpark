import 'package:easy_park/services/isar.dart';
import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:easy_park/ui_components/custom_nav_bar.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:easy_park/ui_components/profile_picture.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showHome: true),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [ProfilePicture()],
            ),
            const Padding(padding: EdgeInsets.all(AppMargins.XS)),
            IsarService.isarUser.isAdmin
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.verified_user,
                        color: AppColors.sandyBrown,
                      ),
                      Text(' ADMIN')
                    ],
                  )
                : Container(),
            const Padding(padding: EdgeInsets.all(AppMargins.XS)),
            CustomTextField(
              label: 'E-mail',
              enabled: false,
              controller:
                  TextEditingController(text: IsarService.isarUser.email),
            ),
            const Padding(padding: EdgeInsets.all(AppMargins.S)),
          ]),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
