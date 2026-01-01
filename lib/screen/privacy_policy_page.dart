import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kebijakan Privasi"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Kebijakan Privasi",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Text(
              "Kami menghargai privasi pengguna aplikasi ini. "
              "Kebijakan privasi ini menjelaskan bagaimana kami "
              "mengumpulkan, menggunakan, dan melindungi informasi pengguna.",
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
            Text(
              "Informasi yang Dikumpulkan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "• Nama dan alamat email\n"
              "• Foto profil pengguna\n"
              "• Data aktivitas penggunaan aplikasi",
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
            Text(
              "Penggunaan Informasi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "• Autentikasi dan pengelolaan akun\n"
              "• Meningkatkan kualitas layanan\n"
              "• Keamanan dan pengembangan aplikasi",
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),
            Text(
              "Keamanan Data",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Kami menjaga keamanan data pengguna dan tidak "
              "membagikan informasi kepada pihak ketiga tanpa izin, "
              "kecuali diwajibkan oleh hukum.",
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 24),
            Text(
              "Dengan menggunakan aplikasi ini, Anda menyetujui "
              "kebijakan privasi yang berlaku.",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
