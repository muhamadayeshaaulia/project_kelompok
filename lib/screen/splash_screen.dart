import 'package:flutter/material.dart';

void main() {
  runApp(MySplashScreen());
}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.yellow,
            child: Center(
              child: Image.asset(
                'assets/images/splash_logo.png',
                width: 300,
              ),
            ),
          )
        ],
      ),
    );
  }
}