class FormFieldModel {
  final String label;
  final String keyName;
  final String type;
  final List<String>? options;
  final bool isRequired;
  final dynamic? value;
  final DateTime? defaultDate;

  FormFieldModel({
    required this.label,
    required this.keyName,
    required this.type,
    this.options,
    required this.isRequired,
    this.value,
    this.defaultDate,
  });
}
