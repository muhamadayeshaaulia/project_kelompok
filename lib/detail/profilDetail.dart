import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/postingan.dart';
import 'package:project_kelompok/detail/user_list_page.dart';


class Profildetail extends StatefulWidget {
  final String uid;

  const Profildetail({super.key, required this.uid});

  @override
  State<Profildetail> createState() => _ProfildetailState();
}

class _ProfildetailState extends State<Profildetail> {
  
  // Widget Helper untuk Statistik (Post/Follower/Following)
  Widget _buildStatColumn(String label, int count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PERUBAHAN UTAMA: Menggunakan CustomScrollView ---
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR (Pinned = True agar menempel saat scroll)
          SliverAppBar(
            pinned: true, 
            expandedHeight: 50.0,
            title: const Text("Profil Pengguna"),
            centerTitle: true,
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.white,
          ),

          // 2. HEADER PROFIL (Foto, Nama, Bio, Statistik)
          // Kita bungkus FutureBuilder lama kamu ke dalam SliverToBoxAdapter
          SliverToBoxAdapter(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                var userData = snapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) return const Center(child: Text("User tidak ditemukan"));

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      // Foto Profil
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: userData['photo_url'] != null
                              ? NetworkImage(userData['photo_url'])
                              : null,
                          child: userData['photo_url'] == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Nama
                      Center(
                        child: Text(
                          userData['nama'] ?? "Tanpa Nama",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Email
                      Center(
                        child: Text(
                          userData['email'] ?? "-",
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Statistik Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Post Count
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('uid', isEqualTo: widget.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              int postCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return _buildStatColumn("Postingan", postCount, () {});
                            },
                          ),
                          Container(height: 30, width: 1, color: Colors.grey[300]),
                          
                          // Followers Count
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('followers')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int followerCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return _buildStatColumn("Followers", followerCount, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserListPage(
                                      title: "Pengikut",
                                      uid: widget.uid,
                                      collectionName: 'followers',
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                          Container(height: 30, width: 1, color: Colors.grey[300]),

                          // Following Count
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('following')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int followingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              return _buildStatColumn("Following", followingCount, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserListPage(
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
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            "Karya Pengguna Ini",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 3. GRID POSTINGAN (Menggunakan SliverGrid)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('uid', isEqualTo: widget.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: Text("Belum ada postingan.")),
                  ),
                );
              }

              // --- BAGIAN INI MEMBUAT GRID BISA DI-SCROLL MENYATU DENGAN HEADER ---
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var post = snapshot.data!.docs[index];
                    var postData = post.data() as Map<String, dynamic>;
                    String postId = post.id;

                    // --- BAGIAN INI MEMBUAT GAMBAR BISA DIKLIK ---
                    return InkWell(
                      onTap: () {
                        // Navigasi ke Halaman Detail Postingan
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(
                              postId: postId,
                              postData: postData,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          postData['post_image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[300], child: const Icon(Icons.error)),
                        ),
                      ),
                    );
                  },
                  childCount: snapshot.data!.docs.length,
                ),
              );
            },
          ),
          
          // Spacer bawah
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}