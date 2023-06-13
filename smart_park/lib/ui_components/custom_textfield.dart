import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isPassword;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? initialValue;
  final bool? enabled;
  const CustomTextField(
      {Key? key,
      required this.label,
      this.icon,
      this.isPassword = false,
      this.onChanged,
      this.validator,
      this.controller,
      this.inputFormatters,
      this.keyboardType,
      this.initialValue,
      this.enabled})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: TextFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(
              widget.icon,
              size: 24,
            ),
            labelText: widget.label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          obscureText: widget.isPassword,
          onChanged: widget.onChanged,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          controller: widget.controller,
          initialValue: widget.initialValue,
          enabled: widget.enabled),
    );
  }
}
