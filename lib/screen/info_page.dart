import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';

class InfoAplikasiPage extends StatelessWidget {
  const InfoAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text("Developer"),
            subtitle: Text("Kelompok Flutter"),
          ),
          const ListTile(
            leading: Icon(Icons.email),
            title: Text("Email"),
            subtitle: Text("developer@email.com"),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Kebijakan Privasi"),
            subtitle: const Text("Lihat kebijakan privasi"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Syarat & Ketentuan"),
            subtitle: const Text("Lihat syarat dan ketentuan"),
            onTap: () {},
          ),

          /// 🔹 Jarak aman dari Bottom Nav
          const SizedBox(height: 80),
        ],
      ),

      bottomNavigationBar: const CustomButtomNav(currentIndex: 2),
    );
  }
}
