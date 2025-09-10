import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddFoodCategories extends StatefulWidget {
  const AddFoodCategories({super.key});

  @override
  State<AddFoodCategories> createState() => _AddFoodCategoriesState();
}

class _AddFoodCategoriesState extends State<AddFoodCategories> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  XFile? _iconFile;
  bool _busy = false;

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _iconFile = picked);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_iconFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pick a category icon')));
      return;
    }

    setState(() => _busy = true);
    try {
      // Prepare Firestore doc
      final col = FirebaseFirestore.instance.collection('categories');
      final docRef = col.doc(); // generate id now for storage path

      // Read file bytes
      final Uint8List bytes = await _iconFile!.readAsBytes();
      final ext = _iconFile!.name.split('.').last.toLowerCase();
      final contentType = (ext == 'png')
          ? 'image/png'
          : (ext == 'jpg' || ext == 'jpeg')
              ? 'image/jpeg'
              : 'application/octet-stream';

      // Upload to Storage
      final path = 'category_icons/${docRef.id}.$ext';
      final task = await FirebaseStorage.instance
          .ref(path)
          .putData(bytes, SettableMetadata(contentType: contentType));
      final iconUrl = await task.ref.getDownloadURL();

      // Current user (optional)
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Write Firestore doc
      await docRef.set({
        'name': _nameCtrl.text.trim(),
        'iconUrl': iconUrl,
        'storagePath': path,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
        'active': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Category saved')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconPreview = _iconFile == null
        ? const CircleAvatar(radius: 36, child: Icon(Icons.image))
        : CircleAvatar(
            radius: 36, backgroundImage: Image.network(_iconFile!.path).image);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Food Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter category name'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  iconPreview,
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : _pickIcon,
                    icon: const Icon(Icons.upload),
                    label: const Text('Pick Icon'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
