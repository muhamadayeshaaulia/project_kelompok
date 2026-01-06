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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        
      ),
    );
  }
}