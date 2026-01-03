import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/postingan.dart';
import 'package:intl/intl.dart';
import 'package:project_kelompok/screen/following_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';

class ExplorPage extends StatefulWidget {
  const ExplorPage({super.key});

  @override
  State<ExplorPage> createState() => _ExplorPageState();
}

class _ExplorPageState extends State<ExplorPage> {
  String formatPostTime(Timestamp? timestamp) {
    if (timestamp == null) return "...";
    DateTime postDate = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(postDate);
    if (difference.inHours < 24) {
      return DateFormat('HH:mm').format(postDate);
    } else {
      return DateFormat('d MMM yyyy').format(postDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Jelajahi Karya",
          style: TextStyle(color: Colors.black),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_search_outlined, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                  builder: (context) => const FollowingPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSectionTitle("🔥 Paling Populer"),
          _buildPopularGrid(),
          const SizedBox(height: 20),
          _buildSectionTitle("✨ Postingan Terbaru"),
          _buildRecentList(),
        ],
      ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 1),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPopularGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('views', descending: true)
          .limit(6)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              var data = post.data() as Map<String, dynamic>;
              return _buildPopularCard(post.id, data);
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularCard(String postId, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => _openDetail(postId, data),
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: NetworkImage(data['post_image']),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['nama'] ?? 'User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye,
                    color: Colors.white70,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${data['views'] ?? 0}",
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var post = snapshot.data!.docs[index];
            var data = post.data() as Map<String, dynamic>;
            String postId = post.id;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['user_image'] ?? ''),
                      backgroundColor: Colors.grey[200],
                    ),
                    title: Text(
                      data['nama'] ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      formatPostTime(data['timestamp'] as Timestamp?),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openDetail(postId, data),
                    child: Image.network(
                      data['post_image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('likes')
                              .snapshots(),
                          builder: (context, likeSnapshot) {
                            int totalLikes = likeSnapshot.hasData
                                ? likeSnapshot.data!.docs.length
                                : 0;
                            return Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: totalLikes > 0
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "$totalLikes",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 15),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('comments')
                              .snapshots(),
                          builder: (context, commentSnapshot) {
                            int totalComments = commentSnapshot.hasData
                                ? commentSnapshot.data!.docs.length
                                : 0;
                            return Row(
                              children: [
                                const Icon(
                                  Icons.comment_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "$totalComments",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Spacer(),
                        Text(
                          "${data['views'] ?? 0} tayangan",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openDetail(String postId, Map<String, dynamic> data) {
    FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'views': FieldValue.increment(1),
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(postId: postId, postData: data),
      ),
    );
  }
}
