import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/member/profil_ayesha.dart';

class MemberCardPage extends StatelessWidget {
  const MemberCardPage({super.key});
  final String ayeshaDocId = "6JozUEKn8fMzDjoq4ZyHtwqm8IP2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tim Developer"),
        backgroundColor: const Color.fromRGBO(255, 192, 45, 1),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Anggota Kelompok",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(ayeshaDocId)
                    .snapshots(),
                builder: (context, snapshot) {
                  String namaTampil = "Loading...";
                  String nimTampil = "...";
                  String roleTampil = "...";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    namaTampil = data['nama'] ?? "Muhamad Ayesha Aulia";
                    nimTampil = data['nim'] ?? "-";
                    roleTampil = data['role'] ?? "Developer";
                  }

                  return _buildMemberCard(
                    context: context,
                    nama: namaTampil,
                    nim: "NIM: $nimTampil",
                    role: roleTampil,
                    warna: Colors.pink.shade100,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AyeshaProfilePage(),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),
              _buildMemberCard(
                context: context,
                nama: "Muhammad Abdul Rozak",
                nim: "NIM: 1123150006",
                role: "Project Manager",
                warna: Colors.blue.shade100,
              ),
              const SizedBox(height: 10),
              _buildMemberCard(
                context: context,
                nama: "Muhammad Ilham Maulana",
                nim: "NIM: 1123150141",
                role: "UI/UX Designer",
                warna: Colors.green.shade100,
              ),
              const SizedBox(height: 10),
              _buildMemberCard(
                context: context,
                nama: "Muhammad Arifin",
                nim: "NIM: 1123150053",
                role: "Backend Developer",
                warna: Colors.orange.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMemberCard({
  required BuildContext context,
  required String nama,
  required String nim,
  required String role,
  required Color warna,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: 2,
      color: warna,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(nim),
                  Text(
                    role,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black54,
              ),
          ],
        ),
      ),
    ),
  );
}
