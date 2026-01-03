import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:project_kelompok/template/photoboothpage.dart';
import 'package:project_kelompok/template/photoboothpage2.dart';
import 'package:project_kelompok/template/template_vintage.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> postData;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.postData,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;
  String? replyingToId;
  String? replyingToName;
  String _myUserName = "Loading...";
  String? _myProfilePic;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _fetchMyName();
  }

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

  Future<void> _fetchMyName() async {
    if (currentUser == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (doc.exists && mounted) {
      setState(() {
        _myUserName = doc.data()?['nama'] ?? "User";
        _myProfilePic = doc.data()?['photo_url'];
      });
    }
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

  Future<void> _deletePost() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Postingan"),
        content: const Text(
          "Postingan ini akan dihapus dari publik beserta like dan komentarnya.\n\nFoto akan TETAP ADA di menu 'Karya Saya'.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()),
        );
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId);

      var likesSnapshot = await postRef.collection('likes').get();
      for (var doc in likesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      var commentsSnapshot = await postRef.collection('comments').get();
      for (var doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(postRef);

      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Postingan dihapus dari publik. Foto aman di Karya Saya.",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
    }
  }

  void _addComment() async {
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty || currentUser == null) return;

    if (_myUserName == "Loading...") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon tunggu, sedang memuat profil...")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
          'uid': currentUser!.uid,
          'nama': _myUserName,
          'photo_url': _myProfilePic,
          'komentar': commentText,
          'parent_id': replyingToId,
          'reply_to_name': replyingToName,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': [],
        });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Komentar berhasil dikirim! 💬"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _commentController.clear();
      replyingToId = null;
      replyingToName = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _deleteComment(String commentId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Komentar"),
        content: const Text("Apakah Anda yakin ingin menghapus komentar ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .doc(commentId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Komentar berhasil dihapus")),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleCommentLike(String commentId, List likes) async {
    if (currentUser == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    if (likes.contains(currentUser!.uid)) {
      await docRef.update({
        'likes': FieldValue.arrayRemove([currentUser!.uid]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayUnion([currentUser!.uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String detectedTemplate = widget.postData['template_type'] ?? 'classic_2';

    // Logika Penamaan Tombol
    String templateLabel;
    if (detectedTemplate == 'classic_4') {
      templateLabel = 'Classic 4';
    } else if (detectedTemplate == 'vintage') {
      templateLabel = 'Vintage';
    } else {
      templateLabel = 'Classic 2';
    }

    bool isOwner = currentUser?.uid == widget.postData['uid'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Postingan"),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
        actions: [
          if (isOwner)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deletePost),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: widget.postData['user_image'] != null
                          ? NetworkImage(widget.postData['user_image'])
                          : null,
                      child: widget.postData['user_image'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      widget.postData['nama'] ?? "User",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      formatPostTime(
                        widget.postData['timestamp'] as Timestamp?,
                      ),
                    ),
                  ),
                  Image.network(
                    widget.postData['post_image'],
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Logika Navigasi Template
                        if (detectedTemplate == 'classic_4') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhotoBoothPage(),
                            ),
                          );
                        } else if (detectedTemplate == 'vintage') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TemplateVintage(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhotoBoothPage2(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: Text(
                        "Gunakan Template $templateLabel",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed: _toggleLike,
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postId)
                              .collection('likes')
                              .snapshots(),
                          builder: (context, snapshot) {
                            int count = snapshot.hasData
                                ? snapshot.data!.docs.length
                                : 0;
                            return Text(
                              "$count ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const Text("Suka"),
                        const SizedBox(width: 15),
                        const Icon(Icons.mode_comment_outlined),
                        const SizedBox(width: 5),
                        const Text("Komentar"),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () async {
                            await Share.share(
                              "Karya dari ${widget.postData['nama']}: ${widget.postData['post_image']}",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  _buildCommentList(),
                ],
              ),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey[400],
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Belum ada komentar.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Text(
                    "Jadilah yang pertama mengomentari!",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }
        var allDocs = snapshot.data!.docs;
        var mainComments = allDocs
            .where((doc) => doc['parent_id'] == null)
            .toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mainComments.length,
          itemBuilder: (context, index) {
            var doc = mainComments[index];
            var replies = allDocs
                .where((d) => d['parent_id'] == doc.id)
                .toList();
            return Column(
              children: [
                _commentTile(doc.id, doc.data() as Map<String, dynamic>),
                ...replies.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: _commentTile(
                      r.id,
                      r.data() as Map<String, dynamic>,
                      isReply: true,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _commentTile(
    String id,
    Map<String, dynamic> data, {
    bool isReply = false,
  }) {
    List likes = data['likes'] ?? [];
    bool isCommentLiked = likes.contains(currentUser?.uid);
    bool isMyComment = data['uid'] == currentUser?.uid;

    return ListTile(
      onLongPress: isMyComment ? () => _deleteComment(id) : null,
      dense: true,
      leading: CircleAvatar(
        radius: isReply ? 12 : 15,
        backgroundImage: data['photo_url'] != null
            ? NetworkImage(data['photo_url'])
            : null,
        child: data['photo_url'] == null
            ? const Icon(Icons.person, size: 18)
            : null,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data['nama'] ?? "User",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          if (isMyComment)
            GestureDetector(
              onTap: () => _deleteComment(id),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['komentar'] ?? ""),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleCommentLike(id, likes),
                child: Text(
                  isCommentLiked ? "Batal Suka" : "Suka",
                  style: TextStyle(
                    color: isCommentLiked ? Colors.blue : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => setState(() {
                  replyingToId = id;
                  replyingToName = data['nama'];
                }),
                child: Text(
                  "Balas",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                formatPostTime(data['timestamp'] as Timestamp?),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              if (likes.isNotEmpty)
                Text(
                  "  ${likes.length} ❤️",
                  style: const TextStyle(fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingToName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Text("Membalas ", style: TextStyle(fontSize: 12)),
                    Text(
                      replyingToName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() {
                        replyingToId = null;
                        replyingToName = null;
                      }),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Tulis komentar...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
