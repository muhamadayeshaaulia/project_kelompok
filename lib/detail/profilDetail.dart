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
  bool isHeFollowingMe = false;
  bool isMutual = false;
  bool isMe = false;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    if (widget.uid == currentUid) {
      if (mounted) setState(() => isMe = true);
      return;
    }

    DocumentSnapshot myFollowDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('followers')
        .doc(currentUid)
        .get();
    DocumentSnapshot hisFollowDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('followers')
        .doc(widget.uid)
        .get();

    if (mounted) {
      setState(() {
        isFollowing = myFollowDoc.exists;
        isHeFollowingMe = hisFollowDoc.exists;
        isMutual = myFollowDoc.exists && hisFollowDoc.exists;
      });
    }
  }

  void _confirmUnfollow(String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Berhenti Mengikuti?"),
        content: Text("Apakah Anda yakin ingin berhenti mengikuti $userName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleFollowAction(false);
            },
            child: const Text(
              "Berhenti Mengikuti",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFollowAction(bool startFollowing) async {
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

    if (startFollowing) {
      batch.set(myFollowingRef, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(otherFollowerRef, {'timestamp': FieldValue.serverTimestamp()});
    } else {
      batch.delete(myFollowingRef);
      batch.delete(otherFollowerRef);
    }

    await batch.commit();
    _checkStatus();
  }

  Future<void> _launchURL(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;
    final Uri uri = Uri.parse(
      cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Error launching URL");
    }
  }

  Widget _getSocialIcon(String url) {
    String lowerUrl = url.toLowerCase();
    if (lowerUrl.contains("instagram.com"))
      return const FaIcon(
        FontAwesomeIcons.instagram,
        color: Colors.pink,
        size: 22,
      );
    if (lowerUrl.contains("facebook.com"))
      return const FaIcon(
        FontAwesomeIcons.facebook,
        color: Colors.blue,
        size: 22,
      );
    if (lowerUrl.contains("github.com"))
      return const FaIcon(
        FontAwesomeIcons.github,
        color: Colors.black,
        size: 22,
      );
    if (lowerUrl.contains("youtube.com"))
      return const FaIcon(
        FontAwesomeIcons.youtube,
        color: Colors.red,
        size: 22,
      );
    if (lowerUrl.contains("linkedin.com"))
      return const FaIcon(
        FontAwesomeIcons.linkedin,
        color: Colors.blue,
        size: 22,
      );
    return const FaIcon(FontAwesomeIcons.link, color: Colors.black54, size: 20);
  }

  Widget _buildStatItem(String label, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const profileGradient = LinearGradient(
      colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(color: Colors.black)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: profileGradient),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
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
                String userName = userData['nama'] ?? "User";

                return Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(gradient: profileGradient),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 42,
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
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('posts')
                                      .where('uid', isEqualTo: widget.uid)
                                      .snapshots(),
                                  builder: (context, snap) => _buildStatItem(
                                    "Post",
                                    snap.hasData ? snap.data!.docs.length : 0,
                                    () {},
                                  ),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.uid)
                                      .collection('followers')
                                      .snapshots(),
                                  builder: (context, snap) => _buildStatItem(
                                    "Pengikut",
                                    snap.hasData ? snap.data!.docs.length : 0,
                                    () {
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
                                    },
                                  ),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.uid)
                                      .collection('following')
                                      .snapshots(),
                                  builder: (context, snap) => _buildStatItem(
                                    "Mengikuti",
                                    snap.hasData ? snap.data!.docs.length : 0,
                                    () {
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
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (userData['keterangan'] != null &&
                          userData['keterangan'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            userData['keterangan'],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      if (userData['sosmed_link'] != null &&
                          userData['sosmed_link'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 15,
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
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: isMe
                                ? OutlinedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage(),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(
                                        0.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      side: const BorderSide(
                                        color: Colors.black26,
                                      ),
                                    ),
                                    child: const Text(
                                      "Settings Profil",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isMutual
                                              ? null
                                              : () => _handleFollowAction(
                                                  !isFollowing,
                                                ),
                                          style: ElevatedButton.styleFrom(
                                            disabledBackgroundColor:
                                                Colors.grey[200],
                                            disabledForegroundColor:
                                                Colors.black54,
                                            backgroundColor: isFollowing
                                                ? Colors.white.withOpacity(0.7)
                                                : Colors.blue,
                                            foregroundColor: isFollowing
                                                ? Colors.black
                                                : Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            isMutual
                                                ? "Teman"
                                                : (isFollowing
                                                      ? "Mengikuti"
                                                      : (isHeFollowingMe
                                                            ? "Ikuti Balik"
                                                            : "Ikuti")),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isFollowing) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.black12,
                                            ),
                                          ),
                                          child: PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            onSelected: (value) {
                                              if (value == 'unfollow')
                                                _confirmUnfollow(userName);
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'unfollow',
                                                child: Text(
                                                  "Berhenti Mengikuti",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    isMe ? "Karya Saya" : "Karya Pengguna Ini",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
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
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
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
