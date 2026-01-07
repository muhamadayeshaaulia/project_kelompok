import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/splash_screen.dart';

class MyPage2 extends StatelessWidget {
  const MyPage2({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/logo/logo-global.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Selamat datang di aplikasi Booth-Art \n Aplikasi ini di buat bertujuan untuk tugas UAS pembelajaran Aplikasi mobile menggunakan flutter dan firebase',
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MySplashScreen(nextRoute: '/screen2'),
                    ),
                    (Route<dynamic> route) => false,
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
    );
  }
}
