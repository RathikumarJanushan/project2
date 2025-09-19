// lib/add_category.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

const kPrimary = Color(0xFFA63334);
const kBg = Color(0xFF2A2928);
const kMuted = Color(0xFFB7B7B6);
const kWhite = Color(0xFFFFFFFF);

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});
  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  Uint8List? _iconBytes;
  String? _iconFileName;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final x = await p.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    setState(() {
      _iconBytes = bytes;
      _iconFileName = x.name;
    });
  }

  String _guessContentType(String? filename) {
    final ext = filename?.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/png';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_iconBytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pick a category image')));
      return;
    }

    final name = _nameCtrl.text.trim();
    if (name.contains('/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot contain "/"')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final safeBase =
          (_iconFileName ?? name).replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeBase';
      final ref = FirebaseStorage.instance.ref('menu_category_icons/$fileName');

      await ref.putData(
        _iconBytes!,
        SettableMetadata(contentType: _guessContentType(_iconFileName)),
      );
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('menu_category')
          .doc(name) // doc id = category name
          .set({
        'name': name,
        'iconUrl': url,
        'iconFileName': fileName,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved: $name')));
      _nameCtrl.clear();
      setState(() {
        _iconBytes = null;
        _iconFileName = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmAndDelete(DocumentSnapshot doc) async {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final name = doc.id;
    final iconFileName = (data['iconFileName'] as String?) ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('This will remove "$name" and its image.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _saving = true);
    try {
      if (iconFileName.isNotEmpty) {
        final ref =
            FirebaseStorage.instance.ref('menu_category_icons/$iconFileName');
        try {
          await ref.delete();
        } catch (_) {
          // ignore not-found or permission errors and continue with doc delete
        }
      }
      await doc.reference.delete();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Deleted: $name')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImg = _iconBytes != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Category'),
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
      ),
      backgroundColor: kBg,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Form card ----
          Card(
            color: kWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: kMuted, width: 1),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAE6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kMuted),
                      ),
                      alignment: Alignment.center,
                      child: hasImg
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _iconBytes!,
                                height: 140,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image, size: 36, color: kPrimary),
                                SizedBox(height: 8),
                                Text('Tap to choose category image'),
                                SizedBox(height: 4),
                                Text('(PNG with transparency preferred)',
                                    style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: _dec('Category name'),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Required';
                      if (t.contains('/')) return 'Cannot contain "/"';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: kWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saving ? null : _save,
                      child: Text(
                        _saving ? 'Saving…' : 'Save Category',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  if (_saving)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ---- Table card ----
          Card(
            color: kWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: kMuted, width: 1),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categories',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('menu_category')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ));
                        }
                        if (snap.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Error: ${snap.error}'),
                          );
                        }
                        final docs = snap.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No categories yet.'),
                          );
                        }

                        // Horizontal + vertical scrollable table
                        // REPLACE the current "return SingleChildScrollView(...)" block
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 680),
                            child: DataTable(
                              headingRowHeight: 44,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 72, // ensure max >= min
                              columns: const [
                                DataColumn(label: Text('Icon')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Created')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: docs.map((d) {
                                final m =
                                    (d.data() as Map<String, dynamic>?) ?? {};
                                final name = (m['name'] as String?) ?? d.id;
                                final iconUrl = (m['iconUrl'] as String?) ?? '';
                                final ts = m['createdAt'];
                                DateTime? dt;
                                if (ts is Timestamp) dt = ts.toDate();
                                final createdStr = dt != null
                                    ? '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
                                        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                                    : '—';

                                return DataRow(cells: [
                                  DataCell(
                                    iconUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Image.network(
                                              iconUrl,
                                              height: 40,
                                              width: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                      Icons.broken_image),
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported),
                                  ),
                                  DataCell(Text(name)),
                                  DataCell(Text(createdStr)),
                                  DataCell(
                                    IconButton(
                                      tooltip: 'Delete',
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _confirmAndDelete(d),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFFAE6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.4),
        ),
      );
}
