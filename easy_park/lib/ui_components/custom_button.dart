import 'package:easy_park/ui_components/ui_specs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final bool isPrimary;
  final String text;
  final VoidCallback onPressed;
  const CustomButton(
      {Key? key,
      this.isPrimary = true,
      this.text = "",
      required this.onPressed})
      : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: TextStyle(fontSize: AppFontSizes.M),
          ),
          style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.all(AppMargins.S),
              minimumSize: Size(130, 45),
              primary: widget.isPrimary ? AppColors.Yellow : AppColors.DarkGray,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)))),
    );
  }
}
