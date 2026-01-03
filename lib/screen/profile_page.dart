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
    List<String> words = lowerName.split(" ");
    for (String word in words) {
      String temp = "";
      for (var i = 0; i < word.length; i++) {
        temp = temp + word[i];
        if (!keywords.contains(temp)) keywords.add(temp);
      }
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
      } catch (e) {
        debugPrint("Post Storage Cleanup Error: $e");
      }
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
      } catch (e) {
        debugPrint("Profile Storage Cleanup Error: $e");
      }
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
      for (var doc in globalFollowers.docs) {
        if (doc.id == uid) await doc.reference.delete();
      }

      final globalFollowing = await firestore
          .collectionGroup('following')
          .get();
      for (var doc in globalFollowing.docs) {
        if (doc.id == uid) await doc.reference.delete();
      }

      final globalLikes = await firestore.collectionGroup('likes').get();
      for (var doc in globalLikes.docs) {
        if (doc.id == uid) await doc.reference.delete();
      }

      final globalComments = await firestore
          .collectionGroup('comments')
          .where('uid', isEqualTo: uid)
          .get();
      for (var doc in globalComments.docs) {
        await doc.reference.delete();
      }
      await firestore.collection('users').doc(uid).delete();
      await firestore.terminate();
      await firestore.clearPersistence();
      await user!.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Akun dan seluruh karya berhasil dihapus"),
            backgroundColor: Colors.red,
          ),
        );
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Profil", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (isEditing) {
                  _initControllers();
                  _loadUserData();
                }
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? "Batal" : "Edit",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildStatsSection(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoField(
                              "Nama Lengkap",
                              nameCtrl,
                              isEditing,
                            ),
                            _buildGenderSection(),
                            _buildInfoField("Alamat", addressCtrl, isEditing),
                            _buildSocialSection(),
                            _buildInfoField(
                              "Tentang Saya",
                              descCtrl,
                              isEditing,
                              maxLines: 3,
                            ),
                            if (isEditing) _buildSaveButton(),
                            if (!isEditing)
                              Center(
                                child: TextButton(
                                  onPressed: _deleteAccount,
                                  child: const Text(
                                    "Hapus Akun Permanen",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSaving)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: isEditing ? _pickImage : null,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 47,
                backgroundImage: _getProfileImage(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nameCtrl.text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem("Post", postCount),
          _statItem("Followers", followerCount),
          _statItem("Following", followingCount),
        ],
      ),
    );
  }

  Widget _statItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController ctrl,
    bool editing, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          editing
              ? TextField(
                  controller: ctrl,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                )
              : Text(
                  ctrl.text.isEmpty ? "-" : ctrl.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          isEditing
              ? Row(
                  children: [
                    _genderOpt("Laki-laki", Icons.male, Colors.blue),
                    const SizedBox(width: 10),
                    _genderOpt("Perempuan", Icons.female, Colors.pink),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      genderCtrl.text == "Laki-laki"
                          ? Icons.male
                          : Icons.female,
                      color: genderCtrl.text == "Laki-laki"
                          ? Colors.blue
                          : Colors.pink,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      genderCtrl.text.isEmpty ? "-" : genderCtrl.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
              Text(val, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sosial Media",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          isEditing
              ? TextField(
                  controller: socialMediaCtrl,
                  decoration: InputDecoration(
                    hintText: "github.com/user, ...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              : _buildSocialIcons(),
        ],
      ),
    );
  }

  Widget _buildSocialIcons() {
    List<String> links = socialMediaCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (links.isEmpty) return const Text("-");
    return Wrap(
      spacing: 12,
      children: links
          .map(
            (url) => GestureDetector(
              onTap: () => _launchURL(url),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: _getSocialIcon(url),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _getSocialIcon(String url) {
    String lowerUrl = url.toLowerCase();
    if (lowerUrl.contains("github.com"))
      return const FaIcon(FontAwesomeIcons.github, size: 20);
    if (lowerUrl.contains("instagram.com"))
      return const FaIcon(
        FontAwesomeIcons.instagram,
        color: Colors.pink,
        size: 20,
      );
    if (lowerUrl.contains("facebook.com"))
      return const FaIcon(
        FontAwesomeIcons.facebook,
        color: Colors.blue,
        size: 20,
      );
    return const FaIcon(FontAwesomeIcons.link, size: 18);
  }

  Future<void> _launchURL(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;
    final Uri uri = Uri.parse(
      cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication))
      debugPrint("Error launch");
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

  dynamic _getProfileImage() {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
      return NetworkImage(_currentPhotoUrl!);
    return null;
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
      _loadUserData();
    } finally {
      setState(() => isSaving = false);
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

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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
}
