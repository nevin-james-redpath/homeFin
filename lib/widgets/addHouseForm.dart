import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Addhouseform extends StatefulWidget {
  final void Function(String address) onSubmit;
  const Addhouseform({super.key, required this.onSubmit});

  @override
  State<Addhouseform> createState() => _AddhouseformState();
}

class _AddhouseformState extends State<Addhouseform> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Property Address'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(_addressController.text);
              }
            },
            child: const Text('Add Property'),
          ),
        ],
      ),
    );
  }
}
