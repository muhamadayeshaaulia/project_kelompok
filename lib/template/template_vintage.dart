import 'dart:io';

import 'package:flutter/material.dart';

class TemplateVintage extends StatefulWidget {
  final List<File>? initialImages;

  const TemplateVintage({super.key, this.initialImages});

  @override
  State<TemplateVintage> createState() => _TemplateVintageState();
}

class _TemplateVintageState extends State<TemplateVintage> {
  Color _frameColor = const Color(0xFFFDF5E6);

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
