import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/following_page.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/screen/info_page.dart';
import 'package:project_kelompok/screen/profile_page.dart';

class CustomButtomNav extends StatelessWidget {
  final int currentIndex;
  const CustomButtomNav({super.key, required this.currentIndex});

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
          GestureDetector(
            onTap: () {
              print('Buka Kamera');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.yellow[700],
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 25),
                )

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
