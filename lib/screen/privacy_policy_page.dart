import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Kebijakan Privasi"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFC02D), Color(0xFFFFE6A7)],
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
          children: [
            /// 🔹 Header
            _buildHeader(),

            const SizedBox(height: 20),

            /// 🔹 Informasi Dikumpulkan
            _buildCard(
              icon: Icons.info_outline,
              title: "Informasi yang Dikumpulkan",
              content:
                  "• Nama dan alamat email\n"
                  "• Foto profil pengguna\n"
                  "• Data aktivitas penggunaan aplikasi",
            ),

            /// 🔹 Penggunaan Informasi
            _buildCard(
              icon: Icons.settings,
              title: "Penggunaan Informasi",
              content:
                  "• Autentikasi dan pengelolaan akun\n"
                  "• Meningkatkan kualitas layanan\n"
                  "• Keamanan dan pengembangan aplikasi",
            ),

            /// 🔹 Keamanan Data
            _buildCard(
              icon: Icons.security,
              title: "Keamanan Data",
              content:
                  "Kami menjaga keamanan data pengguna dan tidak "
                  "membagikan informasi kepada pihak ketiga tanpa izin, "
                  "kecuali diwajibkan oleh hukum.",
            ),

            const SizedBox(height: 24),

            /// 🔹 Footer
            Center(
              child: Text(
                "Dengan menggunakan aplikasi ini,\n"
                "Anda menyetujui kebijakan privasi yang berlaku.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== WIDGET HEADER =====
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC02D), Color(0xFFFFF3D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.privacy_tip, size: 40, color: Colors.black87),
          SizedBox(height: 12),
          Text(
            "Kebijakan Privasi",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kami menghargai privasi pengguna dan berkomitmen "
            "untuk melindungi informasi pribadi Anda.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  /// ===== WIDGET CARD SECTION =====
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
