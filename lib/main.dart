import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_kelompok/screen/explor.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/screen/info_page.dart';
import 'package:project_kelompok/screen/login.dart';
import 'package:project_kelompok/screen/page1.dart';
import 'package:project_kelompok/screen/profile_page.dart';
import 'package:project_kelompok/screen/register.dart';
import 'package:project_kelompok/screen/splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await SupabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booth Art Apps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.yellow),
      initialRoute: '/',
      routes: {
        '/': (context) => const MySplashScreen(),
        '/page1': (context) => const MyPage1(),
        '/login': (context) => const MyLogin(),
        '/register': (context) => const MyRegis(),
        '/home': (context) => const MyHomePage(),
        '/explor': (context) => const ExplorPage(),
        '/info': (context) => const InfoAplikasiPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
