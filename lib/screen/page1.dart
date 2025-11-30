import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/home_screen.dart';
import 'package:project_kelompok/screen/splash_screen.dart';

class MyPage1 extends StatelessWidget {
  const MyPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              image: DecorationImage(
                image: AssetImage('assets/images/images1.webp'),
                fit: BoxFit.cover,
              ),
            ),
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
                          const MySplashScreen(nextRoute: '/home'),
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
