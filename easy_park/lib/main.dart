import 'package:easy_park/screens/auth/login_page.dart';
import 'package:easy_park/screens/auth/profile.dart';
import 'package:easy_park/screens/auth/register_page.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/screens/sensor/add_sensor.dart';
import 'package:easy_park/screens/sensor/navigation_page.dart';
import 'package:easy_park/screens/sensor/payment_history_page.dart';
import 'package:easy_park/screens/sensor/spot_list.dart';
import 'package:easy_park/services/isar.dart';
import 'package:easy_park/services/location.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_park/screens/home/home_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await IsarService.openSchemas();
  await LocationService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EasyPark',
        theme: ThemeData(
          fontFamily: 'OpenSans',
          colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppColors.pineTree,
              secondary: AppColors.blueGreen,
              tertiary: AppColors.orangeYellow,
              outline: AppColors.slateGray,
              error: AppColors.orangeRed),
        ),
        routes: {
          '/': (context) => const HomeWrapper(),
          '/add-sensor': (context) => const AddSensor(),
          '/error': (context) => const ErrorPage(),
          '/history': (context) => const ParkingHistoryPage(),
          '/login': (context) => const LoginPage(),
          '/profile': (context) => const ProfilePage(),
          '/register': (context) => const RegisterPage(),
          '/spot-list': (context) => const ParkingSpotList(),
          '/navigate': (context) => const NavigationPage(),
        });
  }
}
