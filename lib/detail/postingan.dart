import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_kelompok/detail/profilDetail.dart';
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

  void _navigateToProfile(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Profildetail(uid: uid)),
    );
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId);

      var likes = await postRef.collection('likes').get();
      for (var doc in likes.docs) {
        batch.delete(doc.reference);
      }

      var comments = await postRef.collection('comments').get();
      for (var doc in comments.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(postRef);
      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Postingan berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Error delete: $e");
    }
  }

  void _addComment() async {
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty || currentUser == null) return;

    try {
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
            content: Text("Komentar berhasil ditambahkan"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _commentController.clear();
        replyingToId = null;
        replyingToName = null;
      });
      FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint("Error adding comment: $e");
    }
  }

  void _deleteComment(String commentId) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Komentar"),
        content: const Text("Apakah Anda yakin ingin menghapus komentar ini?"),
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
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Komentar berhasil dihapus"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting comment: $e");
    }
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
    String templateLabel = detectedTemplate == 'classic_4'
        ? 'Classic 4'
        : (detectedTemplate == 'vintage' ? 'Vintage' : 'Classic 2');
    bool isOwner = currentUser?.uid == widget.postData['uid'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Postingan", style: TextStyle(color: Colors.black)),
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
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.black,
              onPressed: _deletePost,
            ),
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
                    leading: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.postData['uid'])
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        String? livePhotoUrl;
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          var userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          livePhotoUrl = userData['photo_url'];
                        }
                        return GestureDetector(
                          onTap: () =>
                              _navigateToProfile(widget.postData['uid']),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                (livePhotoUrl != null &&
                                    livePhotoUrl.isNotEmpty)
                                ? NetworkImage(livePhotoUrl)
                                : null,
                            child:
                                (livePhotoUrl == null || livePhotoUrl.isEmpty)
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        );
                      },
                    ),
                    title: GestureDetector(
                      onTap: () => _navigateToProfile(widget.postData['uid']),
                      child: Text(
                        widget.postData['nama'] ?? "User",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                        if (detectedTemplate == 'classic_4') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const PhotoBoothPage(),
                            ),
                          );
                        } else if (detectedTemplate == 'vintage') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const PhotoBoothPage3(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const PhotoBoothPage2(),
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
                              "$count Suka",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.mode_comment_outlined),
                        const SizedBox(width: 5),
                        const Text("Komentar"),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          onPressed: () => Share.share(
                            "Lihat karya ${widget.postData['nama']} ini! ${widget.postData['post_image']}",
                          ),
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
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.grey,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Belum ada komentar.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Jadilah yang pertama mengomentari!",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        var allDocs = snapshot.data!.docs;
        var mainComments = allDocs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return data['parent_id'] == null;
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mainComments.length,
          itemBuilder: (context, index) {
            var doc = mainComments[index];
            var replies = allDocs.where((d) {
              Map<String, dynamic> data = d.data() as Map<String, dynamic>;
              return data['parent_id'] == doc.id;
            }).toList();

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
      dense: true,
      leading: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(data['uid'])
            .snapshots(),
        builder: (context, userSnapshot) {
          String? commenterPhoto;
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            commenterPhoto = userData['photo_url'];
          }
          return GestureDetector(
            onTap: () => _navigateToProfile(data['uid']),
            child: CircleAvatar(
              radius: isReply ? 12 : 15,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  (commenterPhoto != null && commenterPhoto.isNotEmpty)
                  ? NetworkImage(commenterPhoto)
                  : null,
              child: (commenterPhoto == null || commenterPhoto.isEmpty)
                  ? Icon(Icons.person, size: isReply ? 14 : 18)
                  : null,
            ),
          );
        },
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToProfile(data['uid']),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 13),
                  children: [
                    TextSpan(
                      text: "${data['nama'] ?? "User"} ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: formatPostTime(data['timestamp'] as Timestamp?),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMyComment)
            GestureDetector(
              onTap: () => _deleteComment(id),
              child: const Icon(Icons.close, size: 14, color: Colors.grey),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            data['komentar'] ?? "",
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleCommentLike(id, likes),
                child: Text(
                  isCommentLiked ? "Batal Suka" : "Suka",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isCommentLiked ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () => setState(() {
                  replyingToId = id;
                  replyingToName = data['nama'];
                }),
                child: const Text(
                  "Balas",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              if (likes.isNotEmpty)
                Text(
                  "   ${likes.length} ❤️",
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingToName != null)
              Row(
                children: [
                  Text(
                    "Membalas $replyingToName",
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Tulis komentar...",
                      border: InputBorder.none,
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
