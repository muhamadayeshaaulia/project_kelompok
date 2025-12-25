import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'package:project_kelompok/template/photoboothpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _displayName = "Fotografer";
  List<String> _photoUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadPhotos();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            _displayName =
                doc.data()!['nama'] ??
                user.displayName ??
                user.email?.split('@')[0] ??
                "Fotografer";
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
      setState(() => _isLoading = true);
      final objects = await SupabaseService.client.storage
          .from('photos')
          .list(path: 'uploads/$userId');

      final List<String> urls = objects.map((obj) {
        return SupabaseService.client.storage
            .from('photos')
            .getPublicUrl('uploads/$userId/${obj.name}');
      }).toList();

      setState(() {
        _photoUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load photos: $e");
      setState(() => _isLoading = true);
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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(_photoUrls[index]),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
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
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  _photoUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
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
      extendBody: true,
      appBar: AppBar(
        title: const Text('Photo Booth App'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $_displayName!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Pilih template untuk mulai memotret:',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
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
                    title: "Classic 4",
                    icon: Icons.filter_4,
                    color: Colors.orange[100]!,
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
                    title: "Grid 2x2",
                    icon: Icons.grid_view,
                    color: Colors.blue[100]!,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coming Soon!")),
                    ),
                  ),
                  _buildTemplateCard(
                    title: "Vintage",
                    icon: Icons.camera_roll,
                    color: Colors.green[100]!,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Hasil Karya Saya',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _photoUrls.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada foto buatanmu.",
                        style: TextStyle(color: Colors.black45),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.6,
                          ),
                      itemCount: _photoUrls.length,
                      itemBuilder: (context, index) {
                        return _buildPhotoItem(index);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 0),
    );
  }
}
