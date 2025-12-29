import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const PostDetailPage({super.key, required this.postId, required this.postData});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;
  String? replyingToId; 
  String? replyingToName;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }
  void _checkIfLiked() async {
    if (currentUser == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .doc(currentUser!.uid)
        .get();
    if (mounted) setState(() => isLiked = doc.exists);
  }
  void _toggleLike() async {
    if (currentUser == null) return;
    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .doc(currentUser!.uid);

    if (isLiked) {
      await likeRef.delete();
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
    }
    setState(() => isLiked = !isLiked);
  }
  void _addComment() async {
    if (_commentController.text.trim().isEmpty || currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'uid': currentUser!.uid,
      'nama': currentUser!.displayName ?? "User",
      'komentar': _commentController.text.trim(),
      'parent_id': replyingToId, 
      'reply_to_name': replyingToName,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });

    setState(() {
      _commentController.clear();
      replyingToId = null;
      replyingToName = null;
    });
  }

  void _toggleCommentLike(String commentId, List likes) async {
    if (currentUser == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    if (likes.contains(currentUser!.uid)) {
      await docRef.update({'likes': FieldValue.arrayRemove([currentUser!.uid])});
    } else {
      await docRef.update({'likes': FieldValue.arrayUnion([currentUser!.uid])});
    }
  }