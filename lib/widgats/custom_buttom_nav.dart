import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/home_page.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildNavItem(context, Icons.home, 'Home', 0),
                _buildNavItem(context, Icons.people, 'People', 1),
              ],
            ),
            Row(
              children: [
                _buildNavItem(context, Icons.info, 'Info', 2),
                _buildNavItem(context, Icons.person, 'Profile',3),
              ],
            ),
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
    return MaterialButton(minWidth: 40, onPressed: () {
      if (isActive) return;
      if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
        } else if (index == 3) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
        }
    }, child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.yellow[700] : Colors.grey,
        ),
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
  
