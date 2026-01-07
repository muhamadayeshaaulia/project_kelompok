import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RozakDetailPage extends StatelessWidget {
  const RozakDetailPage({super.key});

  final String myUid = "BQdVH5ZOp5ObKtz3xjimt62DmNA2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(myUid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Data Profil Belum Ada",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "UID: $myUid",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            return Column(
              children: [
                const SizedBox(height: 60),
                _buildHeader(data),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Informasi Pribadi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3192),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDetailItem(
                            Icons.badge,
                            "NIM",
                            data['nim'] ?? "-",
                          ),
                          _buildDetailItem(
                            Icons.class_,
                            "Kelas",
                            data['kelas'] ?? "-",
                          ),
                          _buildDetailItem(
                            Icons.email,
                            "Email",
                            data['email'] ?? "-",
                          ),
                          _buildDetailItem(
                            Icons.phone,
                            "No. HP",
                            data['no_hp'] ?? "-",
                          ),
                          _buildDetailItem(
                            Icons.home,
                            "Alamat",
                            data['alamat'] ?? "-",
                          ),
                          _buildDetailItem(
                            Icons.link,
                            "Sosial Media",
                            data['sosmed_link'] ?? "-",
                            isLink: true,
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 10),

                          const Text(
                            "Tentang Saya",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              data['keterangan'] ?? "Tidak ada deskripsi.",
                              style: const TextStyle(
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildHeader(Map<String, dynamic> data) {
  String? photoUrl = data['photo_url'];

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white24,
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
              ? NetworkImage(photoUrl)
              : null,
          child: (photoUrl == null || photoUrl.isEmpty)
              ? const Icon(Icons.person, size: 60, color: Colors.white)
              : null,
        ),
      ),
      const SizedBox(height: 15),
      Text(
        data['nama'] ?? "User",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          data['role'] ?? "Mahasiswa",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget _buildDetailItem(
  IconData icon,
  String label,
  String value, {
  bool isLink = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2E3192), size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isLink ? Colors.blue : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
