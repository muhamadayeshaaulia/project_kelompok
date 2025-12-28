import 'package:flutter/material.dart';

class MemberCardPage extends StatelessWidget {
  const MemberCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tim Developer"),
        backgroundColor: const Color.fromRGBO(255, 192, 45, 1),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: const Column(
            children: [
              const Center(
                child: Text(
                  "Anggota Kelompok 1",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
