import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TemplateVintage extends StatefulWidget {
  final List<File>? initialImages;

  const TemplateVintage({super.key, this.initialImages});

  @override
  State<TemplateVintage> createState() => _TemplateVintageState();
}

class _TemplateVintageState extends State<TemplateVintage> {
  Color _frameColor = const Color(0xFFFDF5E6);

  final List<Color> _colorOptions = [
    const Color(0xFFFDF5E6), // Old Lace (Krem)
    const Color(0xFF2C2C2C), // Charcoal (Hitam Pudar)
    const Color(0xFF8D6E63), // Antique Bronze
    const Color(0xFF556B2F), // Dark Olive
    const Color(0xFF8FBC8F), // Dark Sea Green
    const Color(0xFFD2B48C), // Tan
    const Color(0xFFBC8F8F), // Rosy Brown
    const Color(0xFFA9A9A9), // Dark Gray
  ];

  final List<Uint8List?> _imageBytesList = List.filled(2, null);
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), actions: const []),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: []),
      ),
    );
  }
}
