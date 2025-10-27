import 'package:flutter/material.dart';

class numberFormatInput extends StatelessWidget {
  final String hinttext;
  final TextEditingController controller;
  final bool obscuretext;
  final Function(String)? onChanged;
  final bool isRequired;

  const numberFormatInput({
    super.key,
    required this.hinttext,
    required this.controller,
    this.obscuretext = false,
    this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscuretext,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hinttext,
        filled: true,
        fillColor: const Color.fromARGB(255, 218, 209, 235),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
      ),
    );
  }
}
