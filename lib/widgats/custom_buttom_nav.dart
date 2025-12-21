import 'package:flutter/material.dart';

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
                _buildNavItem(context, icon: Icons.home, index: 0),
                _buildNavItem(context, icon: Icons.people, index: 1),
              ],
            ),
            Row(
              children: [
                _buildNavItem(context, icon: Icons.info, index: 2),
                _buildNavItem(context, icon: Icons.person, index: 3),
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
    return MaterialButton(minWidth: 40, onPressed: () {});
  }
}
