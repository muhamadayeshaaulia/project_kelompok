import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_kelompok/detail/postingan.dart';
import 'package:project_kelompok/detail/user_list_page.dart';
import 'package:project_kelompok/screen/profile_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';

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

  void _checkIfFollowing() async {
    if (widget.uid == currentUid) {
      if (mounted) setState(() => isMe = true);
      return;
    }

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

  Future<void> _launchURL(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;

    final Uri uri = Uri.parse(
      cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl',
    );

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $cleanUrl';
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  Widget _getSocialIcon(String url) {
    String lowerUrl = url.toLowerCase();
    if (lowerUrl.contains("instagram.com")) {
      return const FaIcon(
        FontAwesomeIcons.instagram,
        color: Colors.pink,
        size: 22,
      );
    } else if (lowerUrl.contains("facebook.com")) {
      return const FaIcon(
        FontAwesomeIcons.facebook,
        color: Colors.blue,
        size: 22,
      );
    } else if (lowerUrl.contains("github.com")) {
      return const FaIcon(
        FontAwesomeIcons.github,
        color: Colors.black,
        size: 22,
      );
    } else if (lowerUrl.contains("twitter.com") || lowerUrl.contains("x.com")) {
      return const FaIcon(
        FontAwesomeIcons.xTwitter,
        color: Colors.black,
        size: 22,
      );
    }
    return const FaIcon(FontAwesomeIcons.link, color: Colors.grey, size: 20);
  }

  Widget _buildStatColumn(String label, int count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
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
            title: const Text(
              "Profil Pengguna",
              style: TextStyle(color: Colors.black),
            ),
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
          SliverToBoxAdapter(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData == null)
                  return const Center(child: Text("User tidak ditemukan"));

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            userData['photo_url'] != null &&
                                userData['photo_url'] != ''
                            ? NetworkImage(userData['photo_url'])
                            : null,
                        child:
                            userData['photo_url'] == null ||
                                userData['photo_url'] == ''
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userData['nama'] ?? "Tanpa Nama",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('uid', isEqualTo: widget.uid)
                                .snapshots(),
                            builder: (context, snap) {
                              int count = snap.hasData
                                  ? snap.data!.docs.length
                                  : 0;
                              return _buildStatColumn(
                                "Postingan",
                                count,
                                () {},
                              );
                            },
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('followers')
                                .snapshots(),
                            builder: (context, snap) {
                              int count = snap.hasData
                                  ? snap.data!.docs.length
                                  : 0;
                              return _buildStatColumn("Pengikut", count, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => UserListPage(
                                      title: "Pengikut",
                                      uid: widget.uid,
                                      collectionName: 'followers',
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('following')
                                .snapshots(),
                            builder: (context, snap) {
                              int count = snap.hasData
                                  ? snap.data!.docs.length
                                  : 0;
                              return _buildStatColumn("Mengikuti", count, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (c) => UserListPage(
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

                      if (userData['keterangan'] != null &&
                          userData['keterangan'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            left: 30,
                            right: 30,
                          ),
                          child: Text(
                            userData['keterangan'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (userData['sosmed_link'] != null &&
                          userData['sosmed_link'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Wrap(
                            spacing: 20,
                            children: userData['sosmed_link']
                                .toString()
                                .split(',')
                                .map<Widget>((link) {
                                  return GestureDetector(
                                    onTap: () => _launchURL(link),
                                    child: _getSocialIcon(link),
                                  );
                                })
                                .toList(),
                          ),
                        ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: isMe
                            ? OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfilePage(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                child: const Text(
                                  "Edit Profil",
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _handleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing
                                      ? Colors.grey[300]
                                      : Colors.blue,
                                  foregroundColor: isFollowing
                                      ? Colors.black
                                      : Colors.white,
                                  elevation: 0,
                                ),
                                child: Text(
                                  isFollowing ? "Mengikuti" : "Ikuti",
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      const Text(
                        "Karya Pengguna Ini",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text("Belum ada postingan."),
                    ),
                  ),
                );
              }
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  var post = snapshot.data!.docs[index];
                  var postData = post.data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) =>
                            PostDetailPage(postId: post.id, postData: postData),
                      ),
                    ),
                    child: Image.network(
                      postData['post_image'],
                      fit: BoxFit.cover,
                    ),
                  );
                }, childCount: snapshot.data!.docs.length),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 0),
    );
  }
}
