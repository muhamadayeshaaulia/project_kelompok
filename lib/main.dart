import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_kelompok/screen/explor.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/screen/info_page.dart';
import 'package:project_kelompok/screen/login.dart';
import 'package:project_kelompok/screen/page1.dart';
import 'package:project_kelompok/screen/profile_page.dart';
import 'package:project_kelompok/screen/register.dart';
import 'package:project_kelompok/screen/screen.dart';
import 'package:project_kelompok/screen/screen2.dart';
import 'package:project_kelompok/screen/screen3.dart';
import 'package:project_kelompok/screen/splash_screen.dart';
import 'package:project_kelompok/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/supabase_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  await SupabaseService.init();
  await NotificationService.initializeAll();

  await Permission.notification.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      title: 'Booth Art Apps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.yellow),
      initialRoute: '/',
      routes: {
        '/': (context) => const MySplashScreen(),
        '/page1': (context) => const MyPage1(),
        '/screen': (context) => const MyPage2(),
        '/screen2': (context) => const MyPage3(),
        '/screen3': (context) => const MyPage4(),
        '/screen4': (context) => const MyPage5(),
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
