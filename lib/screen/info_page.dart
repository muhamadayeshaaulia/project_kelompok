import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/screen/member_card.dart';
import 'package:project_kelompok/screen/privacy_policy_page.dart';
import 'package:project_kelompok/screen/terms_conditions_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoAplikasiPage extends StatelessWidget {
  const InfoAplikasiPage({super.key});

  Future<void> _launchEmail() async {
    final String email = 'developer@gmail.com';
    final String subject = 'Tanya Seputar Aplikasi';

    final Uri gmailUrl = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject'
    );

    try {
      await launchUrl(
        gmailUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Gagal membuka Gmail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Info Aplikasi"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔹 Logo / Icon Aplikasi
          Center(
            child: Column(
              children: const [
                Icon(Icons.apps, size: 80, color: Colors.purple),
                SizedBox(height: 12),
                Text(
                  "Nama Aplikasi",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 🔹 Deskripsi Aplikasi
          const Text(
            "Tentang Aplikasi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            leading: Icon(Icons.developer_mode),
            title: Text("Developer"),
            subtitle: Text("Kelompok Flutter"),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MemberCardPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Email"),
            subtitle: const Text("developer@gmail.com"),
            trailing: const Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: Colors.grey
            ), 
            onTap: _launchEmail, 
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Kebijakan Privasi"),
            subtitle: const Text("Lihat kebijakan privasi"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Syarat & Ketentuan"),
            subtitle: const Text("Lihat syarat dan ketentuan"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsConditionsPage(),
                ),
              );
            },
          ),

          /// 🔹 Jarak aman dari Bottom Nav
          const SizedBox(height: 80),
        ],
      ),

      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }
}
