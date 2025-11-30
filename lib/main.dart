import 'package:flutter/material.dart';
import 'package:project_kelompok/screen/home_screen.dart';
import 'package:project_kelompok/screen/page1.dart';
import 'package:project_kelompok/screen/page2.dart';
import 'package:project_kelompok/screen/page3.dart';
import 'package:project_kelompok/screen/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lottie splash demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.yellow),
      initialRoute: '/',
      routes: {
        '/': (context) => const MySplashScreen(),
        '/page1': (context) => const MyPage1(),
        '/page2': (context) => const MyPage2(),
        '/page3': (context) => const MyPage3(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}