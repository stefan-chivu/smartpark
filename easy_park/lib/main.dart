import 'package:easy_park/screens/auth/login_page.dart';
import 'package:easy_park/screens/auth/register_page.dart';
import 'package:easy_park/screens/error.dart';
import 'package:easy_park/screens/sensor/add_sensor.dart';
import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_park/screens/home/home_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_park/services/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: Constants.firebaseWebApiKey,
            authDomain: Constants.firebaseWebAuthDomain,
            projectId: Constants.firebaseWebProjectId,
            storageBucket: Constants.firebaseWebStorageBucket,
            messagingSenderId: Constants.firebaseWebMessagingSenderId,
            appId: Constants.firebaseWebAppId,
            measurementId: Constants.firebaseWebMeasurementId));
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        '/': (context) => HomeWrapper(),
        '/error': (context) => const ErrorPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/add-sensor': (context) => const AddSensor(),
      },
    );
  }
}
