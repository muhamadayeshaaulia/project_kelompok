import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'package:project_kelompok/detail/user_list_page.dart';
import 'package:project_kelompok/detail/postingan.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController genderCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController descCtrl;
  late TextEditingController socialMediaCtrl;

  final user = FirebaseAuth.instance.currentUser;
  bool isEditing = false;
  bool isSaving = false;
  bool isFetching = true;

  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;

  Uint8List? _imageBytes;
  String? _imageExtension;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadUserData();
  }

  void _initControllers() {
    nameCtrl = TextEditingController();
    genderCtrl = TextEditingController();
    addressCtrl = TextEditingController();
    descCtrl = TextEditingController();
    socialMediaCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    genderCtrl.dispose();
    addressCtrl.dispose();
    descCtrl.dispose();
    socialMediaCtrl.dispose();
    super.dispose();
  }

  List<String> _createSearchKeywords(String name) {
    List<String> keywords = [];
    String lowerName = name.toLowerCase().trim();
    String temp = "";
    for (var i = 0; i < lowerName.length; i++) {
      temp = temp + lowerName[i];
      keywords.add(temp);
    }
    return keywords;
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    setState(() => isFetching = true);
    try {
      final String uid = user!.uid;
      final firestore = FirebaseFirestore.instance;

      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          nameCtrl.text = data?['nama'] ?? '';
          genderCtrl.text = data?['jenis_kelamin'] ?? '';
          addressCtrl.text = data?['alamat'] ?? '';
          descCtrl.text = data?['keterangan'] ?? '';
          socialMediaCtrl.text = data?['sosmed_link'] ?? '';
          _currentPhotoUrl = data?['photo_url'];
          _imageBytes = null;
        });
      }

      final postsQuery = await firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();
      final followersQuery = await firestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .get();
      final followingQuery = await firestore
          .collection('users')
          .doc(uid)
          .collection('following')
          .get();

      if (mounted) {
        setState(() {
          postCount = postsQuery.docs.length;
          followerCount = followersQuery.docs.length;
          followingCount = followingQuery.docs.length;
        });
      }
    } finally {
      if (mounted) setState(() => isFetching = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    try {
      String? newUrl;
      if (_imageBytes != null) {
        await _deleteOldProfilePhotos();
        newUrl = await _uploadImageToSupabase();
      }
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'nama': nameCtrl.text,
        'jenis_kelamin': genderCtrl.text,
        'alamat': addressCtrl.text,
        'sosmed_link': socialMediaCtrl.text,
        'keterangan': descCtrl.text,
        'search_keywords': _createSearchKeywords(nameCtrl.text),
        if (newUrl != null) 'photo_url': newUrl,
      }, SetOptions(merge: true));

      setState(() {
        isEditing = false;
        if (newUrl != null) _currentPhotoUrl = newUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
      _loadUserData();
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _deleteAccount() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun Permanen?"),
        content: const Text(
          "Tindakan ini akan menghapus Postingan, Foto di Storage, serta semua jejak Like & Komentar Anda secara permanen.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => isSaving = true);

    try {
      final String uid = user!.uid;
      final firestore = FirebaseFirestore.instance;

      try {
        final List<FileObject> postFiles = await SupabaseService.client.storage
            .from('photos')
            .list(path: 'uploads/$uid');
        if (postFiles.isNotEmpty) {
          await SupabaseService.client.storage
              .from('photos')
              .remove(postFiles.map((e) => 'uploads/$uid/${e.name}').toList());
        }
      } catch (_) {}

      try {
        final List<FileObject> profileFiles = await SupabaseService
            .client
            .storage
            .from('photos')
            .list(path: 'profile/$uid');
        if (profileFiles.isNotEmpty) {
          await SupabaseService.client.storage
              .from('photos')
              .remove(
                profileFiles.map((e) => 'profile/$uid/${e.name}').toList(),
              );
        }
      } catch (_) {}

      final myPosts = await firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();
      for (var doc in myPosts.docs) {
        final pLikes = await doc.reference.collection('likes').get();
        for (var l in pLikes.docs) await l.reference.delete();
        final pComments = await doc.reference.collection('comments').get();
        for (var c in pComments.docs) await c.reference.delete();
        await doc.reference.delete();
      }

      final globalFollowers = await firestore
          .collectionGroup('followers')
          .get();
      for (var doc in globalFollowers.docs)
        if (doc.id == uid) await doc.reference.delete();

      final globalFollowing = await firestore
          .collectionGroup('following')
          .get();
      for (var doc in globalFollowing.docs)
        if (doc.id == uid) await doc.reference.delete();

      final globalLikes = await firestore.collectionGroup('likes').get();
      for (var doc in globalLikes.docs)
        if (doc.id == uid) await doc.reference.delete();

      final globalComments = await firestore
          .collectionGroup('comments')
          .where('uid', isEqualTo: uid)
          .get();
      for (var doc in globalComments.docs) await doc.reference.delete();

      await firestore.collection('users').doc(uid).delete();
      await user!.delete();

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Error Hapus: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const profileGradient = LinearGradient(
      colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: profileGradient),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: Colors.black,
            ),
            onPressed: () => setState(() {
              if (isEditing) _loadUserData();
              isEditing = !isEditing;
            }),
          ),
        ],
      ),
      body: isFetching
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: profileGradient,
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildProfileAvatar(),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _statItem("Post", postCount, () {}),
                                          _statItem(
                                            "Pengikut",
                                            followerCount,
                                            () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (c) => UserListPage(
                                                    title: "Pengikut",
                                                    uid: user!.uid,
                                                    collectionName: 'followers',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          _statItem(
                                            "Mengikuti",
                                            followingCount,
                                            () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (c) => UserListPage(
                                                    title: "Mengikuti",
                                                    uid: user!.uid,
                                                    collectionName: 'following',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  nameCtrl.text.isEmpty
                                      ? "User"
                                      : nameCtrl.text,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (descCtrl.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      descCtrl.text,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                if (addressCtrl.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          addressCtrl.text,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (!isEditing) _buildSocialIconsView(),
                              ],
                            ),
                          ),
                          if (isEditing)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _buildInfoField(
                                    "Nama Lengkap",
                                    nameCtrl,
                                    true,
                                  ),
                                  _buildGenderSection(),
                                  _buildInfoField("Alamat", addressCtrl, true),
                                  _buildInfoField(
                                    "Sosial Media",
                                    socialMediaCtrl,
                                    true,
                                    hint: "pisahkan link dengan koma",
                                  ),
                                  _buildInfoField(
                                    "Tentang Saya",
                                    descCtrl,
                                    true,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildSaveButton(),
                                  TextButton(
                                    onPressed: _deleteAccount,
                                    child: const Text(
                                      "Hapus Akun Permanen",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (!isEditing) ...[
                            const Divider(height: 1, thickness: 1),
                            Container(
                              alignment: Alignment
                                  .centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              child: const Text(
                                "Postingan Saya",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isEditing) _buildKaryaGrid(),
                  ],
                ),
                if (isSaving) _buildLoadingOverlay(),
              ],
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 4),
    );
  }

  Widget _buildKaryaGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Text("Belum ada karya."),
              ),
            ),
          );
        }
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            var post = snapshot.data!.docs[index];
            var postData = post.data() as Map<String, dynamic>;
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) =>
                      PostDetailPage(postId: post.id, postData: postData),
                ),
              ),
              child: Image.network(postData['post_image'], fit: BoxFit.cover),
            );
          }, childCount: snapshot.data!.docs.length),
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: isEditing ? _pickImage : null,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.grey[200],
              backgroundImage: _getProfileImage(),
              child: (_currentPhotoUrl == null && _imageBytes == null)
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialIconsView() {
    List<String> links = socialMediaCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (links.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Wrap(
        spacing: 15,
        children: links
            .map(
              (url) => GestureDetector(
                onTap: () => _launchURL(url),
                child: _getSocialIcon(url),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _getSocialIcon(String url) {
    String lowerUrl = url.toLowerCase();
    if (lowerUrl.contains("instagram.com"))
      return const FaIcon(
        FontAwesomeIcons.instagram,
        color: Colors.pink,
        size: 22,
      );
    if (lowerUrl.contains("facebook.com"))
      return const FaIcon(
        FontAwesomeIcons.facebook,
        color: Colors.blue,
        size: 22,
      );
    if (lowerUrl.contains("github.com"))
      return const FaIcon(
        FontAwesomeIcons.github,
        color: Colors.black,
        size: 22,
      );
    if (lowerUrl.contains("youtube.com"))
      return const FaIcon(
        FontAwesomeIcons.youtube,
        color: Colors.red,
        size: 22,
      );
    if (lowerUrl.contains("linkedin.com"))
      return const FaIcon(
        FontAwesomeIcons.linkedin,
        color: Colors.blue,
        size: 22,
      );
    return const FaIcon(FontAwesomeIcons.link, size: 18, color: Colors.black54);
  }

  Widget _statItem(String label, int count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController ctrl,
    bool editing, {
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Jenis Kelamin",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _genderOpt("Laki-laki", Icons.male, Colors.blue),
              const SizedBox(width: 10),
              _genderOpt("Perempuan", Icons.female, Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderOpt(String val, IconData icon, Color color) {
    bool sel = genderCtrl.text == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => genderCtrl.text = val),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? color : Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: sel ? color : Colors.grey, size: 18),
              const SizedBox(width: 5),
              Text(val, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[800],
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "SIMPAN PERUBAHAN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() => Container(
    color: Colors.black26,
    child: const Center(child: CircularProgressIndicator(color: Colors.yellow)),
  );

  dynamic _getProfileImage() {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
      return NetworkImage(_currentPhotoUrl!);
    return null;
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: Colors.yellow[700],
            activeControlsWidgetColor: Colors.yellow[700],
          ),
        ],
      );
      if (cropped != null) {
        final bytes = await cropped.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageExtension = cropped.path.split('.').last;
        });
      }
    }
  }

  Future<void> _deleteOldProfilePhotos() async {
    try {
      final List<FileObject> objects = await SupabaseService.client.storage
          .from('photos')
          .list(path: 'profile/${user!.uid}');
      if (objects.isNotEmpty) {
        await SupabaseService.client.storage
            .from('photos')
            .remove(
              objects.map((e) => 'profile/${user!.uid}/${e.name}').toList(),
            );
      }
    } catch (_) {}
  }

  Future<String?> _uploadImageToSupabase() async {
    final path =
        'profile/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.${_imageExtension ?? 'jpg'}';
    await SupabaseService.client.storage
        .from('photos')
        .uploadBinary(path, _imageBytes!);
    return SupabaseService.client.storage.from('photos').getPublicUrl(path);
  }

  Future<void> _launchURL(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;
    final Uri uri = Uri.parse(
      cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
