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
  }

