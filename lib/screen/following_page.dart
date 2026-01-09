import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_kelompok/screen/explor.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/detail/profilDetail.dart';
import 'package:project_kelompok/services/notification_service.dart';

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
  bool showAllHistory = false;

  @override
  void initState() {
    super.initState();
    _loadMyFollowing();
    _loadMyFollowers();
  }

  Future<void> _sendFollowNotification(
    String targetUid,
    bool isFollback,
  ) async {
    try {
      DocumentSnapshot targetDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .get();

      DocumentSnapshot myDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (targetDoc.exists && myDoc.exists) {
        String? token =
            (targetDoc.data() as Map<String, dynamic>?)?['fcmToken'];
        String targetName =
            (targetDoc.data() as Map<String, dynamic>?)?['nama'] ?? "User";
        String myName =
            (myDoc.data() as Map<String, dynamic>?)?['nama'] ?? "Seseorang";

        if (token != null) {
          String title = "Halo $targetName! 👋";
          String body = "";

          if (isFollback) {
            body = "$myName baru saja follback kamu! 🤝";
          } else {
            body = "$myName mulai mengikuti kamu 👤";
          }

          await NotificationService.sendPushNotification(
            targetToken: token,
            title: title,
            body: body,
            postId: "",
          );
        }
      }
    } catch (e) {
      debugPrint("Gagal kirim notif follow: $e");
    }
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

  Future<void> _saveSearchHistory(String text) async {
    if (text.isEmpty || currentUser == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('search_history')
        .doc(text.toLowerCase())
        .set({'query': text, 'timestamp': FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot> _getSearchHistory() {
    DateTime limitDate = DateTime.now().subtract(const Duration(days: 7));
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('search_history')
        .where('timestamp', isGreaterThan: limitDate)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _deleteSingleHistory(String docId) async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('search_history')
        .doc(docId)
        .delete();
  }

  Future<void> _clearAllHistory() async {
    if (currentUser == null) return;
    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('search_history')
        .get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
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

      final checkFollbackDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('followers')
          .doc(targetUid)
          .get();

      bool isFollback = checkFollbackDoc.exists;
      setState(() {
        myFollowingList.add(targetUid);
        if (isFollback && !myFollowersList.contains(targetUid)) {
          myFollowersList.add(targetUid);
        }
      });
      _sendFollowNotification(targetUid, isFollback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ExplorPage()),
              );
            },
            icon: const Icon(Icons.explore_outlined),
          ),
        ],
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
                setState(() {
                  searchQuery = val.trim();
                  showAllHistory = false;
                });
                if (val.trim().length > 2) {
                  _saveSearchHistory(val.trim());
                }
              },
            ),
          ),
        ),
      ),
      body: searchQuery.isEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: _getSearchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada pencarian."));
                }

                final allDocs = snapshot.data!.docs;
                final displayedDocs = showAllHistory
                    ? allDocs
                    : allDocs.take(5).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Pencarian Terakhir",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextButton(
                            onPressed: _clearAllHistory,
                            child: const Text(
                              "Hapus Semua",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ...displayedDocs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: const Icon(Icons.history, size: 20),
                              title: Text(data['query'] ?? ""),
                              onTap: () =>
                                  setState(() => searchQuery = data['query']),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => _deleteSingleHistory(doc.id),
                              ),
                            );
                          }).toList(),

                          if (allDocs.length > 5 && !showAllHistory)
                            TextButton(
                              onPressed: () =>
                                  setState(() => showAllHistory = true),
                              child: const Text("Lihat Semua"),
                            ),

                          if (showAllHistory)
                            TextButton(
                              onPressed: () =>
                                  setState(() => showAllHistory = false),
                              child: const Text("Sembunyikan"),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Profildetail(uid: targetUid),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: userData['photo_url'] != null
                            ? NetworkImage(userData['photo_url'])
                            : null,
                        child: userData['photo_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(userData['nama'] ?? "User"),
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
      bottomNavigationBar: const CustomButtomNav(currentIndex: 0),
    );
  }
}
