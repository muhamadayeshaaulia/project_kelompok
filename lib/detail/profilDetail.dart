import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/postingan.dart';
import 'package:project_kelompok/detail/user_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profildetail extends StatefulWidget {
  final String uid;

  const Profildetail({super.key, required this.uid});

  @override
  State<Profildetail> createState() => _ProfildetailState();
}

class _ProfildetailState extends State<Profildetail> {

  bool isFollowing = false;
  bool isMe = false;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  // 1. FUNGSI CEK STATUS FOLLOW
  void _checkIfFollowing() async {
    // Kalau profil yang dibuka adalah diri sendiri
    if (widget.uid == currentUid) {
      setState(() {
        isMe = true;
      });
      return;
    }

    // Cek ke database apakah saya ada di list followers dia
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('followers')
        .doc(currentUid)
        .get();

    if (mounted) {
      setState(() {
        isFollowing = doc.exists;
      });
    }
  }

  // 2. FUNGSI TOMBOL DITEKAN (FOLLOW / UNFOLLOW)
  void _handleFollow() async {
    var batch = FirebaseFirestore.instance.batch();

    DocumentReference myFollowingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(widget.uid);

    DocumentReference otherFollowerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('followers')
        .doc(currentUid);

    setState(() {
      isFollowing = !isFollowing;
    });

    if (isFollowing) {
      batch.set(myFollowingRef, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(otherFollowerRef, {'timestamp': FieldValue.serverTimestamp()});
    } else {
      batch.delete(myFollowingRef);
      batch.delete(otherFollowerRef);
    }

    await batch.commit();
  }
  
  Widget _buildStatColumn(String label, int count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, 
            expandedHeight: 50.0,
            title: const Text("Profil Pengguna"),
            centerTitle: true,
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.white,
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) return const Center(child: Text("User tidak ditemukan"));

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: userData['photo_url'] != null
                              ? NetworkImage(userData['photo_url'])
                              : null,
                          child: userData['photo_url'] == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          userData['nama'] ?? "Tanpa Nama",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          userData['email'] ?? "-",
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- BAGIAN TOMBOL FOLLOW / EDIT ---
                      if (isMe)
                        // Kalau profil sendiri: Tampilkan tombol Edit (Dummy)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Navigasi ke Edit Profil (opsional)
                            }, 
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey)),
                            child: const Text("Edit Profil", style: TextStyle(color: Colors.black)),
                          ),
                        )
                      else
                        // Kalau profil orang lain: Tampilkan Follow/Unfollow
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing ? Colors.grey[300] : Colors.blue,
                              foregroundColor: isFollowing ? Colors.black : Colors.white,
                              elevation: 0,
                            ),
                            child: Text(isFollowing ? "Mengikuti" : "Ikuti"),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('uid', isEqualTo: widget.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              int postCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return _buildStatColumn("Postingan", postCount, () {});
                            },
                          ),
                          Container(height: 30, width: 1, color: Colors.grey[300]),
                          
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('followers')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int followerCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return _buildStatColumn("Pengikut", followerCount, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserListPage(
                                      title: "Pengikut",
                                      uid: widget.uid,
                                      collectionName: 'followers',
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                          Container(height: 30, width: 1, color: Colors.grey[300]),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('following')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int followingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return _buildStatColumn("Mengikuti", followingCount, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserListPage(
                                      title: "Mengikuti",
                                      uid: widget.uid,
                                      collectionName: 'following',
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            "Karya Pengguna Ini",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('uid', isEqualTo: widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: Text("Belum ada postingan.")),
                  ),
                );
              }

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var post = snapshot.data!.docs[index];
                    var postData = post.data() as Map<String, dynamic>;
                    String postId = post.id;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(
                              postId: postId,
                              postData: postData,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          postData['post_image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[300], child: const Icon(Icons.error)),
                        ),
                      ),
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}