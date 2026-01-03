import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/profilDetail.dart';

class UserListPage extends StatelessWidget {
  final String title;     // Judul: "Pengikut" atau "Mengikuti"
  final String uid;       // UID user yang sedang dilihat
  final String collectionName; // 'followers' atau 'following'

  const UserListPage({
    super.key,
    required this.title,
    required this.uid,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection(collectionName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("Belum ada ${title.toLowerCase()}."),
            );
          }

          var userDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              String targetUserId = userDocs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(targetUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.grey),
                      title: Text("Loading..."),
                    );
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData == null) return const SizedBox();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userData['photo_url'] != null
                          ? NetworkImage(userData['photo_url'])
                          : null,
                      child: userData['photo_url'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      userData['nama'] ?? "User",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(userData['email'] ?? ""),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profildetail(uid: targetUserId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}