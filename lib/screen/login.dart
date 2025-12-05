import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyLogin extends StatelessWidget {
  const MyLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login untuk melanjukan perjalan an mu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Lottie.asset(
              'assets/annimations/Bus_Loader.json',
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: Icon(Icons.email),
                labelText: 'Email',
                hintText: 'Masukan Email Anda',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: Icon(Icons.lock),
                labelText: 'Password',
                hintText: 'Masukan password anda',
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
