import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/splash_screen.dart';
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
        builder: (context) => CameraPage(photoCount: count, templateType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home_rounded, 'Home', 0, '/home'),
            _buildNavItem(
              context,
              Icons.explore_rounded,
              'Explore',
              1,
              '/explor',
            ),
            GestureDetector(
              onTap: () => _showCameraOptions(context),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.yellow[700],
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
            _buildNavItem(context, Icons.info_rounded, 'Info', 2, '/info'),
            _buildNavItem(
              context,
              Icons.person_rounded,
              'Profile',
              3,
              '/profile',
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
    String routeName,
  ) {
    bool isActive = index == currentIndex;
    return InkWell(
      onTap: () {
        if (isActive) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MySplashScreen(
                  nextRoute:
                      routeName,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.yellow[700] : Colors.grey[400],
              size: isActive ? 28 : 24,
            ),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.yellow[700] : Colors.grey[400],
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
