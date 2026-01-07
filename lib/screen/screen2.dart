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
            ],
          ),
          SizedBox(height: 20),
          
        ],
      ),
    );
  }
}
