import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadInput extends StatefulWidget {
  final String label;
  final String storageBucket; // e.g., 'images'
  final String? initialUrl;
  final ValueChanged<String> onUploaded; // callback with URL

  const ImageUploadInput({
    super.key,
    required this.label,
    required this.storageBucket,
    required this.onUploaded,
    this.initialUrl,
  });

  @override
  State<ImageUploadInput> createState() => _ImageUploadInputState();
}

class _ImageUploadInputState extends State<ImageUploadInput> {
  final picker = ImagePicker();
  final supabase = Supabase.instance.client;
  String? _imageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialUrl;
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    final file = File(picked.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
    final storagePath = 'uploads/$fileName';
    print('$file $fileName $storagePath');
    try {
      await supabase.storage
          .from(widget.storageBucket)
          .upload(storagePath, file);
      final publicUrl = supabase.storage
          .from(widget.storageBucket)
          .getPublicUrl(storagePath);

      setState(() {
        _imageUrl = publicUrl;
        _isUploading = false;
      });

      widget.onUploaded(publicUrl);
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        if (_imageUrl != null && _imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(_imageUrl!, height: 140, fit: BoxFit.cover),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.image_outlined),
          label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
          onPressed: _isUploading ? null : _pickAndUploadImage,
        ),
      ],
    );
  }
}
