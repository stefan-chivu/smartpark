import 'package:easy_park/screens/auth/login_page.dart';
import 'package:easy_park/screens/auth/onboarding_license_plate.dart';
import 'package:easy_park/services/isar.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

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
    if (IsarService.isarUser.uid.isNotEmpty) {
      if (IsarService.isarUser.onboardingComplete) {
        return const Home();
      }
      return const OnboardingLicensePlate();
    } else {
      return const LoginPage();
    }
  }
}
