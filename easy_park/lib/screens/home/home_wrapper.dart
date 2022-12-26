import 'package:easy_park/screens/auth/login_page.dart';
import 'package:easy_park/services/isar.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class HomeWrapper extends StatefulWidget {
  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (IsarService.getUid() != "") {
      return const Home();
    } else {
      return const LoginPage();
    }
  }
}
