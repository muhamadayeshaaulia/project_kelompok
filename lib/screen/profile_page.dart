import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller
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
      debugPrint("Load Error: $e");
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
          : Stack(
              children: [
                _header(),
                _content(),
              ],
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC02D), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 120),
          _avatar(),
          const SizedBox(height: 16),
          _card(),
        ],
      ),
    );
  }

  // ================= AVATAR =================
  Widget _avatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
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
          if (isEditing)
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFFFC02D),
              child: Icon(Icons.camera_alt, size: 16),
            ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _card() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field("Nama Lengkap", nameCtrl),
              _genderDropdown(),
              _readonly("Email", user?.email ?? "-"),
              _field("Alamat", addressCtrl),
              _field("Sosial Media", socialCtrl),
              _field("Tentang Saya", descCtrl, maxLines: 3),
              const SizedBox(height: 20),
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC02D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan Perubahan",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FORM =================
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