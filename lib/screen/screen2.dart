import 'package:flutter/material.dart';

class MyPage3 extends StatelessWidget {
  const MyPage3({super.key});

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
          
        ],
      ),
    );
  }
}
