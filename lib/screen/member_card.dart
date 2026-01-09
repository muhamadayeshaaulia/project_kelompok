import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/member/profil_ayesha.dart';
import 'package:project_kelompok/member/profil_ilham.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/member/profil_rozak.dart';

class MemberCardPage extends StatelessWidget {
  const MemberCardPage({super.key});
  final String ayeshaDocId = "6JozUEKn8fMzDjoq4ZyHtwqm8IP2";
  final String ilhamDocId = "VAGSZaUD4TU5bV4zNXMENBKU2Tg1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tim Developer"),
        backgroundColor: const Color.fromRGBO(255, 192, 45, 1),
        elevation: 0,
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
              const SizedBox(height: 20),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(ayeshaDocId)
                    .snapshots(),
                builder: (context, snapshot) {
                  String nama = "Loading...";
                  String nim = "...";
                  String role = "...";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    nama = data['nama'] ?? "Muhamad Ayesha Aulia";
                    nim = data['nim'] ?? "1123150188";
                    role = data['role'] ?? "Frontend Developer";
                  }

                  return _buildMemberCard(
                    context: context,
                    nama: nama,
                    nim: "NIM: $nim",
                    role: role,
                    warna: Colors.pink.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AyeshaProfilPage(),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 15),
              _buildMemberCard(
                context: context,
                nama: "Muhammad Abdul Rozak",
                nim: "NIM: 1123150006",
                role: "Backend",
                warna: Colors.blue.shade200,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RozakDetailPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(ilhamDocId)
                    .snapshots(),
                builder: (context, snapshot) {
                  String nama = "Muhammad Ilham Maulana"; 
                  String nim = "1123150141";
                  String role = "UI/UX Designer";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    nama = data['nama'] ?? nama;
                    nim = data['nim'] ?? nim;
                    role = data['role'] ?? role;
                  }

                  return _buildMemberCard(
                    context: context,
                    nama: nama,
                    nim: "NIM: $nim",
                    role: role,
                    warna: Colors.green.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IlhamProfilPage(),
                        ),
                      );
                    },
                  );
                },
              ),

              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(ilhamDocId)
                    .snapshots(),
                builder: (context, snapshot) {
                  String nama = "Muhammad Arifin"; 
                  String nim = "1123150141";
                  String role = "UI/UX Designer";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    nama = data['nama'] ?? nama;
                    nim = data['nim'] ?? nim;
                    role = data['role'] ?? role;
                  }

                  return _buildMemberCard(
                    context: context,
                    nama: nama,
                    nim: "NIM: $nim",
                    role: role,
                    warna: Colors.green.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IlhamProfilPage(),
                        ),
                      );
                    },
                  );
                },
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
  return Card(
    elevation: 4,
    shadowColor: warna.withOpacity(0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [warna, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 35,
                color: warna.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nim,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.black54,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
