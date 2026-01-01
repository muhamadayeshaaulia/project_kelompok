import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../screen/home_page.dart';
import '../widgats/custom_buttom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ================= USER =================
  final user = FirebaseAuth.instance.currentUser;

  // ================= CONTROLLER =================
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String? selectedGender;
  String? photoUrl;

  Uint8List? imageBytes;
  String? imageExt;

  bool isEditing = false;
  bool isLoading = true;
  bool isSaving = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ================= LOAD DATA =================
  Future<void> _loadUser() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameCtrl.text = data['nama'] ?? '';
      addressCtrl.text = data['alamat'] ?? '';
      descCtrl.text = data['keterangan'] ?? '';
      selectedGender = data['jenis_kelamin'];
      photoUrl = data['photo_url'];
    }

    setState(() => isLoading = false);
  }

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      imageBytes = await img.readAsBytes();
      imageExt = img.name.split('.').last;
      setState(() {});
    }
  }

  // ================= UPLOAD IMAGE =================
  Future<String?> _uploadImage() async {
    if (imageBytes == null) return null;

    final ext = imageExt ?? 'jpg';
    final fileName = 'profile_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final path = 'profile/$fileName';

    await SupabaseService.client.storage.from('photos').uploadBinary(
      path,
      imageBytes!,
      fileOptions: FileOptions(
        upsert: true,
        contentType: 'image/$ext',
      ),
    );

    return SupabaseService.client.storage.from('photos').getPublicUrl(path);
  }

  // ================= SAVE PROFILE =================
  Future<void> _saveProfile() async {
    setState(() => isSaving = true);

    try {
      String? newPhoto;

      if (imageBytes != null) {
        newPhoto = await _uploadImage();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'nama': nameCtrl.text,
        'alamat': addressCtrl.text,
        'keterangan': descCtrl.text,
        'jenis_kelamin': selectedGender,
        'photo_url': newPhoto ?? photoUrl,
        'updated_at': Timestamp.now(),
      }, SetOptions(merge: true));

      photoUrl = newPhoto ?? photoUrl;
      imageBytes = null;
      isEditing = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil disimpan")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  // ================= REMOVE PHOTO =================
  void _removePhoto() {
    setState(() {
      imageBytes = null;
      photoUrl = null;
    });
  }

  // ================= PHOTO ACTION =================
  void _showPhotoAction() {
    if (!isEditing) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Ganti Foto"),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Hapus Foto"),
            onTap: () {
              Navigator.pop(context);
              _removePhoto();
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
        title: const Text("Profil"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
            child: Text(isEditing ? "Batal" : "Edit"),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _header(),
                  _avatar(),
                  _profileForm(),
                ],
              ),
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC02D), Color(0xFFFFE082)],
        ),
      ),
    );
  }

  // ================= AVATAR =================
  Widget _avatar() {
    ImageProvider? img;

    if (imageBytes != null) {
      img = MemoryImage(imageBytes!);
    } else if (photoUrl != null) {
      img = NetworkImage(photoUrl!);
    }

    return Transform.translate(
      offset: const Offset(0, -40),
      child: GestureDetector(
        onTap: _showPhotoAction,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: img,
                child: img == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            if (isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 16,
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= FORM =================
  Widget _profileForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field("Nama Lengkap", nameCtrl),
              _gender(),
              _field("Alamat", addressCtrl),
              _field("Tentang Saya", descCtrl, maxLines: 3),
              const SizedBox(height: 12),
              if (isEditing)
                ElevatedButton(
                  onPressed: isSaving ? null : _saveProfile,
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan"),
                ),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _gender() {
    return DropdownButtonFormField<String>(
      value: ["Laki laki", "Perempuan"].contains(selectedGender)
          ? selectedGender
          : null,
      items: const [
        DropdownMenuItem(value: "Laki laki", child: Text("Laki laki")),
        DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
      ],
      onChanged: isEditing ? (v) => setState(() => selectedGender = v) : null,
      decoration: const InputDecoration(labelText: "Jenis Kelamin"),
    );
  }
}
