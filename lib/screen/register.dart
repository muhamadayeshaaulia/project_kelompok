import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRegis extends StatefulWidget {
  const MyRegis({super.key});

  @override
  State<MyRegis> createState() => _MyRegisState();
}

class _MyRegisState extends State<MyRegis> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.length < 6) {
      setState(() {
        _error = "Email kosong atau password kurang dari 6 karakter";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registrasi berhasil 🎉 Silakan login'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );


    await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}
