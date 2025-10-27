import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class CalendarInput extends StatelessWidget {
  final String hinttext;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool isRequired;
  final DateTime? defaultDate;

  const CalendarInput({
    super.key,
    required this.hinttext,
    required this.controller,
    this.onChanged,
    this.isRequired = false,
    this.defaultDate,
  });
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: defaultDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      controller.text = formattedDate;
      if (onChanged != null) onChanged!(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        hintText: hinttext,
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
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
