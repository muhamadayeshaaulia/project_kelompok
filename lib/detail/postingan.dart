import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

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

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _fetchMyName();
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

  void _addComment() async {
    if (_commentController.text.trim().isEmpty || currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
          'uid': currentUser!.uid,
          'nama': _myUserName,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal menghapus komentar: $e")),
                );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Postingan"),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
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
                  ),
                  Image.network(
                    widget.postData['post_image'],
                    width: double.infinity,
                    fit: BoxFit.contain,
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
                        const Text("Suka"),
                        const SizedBox(width: 15),
                        const Icon(Icons.mode_comment_outlined),
                        const SizedBox(width: 5),
                        const Text("Komentar"),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () async {
                            try {
                              await Share.share(
                                "Lihat karya keren ini: ${widget.postData['post_image']}\nDiposting oleh: ${widget.postData['nama']}",
                                subject: "Karya Fotografi",
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Tidak dapat membuka menu berbagi: $e",
                                  ),
                                ),
                              );
                            }
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

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

        var allComments = snapshot.data!.docs;
        var mainComments = allComments
            .where((doc) => doc['parent_id'] == null)
            .toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mainComments.length,
          itemBuilder: (context, index) {
            var commentDoc = mainComments[index];
            var commentId = commentDoc.id;
            var commentData = commentDoc.data() as Map<String, dynamic>;
            var replies = allComments
                .where((doc) => doc['parent_id'] == commentId)
                .toList();

            return Column(
              children: [
                _commentTile(commentId, commentData),
                ...replies.map(
                  (reply) => Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: _commentTile(
                      reply.id,
                      reply.data() as Map<String, dynamic>,
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
      leading: isReply
          ? null
          : const Icon(Icons.account_circle, size: 30, color: Colors.grey),
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
                Icons.delete_outline,
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
                onTap: () {
                  setState(() {
                    replyingToId = id;
                    replyingToName = data['nama'];
                  });
                },
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
              if (likes.isNotEmpty)
                Text(
                  "${likes.length} ❤️",
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
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingToName != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Text("Membalas ", style: const TextStyle(fontSize: 12)),
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
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
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
                      hintText: replyingToName != null
                          ? "Balas..."
                          : "Tulis komentar...",
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
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
