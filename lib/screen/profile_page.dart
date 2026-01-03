import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final socialMediaCtrl = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  bool isEditing = false;
  bool isSaving = false;
  bool isFetching = true;

  Uint8List? _imageBytes;
  String? _imageExtension;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Widget _getSocialIcon(String url) {
    String lowerUrl = url.toLowerCase();
    if (lowerUrl.contains("github.com"))
      return const FaIcon(
        FontAwesomeIcons.github,
        color: Color(0xFF181717),
        size: 22,
      );
    if (lowerUrl.contains("instagram.com"))
      return const FaIcon(
        FontAwesomeIcons.instagram,
        color: Color(0xFFE4405F),
        size: 22,
      );
    if (lowerUrl.contains("facebook.com"))
      return const FaIcon(
        FontAwesomeIcons.facebook,
        color: Color(0xFF1877F2),
        size: 22,
      );
    if (lowerUrl.contains("twitter.com") || lowerUrl.contains("x.com"))
      return const FaIcon(
        FontAwesomeIcons.xTwitter,
        color: Colors.black,
        size: 22,
      );
    if (lowerUrl.contains("linkedin.com"))
      return const FaIcon(
        FontAwesomeIcons.linkedin,
        color: Color(0xFF0077B5),
        size: 22,
      );
    if (lowerUrl.contains("youtube.com"))
      return const FaIcon(
        FontAwesomeIcons.youtube,
        color: Color(0xFFFF0000),
        size: 22,
      );
    if (lowerUrl.contains("tiktok.com"))
      return const FaIcon(
        FontAwesomeIcons.tiktok,
        color: Colors.black,
        size: 22,
      );
    return const FaIcon(FontAwesomeIcons.link, color: Colors.grey, size: 20);
  }

  Future<void> _launchURL(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;
    final Uri uri = Uri.parse(
      cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl',
    );
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication))
        throw 'Error';
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
    }
  }
  Future<void> _loadUserData() async {
    if (user == null) return;
    setState(() => isFetching = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          nameCtrl.text = data?['nama'] ?? '';
          genderCtrl.text = data?['jenis_kelamin'] ?? '';
          addressCtrl.text = data?['alamat'] ?? '';
          descCtrl.text = data?['keterangan'] ?? '';
          socialMediaCtrl.text = data?['sosmed_link'] ?? '';
          _currentPhotoUrl = data?['photo_url'];
        });
      }
    } finally {
      if (mounted) setState(() => isFetching = false);
    }
  }

  Future<bool> _reauthenticateUser() async {
    final passwordCtrl = TextEditingController();
    bool success = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Kata Sandi"),
        content: TextField(
          controller: passwordCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Kata Sandi"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                AuthCredential cred = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: passwordCtrl.text.trim(),
                );
                await user!.reauthenticateWithCredential(cred);
                success = true;
                if (mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Salah!")));
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
    return success;
  }

  Future<void> _deleteAccount() async {
    if (user == null) return;
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: const Text(
          "Semua folder data, postingan, dan like akan hilang.",
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
      final uid = user!.uid;
      final firestore = FirebaseFirestore.instance;
      final comments = await firestore
          .collectionGroup('comments')
          .where('uid', isEqualTo: uid)
          .get();
      for (var doc in comments.docs) {
        await doc.reference.delete();
      }
      final posts = await firestore.collection('posts').get();
      for (var pDoc in posts.docs) {
        await pDoc.reference.collection('likes').doc(uid).delete();
      }
      final allUsers = await firestore.collection('users').get();
      for (var uDoc in allUsers.docs) {
        await uDoc.reference.collection('followers').doc(uid).delete();
        await uDoc.reference.collection('following').doc(uid).delete();
      }
      await firestore.collection('users').doc(uid).delete();
      await firestore.terminate();
      await firestore.clearPersistence();

      try {
        await user!.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          setState(() => isSaving = false);
          if (await _reauthenticateUser()) {
            setState(() => isSaving = true);
            await user!.delete();
          } else {
            return;
          }
        }
      }
      if (mounted)
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      debugPrint("Error: $e");
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
            onPressed: () => setState(() {
              isEditing = !isEditing;
              if (!isEditing) _loadUserData();
            }),
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
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(255, 192, 45, 1),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: _buildProfileImage(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              nameCtrl.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField("Nama", nameCtrl, enabled: isEditing),
                            const Text(
                              "Jenis Kelamin",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            isEditing
                                ? _buildGenderSelection()
                                : _buildGenderDisplay(),
                            const SizedBox(height: 14),
                            _buildField(
                              "Alamat",
                              addressCtrl,
                              enabled: isEditing,
                            ),
                            const Text(
                              "Sosial Media (Pisahkan dengan koma)",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            isEditing
                                ? TextField(
                                    controller: socialMediaCtrl,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      hintText: "Link GitHub, IG, dll",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  )
                                : _buildSocialMediaDisplay(),
                            const SizedBox(height: 14),
                            _buildField(
                              "Tentang Saya",
                              descCtrl,
                              maxLines: 3,
                              enabled: isEditing,
                            ),
                            if (isEditing)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow[800],
                                  ),
                                  child: const Text(
                                    "Simpan",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: _deleteAccount,
                                child: const Text(
                                  "Hapus Akun",
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
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.yellow),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        Expanded(child: _genderBtn("Laki-laki", Icons.male, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _genderBtn("Perempuan", Icons.female, Colors.pink)),
      ],
    );
  }

  Widget _genderBtn(String val, IconData icon, Color color) {
    bool isSel = genderCtrl.text == val;
    return GestureDetector(
      onTap: () => setState(() => genderCtrl.text = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSel ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(val),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDisplay() {
    bool isM = genderCtrl.text == "Laki-laki";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isM ? Icons.male : Icons.female,
            color: isM ? Colors.blue : Colors.pink,
          ),
          const SizedBox(width: 10),
          Text(genderCtrl.text),
        ],
      ),
    );
  }

  Widget _buildSocialMediaDisplay() {
    List<String> links = socialMediaCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: links
          .map(
            (url) => GestureDetector(
              onTap: () => _launchURL(url),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: _getSocialIcon(url),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            decoration: InputDecoration(
              filled: !enabled,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_imageBytes != null)
      return Image.memory(_imageBytes!, fit: BoxFit.cover);
    if (_currentPhotoUrl != null)
      return Image.network(_currentPhotoUrl!, fit: BoxFit.cover);
    return const Icon(Icons.person, size: 50);
  }
  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    try {
      String? newUrl;
      if (_imageBytes != null) newUrl = await _uploadImageToSupabase();
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'nama': nameCtrl.text,
        'jenis_kelamin': genderCtrl.text,
        'alamat': addressCtrl.text,
        'sosmed_link': socialMediaCtrl.text,
        'keterangan': descCtrl.text,
        if (newUrl != null) 'photo_url': newUrl,
      }, SetOptions(merge: true));
      setState(() {
        isEditing = false;
        if (newUrl != null) _currentPhotoUrl = newUrl;
      });
    } finally {
      setState(() => isSaving = false);
    }
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
