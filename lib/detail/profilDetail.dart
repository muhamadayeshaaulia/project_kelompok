import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/user_list_page.dart';

class Profildetail extends StatefulWidget {
  final String uid;

  const Profildetail({super.key, required this.uid});

  @override
  State<Profildetail> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<Profildetail> {
  
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
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            FutureBuilder<DocumentSnapshot>(
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

                if (userData == null) return const Text("User tidak ditemukan");

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: userData['photo_url'] != null
                              ? NetworkImage(userData['photo_url'])
                              : null,
                          child: userData['photo_url'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          userData['nama'] ?? "Tanpa Nama",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Center(
                        child: Text(
                          userData['email'] ?? "-",
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('uid', isEqualTo: widget.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              int postCount = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;
                              return _buildStatColumn("Postingan", postCount, () {
                              });
                            },
                          ),
                          Container(height: 30, width: 1, color: Colors.grey[300]),
                          
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('followers')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int followerCount = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;
                              
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
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.uid)
                                .collection('following')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int followingCount = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;
                              return _buildStatColumn("Following", followingCount, () {
                                // TAMBAHKAN KODE NAVIGASI KE LIST FOLLOWING DISINI
                                debugPrint("Tombol Following Ditekan");
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(thickness: 1),
            
            // Judul Bagian Postingan (Dibuat Center)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Center(
                child: Text(
                  "Karya Pengguna Ini",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isEqualTo: widget.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text("Belum ada postingan."),
                    ),
                  );
                }

                // Grid View dengan padding yang seimbang
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0), // Padding tipis kiri kanan
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4, // Jarak antar foto horizontal
                      mainAxisSpacing: 4,  // Jarak antar foto vertikal
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var post = snapshot.data!.docs[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4), // Sedikit rounded biar bagus
                        child: Image.network(
                          post['post_image'],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20), // Spasi bawah agar tidak mentok
          ],
        ),
      ),
    );
  }
}