import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project_kelompok/screen/splash_screen.dart';

import 'package:flutter/material.dart';

class MyPage4 extends StatefulWidget {
  const MyPage4({super.key});

  @override
  State<MyPage4> createState() => _MyPage4State();
}

class _MyPage4State extends State<MyPage4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              // Pastikan kamu punya file animasi baru, misal tentang sharing/social media
              child: Lottie.asset(
                'assets/animations/SocialMedia.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.share, size: 100, color: Colors.blue);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Bagikan Keseruanmu \n Upload langsung ke Media Sosial dan biarkan dunia melihat senyum terbaikmu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
