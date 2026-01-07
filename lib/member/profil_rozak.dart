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
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Data Profil Belum Ada",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "UID: $myUid",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
