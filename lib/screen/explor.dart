import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/postingan.dart';
import 'package:intl/intl.dart';

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
        centerTitle: true,
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
  }

