import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project_kelompok/screen/splash_screen.dart';

class MyPage5 extends StatefulWidget {
  const MyPage5({super.key});

  @override
  State<MyPage5> createState() => _MyPage5State();
}

class _MyPage5State extends State<MyPage5> {
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
              child: Lottie.asset(
                'assets/animations/DigitalCamera.json',
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
                'Ayo Ambil MomenMu \n Hari Mu adalah Kebahagianmu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(isActive: false),
                _buildDot(isActive: false),
                _buildDot(isActive: false),
                _buildDot(isActive: true),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MySplashScreen(nextRoute: '/page1'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Mulai Sekarang",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.blue[100],
      ),
    );
  }
}
