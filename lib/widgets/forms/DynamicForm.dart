import 'dart:io';

import 'package:flutter/material.dart';
import 'package:homefin/models/formFieldModel.dart';
import 'package:homefin/widgets/inputs/calendarInput.dart';
import 'package:homefin/widgets/inputs/dropdownFormInput.dart';
import 'package:homefin/widgets/inputs/imageUploadInput.dart';
import 'package:homefin/widgets/inputs/numberFormatInput.dart';
import 'package:homefin/widgets/inputs/textFormInput.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DynamicForm extends StatefulWidget {
  final List<FormFieldModel> fields;
  final Function(Map<String, dynamic>) onSubmit;

  const DynamicForm({super.key, required this.fields, required this.onSubmit});

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final Map<String, dynamic> _formValues = {};
  final picker = ImagePicker();
  final supabase = Supabase.instance.client;
  final Map<String, String?> _formErrors = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _formValues[field.keyName] = field.value ?? '';
    }
  }

  bool _validateForm() {
    bool isValid = true;
    _formErrors.clear();

    for (var field in widget.fields) {
      final value = _formValues[field.keyName];
      if (field.isRequired &&
          (value == null || value.toString().trim().isEmpty)) {
        _formErrors[field.keyName] = '${field.label} is required';
        isValid = false;
      }
    }

    setState(() {}); // refresh to show errors
    return isValid;
  }

  Future<void> _pickAndUploadImage(String keyName) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
    final storagePath = 'uploads/$fileName';

    try {
      await supabase.storage.from('images').upload(storagePath, file);
      final publicUrl = supabase.storage
          .from('images')
          .getPublicUrl(storagePath);
      setState(() => _formValues[keyName] = publicUrl);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // consistent outer padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...widget.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: _buildField(field),
              );
            }).toList(),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Save', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  if (_validateForm()) {
                    final cleanedValues = Map<String, dynamic>.from(_formValues)
                      ..removeWhere((k, v) => v == null || v == '');
                    widget.onSubmit(cleanedValues);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fix required fields'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(FormFieldModel field) {
    switch (field.type) {
      case 'number':
        final controller = TextEditingController(
          text: field.value?.toString() ?? '',
        );
        return numberFormatInput(
          hinttext: field.label,
          controller: controller,
          onChanged: (v) =>
              _formValues[field.keyName] = double.tryParse(v) ?? 0,
        );

      case 'dropdown':
        final defaultValue = field.options?.first;
        if (_formValues[field.keyName] == '' && defaultValue != null) {
          _formValues[field.keyName] = defaultValue;
        }

        return Dropdownforminput(
          label: field.label,
          options: field.options ?? [],
          initialValue: _formValues[field.keyName],
          onChanged: (v) => _formValues[field.keyName] = v,
        );

      case 'date':
        final dateController = TextEditingController(
          text:
              field.value ??
              (field.defaultDate != null
                  ? DateFormat('yyyy-MM-dd').format(field.defaultDate!)
                  : ''),
        );
        return CalendarInput(
          hinttext: field.label,
          controller: dateController,
          isRequired: field.isRequired,
          onChanged: (v) => _formValues[field.keyName] = v,
          defaultDate: field.defaultDate,
        );

      case 'image':
        final imageUrl = _formValues[field.keyName];
        return ImageUploadInput(
          label: field.label,
          storageBucket: 'propertyimages', // your Supabase storage bucket
          initialUrl: _formValues[field.keyName],
          onUploaded: (url) {
            _formValues[field.keyName] = url;
          },
        );

      default:
        final controller = TextEditingController(
          text: field.value?.toString() ?? '',
        );
        return Textforminput(
          hinttext: field.label,
          controller: controller,
          onChanged: (v) => _formValues[field.keyName] = v,
        );
    }
  }
}
