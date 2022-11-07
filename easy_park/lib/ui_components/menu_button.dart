import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  final bool horizontal;

  const MenuButton({
    super.key,
    required this.icon,
    this.text = "",
    required this.onTap,
    this.horizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: InkWell(
            enableFeedback: true,
            onTap: onTap,
            child: horizontal
                ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      icon,
                    ),
                    Center(child: Text(text))
                  ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(
                          icon,
                        ),
                        Center(child: Text(text)),
                      ])));
  }
}
