import 'package:flutter/material.dart';

class HomeMenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;

  const HomeMenuButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        enableFeedback: true,
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            icon,
            size: 70,
          ),
          Text(text),
        ]));
  }
}
