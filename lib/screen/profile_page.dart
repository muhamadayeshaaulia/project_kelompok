import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'package:image_cropper/image_cropper.dart';

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

  String? selectedGender;

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

  Future<void> _loadUserData() async {
    if (user == null) return;
    setState(() => isFetching = true);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data();
      setState(() {
        nameCtrl.text = data?['nama'] ?? '';
        genderCtrl.text = data?['jenis_kelamin'] ?? '';
        selectedGender =
            ["Laki laki", "Perempuan"].contains(genderCtrl.text)
                ? genderCtrl.text
                : null;
        addressCtrl.text = data?['alamat'] ?? '';
        descCtrl.text = data?['keterangan'] ?? '';
        socialMediaCtrl.text = data?['sosmed_link'] ?? '';
        _currentPhotoUrl = data?['photo_url'];
      });
    }

    if (mounted) setState(() => isFetching = false);
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Foto Profil',
            toolbarColor: Colors.yellow,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
        ],
      );

      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        final ext = croppedFile.path.split('.').last;
        setState(() {
          _imageBytes = bytes;
          _imageExtension = ext;
        });
      }
    }
  }

  Future<String?> _uploadImageToSupabase() async {
    if (_imageBytes == null || user == null) return null;

    String ext = _imageExtension ?? 'jpg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = 'profile/${user!.uid}/$fileName';

    await SupabaseService.client.storage.from('photos').uploadBinary(
          path,
          _imageBytes!,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: true,
          ),
        );

    return SupabaseService.client.storage.from('photos').getPublicUrl(path);
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => isSaving = true);

    String? newPhotoUrl;

    if (_imageBytes != null) {
      newPhotoUrl = await _uploadImageToSupabase();
    }

    final updateData = {
      'nama': nameCtrl.text,
      'jenis_kelamin': genderCtrl.text,
      'alamat': addressCtrl.text,
      'keterangan': descCtrl.text,
      'sosmed_link': socialMediaCtrl.text,
      'email': user!.email,
      'updated_at': DateTime.now(),
    };

    if (newPhotoUrl != null) {
      updateData['photo_url'] = newPhotoUrl;
      await user!.updatePhotoURL(newPhotoUrl);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .set(updateData, SetOptions(merge: true));

    if (mounted) {
      setState(() {
        _currentPhotoUrl = newPhotoUrl ?? _currentPhotoUrl;
        _imageBytes = null;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan')),
      );
    }

    setState(() => isSaving = false);
  }

  Future<void> _deleteAccount() async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .delete();

    await SupabaseService.client.storage
        .from('photos')
        .remove(['profile/${user!.uid}']);

    await user!.delete();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
        (_) => false,
      );
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyHomePage()),
            );
          },
        ),
        title: const Text("Profil", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) _loadUserData();
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pengaturan Personal",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildField("Nama Lengkap", nameCtrl, enabled: isEditing),
                    _buildGenderDropdown(),
                    _buildEmailField("Email", user?.email ?? ""),
                    _buildField("Alamat", addressCtrl, enabled: isEditing),
                    _buildField("Sosial Media (Link)", socialMediaCtrl,
                        enabled: isEditing),
                    _buildField("Tentang saya", descCtrl,
                        maxLines: 3, enabled: isEditing),
                    const SizedBox(height: 32),
                    const Text("Kontrol Akun",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyHomePage()),
                              (_) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                        ),
                        child: const Text("Keluar Akun",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Hapus Akun",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomButtomNav(currentIndex: 3),
    );
  }

  Widget _buildProfileImage() {
    if (_imageBytes != null) {
      return Image.memory(_imageBytes!, fit: BoxFit.cover);
    }
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return Image.network(_currentPhotoUrl!, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: !enabled,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildEmailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        items: const [
          DropdownMenuItem(value: "Laki laki", child: Text("Laki laki")),
          DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
        ],
        onChanged: isEditing
            ? (value) {
                setState(() {
                  selectedGender = value;
                  genderCtrl.text = value ?? '';
                });
              }
            : null,
        decoration: InputDecoration(
          labelText: "Jenis Kelamin",
          filled: !isEditing,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
