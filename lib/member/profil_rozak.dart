import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfileDetailPage extends StatelessWidget {
  const MyProfileDetailPage({super.key});

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
}
