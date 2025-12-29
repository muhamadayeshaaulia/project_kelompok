import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String searchQuery = "";
  List<String> myFollowingList = [];
  List<String> myFollowersList = [];

  @override
  void initState() {
    super.initState();
    _loadMyFollowing();
    _loadMyFollowers();
  }

  Future<void> _loadMyFollowing() async {
    if (currentUser == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('following')
        .get();

    if (mounted) {
      setState(() {
        myFollowingList = snapshot.docs.map((doc) => doc.id).toList();
      });
    }
  }

  Future<void> _loadMyFollowers() async {
    if (currentUser == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('followers')
        .get();

    if (mounted) {
      setState(() {
        myFollowersList = snapshot.docs.map((doc) => doc.id).toList();
      });
    }
  }

  Future<void> _toggleFollow(String targetUid) async {
    if (currentUser == null) return;
    final myFollowingDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('following')
        .doc(targetUid);
    final targetFollowersDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(currentUser!.uid);

    if (myFollowingList.contains(targetUid)) {
      await myFollowingDoc.delete();
      await targetFollowersDoc.delete();
      setState(() => myFollowingList.remove(targetUid));
    } else {
      final timestamp = {'timestamp': FieldValue.serverTimestamp()};
      await myFollowingDoc.set(timestamp);
      await targetFollowersDoc.set(timestamp);
      setState(() => myFollowingList.add(targetUid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari User"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Masukkan Username yg dicari",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                setState(() => searchQuery = val.trim());
              },
            ),
          ),
        ),
      ),
      body: searchQuery.isEmpty
          ? const Center(child: Text("Belum ada pencarian."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'search_keywords',
                    arrayContains: searchQuery.toLowerCase().replaceAll(
                      '.',
                      '',
                    ),
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs =
                    snapshot.data?.docs
                        .where((doc) => doc.id != currentUser?.uid)
                        .toList() ??
                    [];
                if (docs.isEmpty) {
                  return const Center(child: Text("User tidak ditemukan."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final targetUid = docs[index].id;
                    final userData = docs[index].data() as Map<String, dynamic>;
                    final bool amIFollowingHim = myFollowingList.contains(
                      targetUid,
                    );
                    final bool isHeFollowingMe = myFollowersList.contains(
                      targetUid,
                    );
                    final bool isFriend = amIFollowingHim && isHeFollowingMe;

                    String buttonText = "Follow";
                    Color buttonColor = Colors.orange;
                    if (isFriend) {
                      buttonText = "Teman";
                      buttonColor = Colors.yellow[700]!;
                    } else if (amIFollowingHim) {
                      buttonText = "Following";
                      buttonColor = Colors.grey[300]!;
                    } else if (isHeFollowingMe) {
                      buttonText = "Follow Back";
                      buttonColor = Colors.blue;
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userData['photo_url'] != null
                            ? NetworkImage(userData['photo_url'])
                            : null,
                        child: userData['photo_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(userData['nama'] ?? "User"),
                      subtitle: Text(userData['email'] ?? ""),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          elevation: isFriend ? 0 : 2,
                          disabledBackgroundColor: buttonColor,
                          disabledForegroundColor: Colors.black,
                        ),
                        onPressed: isFriend
                            ? null
                            : () => _toggleFollow(targetUid),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: (amIFollowingHim || isFriend)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 1),
    );
  }
}
