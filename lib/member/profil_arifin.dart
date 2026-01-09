import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArifinProfilPage extends StatelessWidget {
  const ArifinProfilPage({super.key});
  
  final String arifinDocId = "lpFLoTHeFTPRtfoESKnFoGzO3a42";

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 380.0;
    final double contentStartPos = 340.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(),
    );
  }
}