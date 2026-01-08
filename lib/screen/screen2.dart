import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project_kelompok/screen/screen3.dart'; // Pastikan ini mengarah ke MyPage4
import 'package:project_kelompok/screen/splash_screen.dart';

class MyPage3 extends StatelessWidget {
  const MyPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Animasi ---
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Lottie.asset(
                'assets/animations/CamerasP.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            // --- Teks Deskripsi ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Tangkap Momentmu Lalu Abadikan \n Jadikan Setiap Moment mu diabadikan Untuk Dokumentasi Anak Cucu mu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // --- Indikator (Dots) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(isActive: false), // Dot 1
                _buildDot(isActive: true), // Dot 2 (AKTIF)
                _buildDot(isActive: false), // Dot 3
                _buildDot(isActive: false), // Dot 4
              ],
            ),
            const SizedBox(height: 20),

            // --- Tombol Continue ---
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      // Pastikan MyPage4 sudah diimport dengan benar
                      MaterialPageRoute(builder: (context) => const MyPage4()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Gaya rounded
                    ),
                  ),
                  child: const Text(
                    "Continue", // Teks sesuai request
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

  // Helper agar kodingan dots lebih rapi & tidak duplikat
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
