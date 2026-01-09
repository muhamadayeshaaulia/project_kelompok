import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class arifinProfilPage extends StatelessWidget {
  const arifinProfilPage({super.key});
  final String arifinDocId = "lpFLoTHeFTPRtfoESKnFoGzO3a42";
  
  @override
  Widget build(BuildContext context) {
     final double headerHeight = 400.0;
     final double contentStartPos = 360.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            shape: BoxShape.circle,
            ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(arifinDocId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data tidak ditemukan"));
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String nama = data['nama'] ?? "Nama";
          String role = data['role'] ?? "Developer";
          String? photoUrl = data['photo_url'];
          return Stack(
            children: [
              Positioned(
                top: 0,