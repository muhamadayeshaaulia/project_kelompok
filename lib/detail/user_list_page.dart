import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/profilDetail.dart';

class UserListPage extends StatelessWidget {
  final String title;
  final String uid;
  final String collectionName;

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
        title: Text(title, style: TextStyle(color: Colors.black),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
            return Center(child: Text("Belum ada ${title.toLowerCase()}."));
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

                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
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
