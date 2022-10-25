import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_park/screens/home/home_wrapper.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyPark',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(primary: AppColors.DarkGray, secondary: AppColors.Yellow),
      ),
      home: HomeWrapper(),
    );
  }
}
