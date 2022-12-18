import 'package:easy_park/ui_components/custom_app_bar.dart';
import 'package:flutter/material.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showHome: true),
      body: Column(),
    );
  }
}
