import 'package:easy_park/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class HomeWrapper extends StatefulWidget {
  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _uid;

  @override
  void initState() {
    super.initState();
    _uid = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('uid') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _uid,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              color: Colors.white,
              child: const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          default:
            if (snapshot.hasData) {
              if (snapshot.data != "") {
                return Home();
              } else {
                return LoginPage();
              }
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return LoginPage();
            }
        }
      },
    );
  }
}
