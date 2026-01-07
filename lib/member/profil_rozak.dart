import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfileDetailPage extends StatelessWidget {
  const MyProfileDetailPage({super.key});

  final String myUid = "BQdVH5ZOp5ObKtz3xjimt62DmNA2";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(myUid)
              .get(),
          builder: (context, snapshot) {},
        ),
      ),
    );
  }
}
