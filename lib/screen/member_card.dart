import 'package:flutter/material.dart';

class MemberCardPage extends StatelessWidget {
  const MemberCardPage({super.key});

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
                  "Anggota Kelompok 1",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              // 3. Muhamad Ayesha Aulia
              _buildMemberCard(
                nama: "Muhamad Ayesha Aulia",
                nim: "NIM: 1123150188",
                role: "Frontend Developer",
                warna: Colors.pink.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMemberCard({
  required String nama,
  required String nim,
  required String role,
  required Color warna,
}) {
  return Card(
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
          Column(
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
        ],
      ),
    ),
  );
}
