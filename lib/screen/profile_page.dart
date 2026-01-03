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

  // --- LOGIKA SOSIAL MEDIA ---
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

  Future<void> _deleteAccount() async {
    if (user == null) return;
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: const Text("Semua data Anda akan dihapus permanen."),
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
      await firestore.collection('users').doc(uid).delete();
      await firestore.terminate();
      await firestore.clearPersistence();
      await user!.delete();
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
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Informasi Personal"),
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
                            const SizedBox(height: 30),
                            if (isEditing) _buildSaveButton(),
                            if (!isEditing) _buildDeleteButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSaving) _buildSavingOverlay(),
              ],
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(255, 192, 45, 1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: isEditing ? _pickImage : null,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _getProfileImage(),
                  ),
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
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
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          editing
              ? TextField(
                  controller: ctrl,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          isEditing
              ? Row(
                  children: [
                    _genderOption("Laki-laki", Icons.male, Colors.blue),
                    const SizedBox(width: 15),
                    _genderOption("Perempuan", Icons.female, Colors.pink),
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
                      size: 20,
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

  Widget _genderOption(String val, IconData icon, Color color) {
    bool isSelected = genderCtrl.text == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => genderCtrl.text = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 8),
              Text(
                val,
                style: TextStyle(color: isSelected ? color : Colors.black54),
              ),
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
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          isEditing
              ? TextField(
                  controller: socialMediaCtrl,
                  decoration: InputDecoration(
                    hintText: "Pisahkan dengan koma (github.com/user, ...)",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[800],
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "SIMPAN PERUBAHAN",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Center(
      child: TextButton(
        onPressed: _deleteAccount,
        child: const Text("Hapus Akun", style: TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.yellow),
      ),
    );
  }

  dynamic _getProfileImage() {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    if (_currentPhotoUrl != null) return NetworkImage(_currentPhotoUrl!);
    return null;
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
