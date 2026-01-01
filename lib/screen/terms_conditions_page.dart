import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Syarat & Ketentuan"),
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
            _buildHeader(),

            const SizedBox(height: 20),

            _buildCard(
              icon: Icons.check_circle_outline,
              title: "Ketentuan Umum",
              content:
                  "Aplikasi ini digunakan untuk keperluan pribadi dan "
                  "tidak diperbolehkan untuk aktivitas yang melanggar hukum.",
            ),

            _buildCard(
              icon: Icons.person_outline,
              title: "Akun Pengguna",
              content:
                  "Pengguna bertanggung jawab atas keamanan akun dan "
                  "informasi yang diberikan dalam aplikasi.",
            ),

            _buildCard(
              icon: Icons.photo_camera,
              title: "Penggunaan Layanan",
              content:
                  "Fitur photobooth hanya boleh digunakan sesuai "
                  "dengan tujuan aplikasi dan tidak untuk disalahgunakan.",
            ),

            _buildCard(
              icon: Icons.block,
              title: "Larangan",
              content:
                  "Dilarang menggunakan aplikasi untuk menyebarkan "
                  "konten ilegal, merugikan pihak lain, atau melanggar "
                  "hak cipta.",
            ),

            _buildCard(
              icon: Icons.update,
              title: "Perubahan Ketentuan",
              content:
                  "Kami berhak mengubah syarat dan ketentuan sewaktu-waktu "
                  "tanpa pemberitahuan terlebih dahulu.",
            ),

            const SizedBox(height: 24),

            Center(
              child: Text(
                "Dengan menggunakan aplikasi ini,\n"
                "Anda dianggap telah membaca dan menyetujui\n"
                "seluruh syarat dan ketentuan yang berlaku.",
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

  /// ===== HEADER =====
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
          Icon(Icons.description, size: 40, color: Colors.black87),
          SizedBox(height: 12),
          Text(
            "Syarat & Ketentuan",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Harap membaca syarat dan ketentuan ini "
            "sebelum menggunakan aplikasi.",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// ===== CARD =====
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
