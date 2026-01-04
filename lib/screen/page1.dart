import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_kelompok/screen/splash_screen.dart';
import 'package:project_kelompok/services/auth_service.dart';

class MyPage1 extends StatefulWidget {
  const MyPage1({super.key});

  @override
  State<MyPage1> createState() => _MyPage1State();
}

class _MyPage1State extends State<MyPage1> {
  bool _isLoading = false;

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      AuthService authService = AuthService();
      User? user = await authService.signInWithGoogle();

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MySplashScreen(nextRoute: '/home'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/home1.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/global.png',
                  width: 140,
                  height: 140,
                ),
                const SizedBox(height: 10),
                const Text(
                  'MyPhotoBooth',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : _authButton(
                              imagePath: 'assets/images/icongoogle.png',
                              text: 'Sambungkan dengan Google',
                              onTap: _handleGoogleSignIn,
                            ),
                      const SizedBox(height: 12),
                      _authButton(
                        imagePath: 'assets/images/email3.png',
                        text: 'Lanjut dengan Email',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MySplashScreen(nextRoute: '/register'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Dengan mendaftar, kamu menyetujui Ketentuan...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(color: Colors.white),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.lightBlueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _authButton({
    required String imagePath,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 24, width: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
