import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.errorText,
    this.suffixIcon,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          errorText: errorText,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }
}
