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
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(ayeshaDocId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text("Gagal memuat data developer."));
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSpecialCard(
                      nama: data['nama'] ?? "Nama Tidak Ada",
                      realName: data['nama_lengkap'] ?? "-",
                      nim: data['nim'] ?? "-",
                      role: data['role'] ?? "Developer",
                      alamat: data['alamat'] ?? "-",
                      bio: data['keterangan'] ?? "Tidak ada bio.",
                      kelas: data['kelas'] ?? "-",
                      email: data['email'] ?? "-",
                      noHp: data['no_hp'] ?? "-",
                      warna: Colors.yellow.shade100,
                      iconColor: Colors.orange,
                      photoUrl: data['photo_url'],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialCard({
    required String nama,
    required String realName,
    required String nim,
    required String role,
    required String alamat,
    required String bio,
    required String kelas,
    required String email,
    required String noHp,
    required Color warna,
    required Color iconColor,
    String? photoUrl,
  }) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: warna,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
