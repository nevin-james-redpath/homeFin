import 'package:flutter/material.dart';

class Dropdownforminput extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String?> onChanged;

  const Dropdownforminput({
    super.key,
    required this.label,
    required this.options,
    this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: initialValue ?? (options.isNotEmpty ? options.first : null),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(255, 218, 209, 235),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      isExpanded: false,
      isDense: true,

      dropdownColor: const Color.fromARGB(255, 218, 209, 235),
      icon: const Icon(Icons.arrow_drop_down),
      items: options
          .map((opt) => DropdownMenuItem<String>(value: opt, child: Text(opt)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
