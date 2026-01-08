import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project_kelompok/screen/screen3.dart';
import 'package:project_kelompok/screen/splash_screen.dart';

class MyPage3 extends StatelessWidget {
  const MyPage3({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: Lottie.asset(
                'assets/animations/CamerasP.json',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Tangkap Momentmu Lalu Abadikan \n Jadikan Setiap Moment mu diabadikan Untuk Dokumentasi Anak Cucu mu',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[100],
                    ),
                  ),
                ),
                SizedBox(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[100],
                    ),
                  ),
                ),
                SizedBox(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[100],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              child: SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MyPage4(), // Pastikan import MyPage4
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    "Next",
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
}
