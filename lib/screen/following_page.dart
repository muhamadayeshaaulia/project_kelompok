import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
    );
  }
}
