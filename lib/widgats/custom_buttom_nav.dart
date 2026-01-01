import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/following_page.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/screen/info_page.dart';
import 'package:project_kelompok/screen/profile_page.dart';
import 'package:project_kelompok/screen/camera_page.dart'; // Pastikan import ini ada

class CustomButtomNav extends StatelessWidget {
  final int currentIndex;
  const CustomButtomNav({super.key, required this.currentIndex});

  // --- LOGIKA BUKA KAMERA & POPUP ---
  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Mulai Memotret",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pilihan 2 Frame
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Tutup popup
                    _openCamera(context, 2); // Buka kamera 2 frame
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue[100],
                        child: const Icon(Icons.filter_2, color: Colors.blue, size: 30),
                      ),
                      const SizedBox(height: 8),
                      const Text("2 Frame", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Pilihan 4 Frame
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Tutup popup
                    _openCamera(context, 4); // Buka kamera 4 frame
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.purple[100],
                        child: const Icon(Icons.filter_4, color: Colors.purple, size: 30),
                      ),
                      const SizedBox(height: 8),
                      const Text("4 Frame", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper untuk Navigasi ke CameraPage
  void _openCamera(BuildContext context, int count) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage(photoCount: count)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, 'Home', 0),
            _buildNavItem(context, Icons.people, 'People', 1),
            
            // --- TOMBOL KAMERA TENGAH ---
            GestureDetector(
              onTap: () {
                // PANGGIL FUNGSI POPUP DI SINI
                _showCameraOptions(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.yellow[700],
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 25),
                  )
                ],
              ),
            ),
            // ---------------------------

            _buildNavItem(context, Icons.info, 'Info', 2),
            _buildNavItem(context, Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    bool isActive = index == currentIndex;
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        if (isActive) return;
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const InfoAplikasiPage()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FollowingPage()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.yellow[700] : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.yellow[700] : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}