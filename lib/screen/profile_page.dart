import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ================= CONTROLLER =================
  final nameCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final socialCtrl = TextEditingController();

  String? selectedGender;
  Uint8List? _imageBytes;
  String? _imageExtension;
  String? _photoUrl;

  final user = FirebaseAuth.instance.currentUser;

  bool isEditing = false;
  bool isSaving = false;
  bool isFetching = true;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ================= LOAD USER =================
  Future<void> _loadUser() async {
    if (user == null) return;

    setState(() => isFetching = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        nameCtrl.text = data['nama'] ?? '';
        genderCtrl.text = data['jenis_kelamin'] ?? '';
        selectedGender = genderCtrl.text.isEmpty ? null : genderCtrl.text;
        addressCtrl.text = data['alamat'] ?? '';
        descCtrl.text = data['keterangan'] ?? '';
        socialCtrl.text = data['sosmed_link'] ?? '';
        _photoUrl = data['photo_url'];
      }
    } catch (e) {
      debugPrint("Load error: $e");
    } finally {
      setState(() => isFetching = false);
    }
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    if (!isEditing) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      _imageBytes = await picked.readAsBytes();
      _imageExtension = picked.name.split('.').last;
      setState(() {});
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return null;

    final ext = (_imageExtension ?? 'jpg').toLowerCase();
    final safeExt = ['jpg', 'jpeg', 'png'].contains(ext) ? ext : 'jpg';

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$safeExt';
    final path = 'profile/$fileName';

    await SupabaseService.client.storage.from('photos').uploadBinary(
      path,
      _imageBytes!,
      fileOptions: FileOptions(
        contentType: 'image/$safeExt',
        upsert: true,
      ),
    );

    return SupabaseService.client.storage.from('photos').getPublicUrl(path);
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      String? newPhoto;

      if (_imageBytes != null) {
        newPhoto = await _uploadImage();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'nama': nameCtrl.text,
        'jenis_kelamin': selectedGender,
        'alamat': addressCtrl.text,
        'keterangan': descCtrl.text,
        'sosmed_link': socialCtrl.text,
        'email': user!.email,
        'photo_url': newPhoto ?? _photoUrl,
        'updated_at': Timestamp.now(),
      }, SetOptions(merge: true));

      setState(() {
        _photoUrl = newPhoto ?? _photoUrl;
        _imageBytes = null;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil disimpan")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  // ================= DELETE ACCOUNT =================
  Future<void> _deleteAccount() async {
    if (user == null) return;

    try {
      // Hapus Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .delete();

      // Hapus akun Auth
      await user!.delete();

      // Redirect
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus akun: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= CONFIRM DIALOG =================
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Akun"),
        content: const Text(
          "Akun dan seluruh data Anda akan dihapus secara permanen. "
          "Apakah Anda yakin?",
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Profil", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MyHomePage()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) _loadUser();
              });
            },
            child: Text(isEditing ? "Batal" : "Edit"),
          )
        ],
      ),
      body: isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _header(),
                  _avatar(),
                  _profileCard(),
                  _accountControlCard(),
                ],
              ),
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC02D), Color(0xFFFFE082)],
        ),
      ),
    );
  }

  // ================= AVATAR =================
  Widget _avatar() {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: GestureDetector(
        onTap: _pickImage,
        child: CircleAvatar(
          radius: 55,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _imageBytes != null
                ? MemoryImage(_imageBytes!)
                : (_photoUrl != null ? NetworkImage(_photoUrl!) : null)
                    as ImageProvider?,
            child: _photoUrl == null && _imageBytes == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
        ),
      ),
    );
  }

  // ================= PROFILE CARD =================
  Widget _profileCard() {
    return _card(
      title: "Informasi Pribadi",
      children: [
        _field("Nama Lengkap", nameCtrl),
        _genderDropdown(),
        _readonly("Email", user?.email ?? "-"),
        _field("Alamat", addressCtrl),
        _field("Sosial Media", socialCtrl),
        _field("Tentang Saya", descCtrl, maxLines: 3),
        if (isEditing)
          ElevatedButton(
            onPressed: isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC02D),
            ),
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Simpan Perubahan"),
          ),
      ],
    );
  }

  // ================= ACCOUNT CONTROL =================
  Widget _accountControlCard() {
    return _card(
      title: "Kontrol Akun",
      children: [
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text("Hapus Akun"),
          subtitle: const Text("Hapus akun secara permanen"),
          onTap: _showDeleteDialog,
        ),
      ],
    );
  }

  // ================= WIDGET HELPER =================
  Widget _card({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        enabled: isEditing,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: !isEditing,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: ["Laki laki", "Perempuan"].contains(selectedGender)
            ? selectedGender
            : null,
        items: const [
          DropdownMenuItem(value: "Laki laki", child: Text("Laki laki")),
          DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
        ],
        onChanged: isEditing
            ? (v) {
                setState(() {
                  selectedGender = v;
                  genderCtrl.text = v ?? '';
                });
              }
            : null,
        decoration: InputDecoration(
          labelText: "Jenis Kelamin",
          filled: !isEditing,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}