import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_kelompok/screen/home_screen.dart';
import 'package:project_kelompok/screen/login.dart';
import 'package:project_kelompok/screen/page1.dart';
import 'package:project_kelompok/screen/page2.dart';
import 'package:project_kelompok/screen/page3.dart';
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
  runApp(MyApp());
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
        '/page2': (context) => const MyPage2(),
        '/page3': (context) => const MyPage3(),
        '/login': (context) => const MyLogin(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const MyRegis(),
      },
    );
  }
}
