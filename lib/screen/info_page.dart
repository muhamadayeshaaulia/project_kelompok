import 'package:flutter/material.dart';

class InfoAplikasiPage extends StatelessWidget {
  const InfoAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Info Aplikasi"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Logo / Icon Aplikasi
            Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.apps,
                    size: 80,
                    color: Colors.purple,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Nama Aplikasi",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Versi 1.0.0",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🔹 Deskripsi Aplikasi
            const Text(
              "Tentang Aplikasi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Aplikasi ini dibuat untuk membantu pengguna dalam "
              "mengelola profil, mengikuti pengguna lain, serta "
              "memberikan pengalaman interaksi yang sederhana dan nyaman.",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),

            /// 🔹 Informasi Tambahan
            const Divider(),
            ListTile(
              leading: const Icon(Icons.developer_mode),
              title: const Text("Developer"),
              subtitle: const Text("Kelompok Flutter"),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: const Text("developer@email.com"),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Kebijakan Privasi"),
              subtitle: const Text("Lihat kebijakan privasi"),
              onTap: () {
                // navigasi ke halaman privacy policy
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text("Syarat & Ketentuan"),
              subtitle: const Text("Lihat syarat dan ketentuan"),
              onTap: () {
                // navigasi ke halaman terms
              },
            ),
          ],
        ),
      ),
    );
  }
}
