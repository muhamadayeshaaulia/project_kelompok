import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/explor.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/screen/info_page.dart';
import 'package:project_kelompok/screen/profile_page.dart';
import 'package:project_kelompok/screen/camera_page.dart';

class CustomButtomNav extends StatelessWidget {
  final int currentIndex;
  const CustomButtomNav({super.key, required this.currentIndex});

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
                _buildCameraOption(
                  context,
                  icon: Icons.filter_2,
                  label: "Classic 2",
                  color: Colors.blue,
                  onTap: () => _openCamera(context, 2, 'classic'),
                ),
                _buildCameraOption(
                  context,
                  icon: Icons.filter_4,
                  label: "Classic 4",
                  color: Colors.purple,
                  onTap: () => _openCamera(context, 4, 'classic'),
                ),
                _buildCameraOption(
                  context,
                  icon: Icons.camera_roll,
                  label: "Vintage",
                  color: Colors.green,
                  onTap: () => _openCamera(context, 2, 'vintage'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildCameraOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _openCamera(BuildContext context, int count, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          photoCount: count,
          templateType: type,
        ),
      ),
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
            _buildNavItem(context, Icons.explore_outlined, 'Explore', 1),
            GestureDetector(
              onTap: () => _showCameraOptions(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.yellow[700],
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
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
        Widget page;
        switch (index) {
          case 0:
            page = const MyHomePage();
            break;
          case 1:
            page = const ExplorPage();
            break;
          case 2:
            page = const InfoAplikasiPage();
            break;
          case 3:
            page = const ProfilePage();
            break;
          default:
            page = const MyHomePage();
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
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
