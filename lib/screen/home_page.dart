import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/detail/postingan.dart';
import 'package:project_kelompok/template/photoboothpage.dart';
import 'package:project_kelompok/template/photoboothpage2.dart';
import 'package:project_kelompok/template/template_vintage.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static bool hasShownWelcome = false;
  String _displayName = "Fotografer";
  String? _profileImageUrl;
  List<String> _photoUrls = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadPhotos();
    if (!hasShownWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeMessage();
        hasShownWelcome = true;
      });
    }
  }

  int _getGridCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 5;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  void _showWelcomeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.waving_hand, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Selamat datang! Nikmati & tangkap momen mu ✨",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null && mounted) {
          final data = doc.data()!;
          setState(() {
            _displayName = data['nama'] ?? user.displayName ?? "Fotografer";
            _profileImageUrl = data['photo_url'];
          });
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }
    }
  }

  Future<void> _loadPhotos() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final List<FileObject> objects = await SupabaseService.client.storage
          .from('photos')
          .list(path: 'uploads/$userId');

      final images = objects.where((obj) {
        final name = obj.name.toLowerCase();
        return name.endsWith('.png') ||
            name.endsWith('.jpg') ||
            name.endsWith('.jpeg');
      }).toList();

      images.sort((a, b) => b.name.compareTo(a.name));

      final List<String> urls = images
          .map(
            (obj) => SupabaseService.client.storage
                .from('photos')
                .getPublicUrl('uploads/$userId/${obj.name}'),
          )
          .toList();

      if (mounted) {
        setState(() {
          _photoUrls = urls;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error load photos: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(String imageUrl) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Foto?"),
        content: const Text(
          "Foto ini akan dihapus permanen. Jika sudah diposting, postingan juga akan hilang.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto(imageUrl);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;
      final path = 'uploads/${user.uid}/$fileName';

      await SupabaseService.client.storage.from('photos').remove([path]);

      final postsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .where('post_image', isEqualTo: imageUrl)
          .get();

      for (var doc in postsQuery.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _photoUrls.remove(imageUrl);
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Foto berhasil dihapus.")));
    } catch (e) {
      debugPrint("Error deleting photo: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus foto.")));
    }
  }

  Widget _buildTemplateCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Icon(icon, size: 30, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    final imageUrl = _photoUrls[index];
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: user?.uid)
          .where('post_image', isEqualTo: imageUrl)
          .snapshots(),
      builder: (context, snapshot) {
        bool isAlreadyPosted =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return GestureDetector(
          onLongPress: isAlreadyPosted
              ? null
              : () => _showPostConfirmation(imageUrl),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: isAlreadyPosted
                            ? "Sudah Diposting"
                            : "Posting ke Publik",
                        icon: Icon(
                          isAlreadyPosted
                              ? Icons.cloud_done
                              : Icons.send_rounded,
                          color: isAlreadyPosted ? Colors.green : Colors.orange,
                        ),
                        onPressed: isAlreadyPosted
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Foto ini sudah ada di postingan publik!",
                                    ),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            : () => _showPostConfirmation(imageUrl),
                      ),
                      IconButton(
                        tooltip: "Hapus Foto",
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _confirmDelete(imageUrl),
                      ),
                      IconButton(
                        tooltip: "Lihat Detail",
                        icon: const Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.blue,
                          size: 22,
                        ),
                        onPressed: () => _showDetailPhoto(imageUrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetailPhoto(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostConfirmation(String imageUrl) {
    String detectedTemplate = 'classic_2'; // Default

    // --- LOGIKA DETEKSI YANG BARU ---
    if (imageUrl.contains('C4_')) {
      detectedTemplate = 'classic_4';
    } else if (imageUrl.contains('V1_')) {
      // Ini tambahannya!
      detectedTemplate = 'vintage';
    } else if (imageUrl.contains('C2_')) {
      detectedTemplate = 'classic_2';
    }
    // --------------------------------

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Posting ke Explore?"),
        content: Text(
          // Update text dialognya biar dinamis
          "Sistem mendeteksi ini adalah ${detectedTemplate == 'vintage' ? 'Vintage' : (detectedTemplate == 'classic_4' ? 'Classic 4' : 'Classic 2')}. "
          "Karya kamu akan muncul di halaman publik.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Kirim detectedTemplate yang sudah benar ke database
              _postImage(imageUrl, detectedTemplate);
            },
            child: const Text(
              "Ya, Posting!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _postImage(String imageUrl, String templateType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'uid': user.uid,
        'nama': _displayName,
        'user_image': _profileImageUrl,
        'post_image': imageUrl,
        'template_type': templateType,
        'timestamp': FieldValue.serverTimestamp(),
        'views': 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil diposting ke publik! 🚀")),
      );
    } catch (e) {
      debugPrint("Error posting image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal memposting foto.")));
    }
  }

  Widget _buildTabButton(int index, String title) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.black38,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: isActive ? 40 : 0,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_photoUrls.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text("Belum ada karya yang tersimpan."),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridCount(context),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.6,
      ),
      itemCount: _photoUrls.length,
      itemBuilder: (context, index) => _buildPhotoItem(index),
    );
  }

  Widget _buildPostingsGrid() {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: user?.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Kamu belum memposting karya ke publik."),
            ),
          );
        }

        final posts = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getGridCount(context),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.65,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postData = posts[index].data() as Map<String, dynamic>;
            final postId = posts[index].id;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PostDetailPage(postId: postId, postData: postData),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        postData['post_image'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.public,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Photo Booth App'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah kamu yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        hasShownWelcome = false;

                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow[700]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            (_profileImageUrl != null &&
                                _profileImageUrl!.isNotEmpty)
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child:
                            (_profileImageUrl == null ||
                                _profileImageUrl!.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $_displayName!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Pilih template untuk mulai memotret:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildTemplateCard(
                      title: "Classic 2",
                      icon: Icons.filter_2,
                      color: Colors.blue[100]!,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhotoBoothPage2(),
                          ),
                        );
                        if (result == true) _loadPhotos();
                      },
                    ),
                    _buildTemplateCard(
                      title: "Classic 4",
                      icon: Icons.filter_4,
                      color: Colors.purple[100]!,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhotoBoothPage(),
                          ),
                        );
                        if (result == true) _loadPhotos();
                      },
                    ),
                    _buildTemplateCard(
                      title: "Vintage",
                      icon: Icons.camera_roll,
                      color: Colors.green[100]!,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TemplateVintage(),
                          ),
                        );
                        if (result == true) _loadPhotos();
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _buildTabButton(0, "Karya Saya"),
                    const SizedBox(width: 25),
                    _buildTabButton(1, "Postingan Saya"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _selectedTab == 0
                    ? _buildGalleryGrid()
                    : _buildPostingsGrid(),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 0),
    );
  }
}
