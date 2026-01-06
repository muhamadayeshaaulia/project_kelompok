import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AyeshaProfilPage extends StatelessWidget {
  const AyeshaProfilPage({super.key});
  final String ayeshaDocId = "6JozUEKn8fMzDjoq4ZyHtwqm8IP2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Profil Developer"),
        backgroundColor: const Color.fromRGBO(255, 192, 45, 1),
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}