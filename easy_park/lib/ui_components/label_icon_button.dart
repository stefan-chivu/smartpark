import 'package:flutter/material.dart';

class LabelIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  final bool horizontal;
  final Color? color;
  final Color textColor;

  const LabelIconButton(
      {super.key,
      required this.icon,
      this.text = "",
      required this.onTap,
      this.horizontal = true,
      this.color,
      this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(15))),
            child: InkWell(
                enableFeedback: true,
                onTap: onTap,
                child: horizontal
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                color: textColor,
                              ),
                              const Padding(padding: EdgeInsets.all(3)),
                              Center(
                                  child: Text(
                                text,
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              ))
                            ]),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Icon(
                              icon,
                              color: textColor,
                            ),
                            // const Padding(padding: EdgeInsets.all(3)),
                            Center(
                                child: Text(
                              text,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            )),
                          ]))));
  }
}
