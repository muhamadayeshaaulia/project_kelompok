import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:project_kelompok/widgats/custom_buttom_nav.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'dart:io';
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
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) setState(() => isFetching = false);
    }
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Atur Foto Profil',
            toolbarColor: Colors.yellow[700],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Atur Foto Profil'),
        ],
      );

      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        final extension = croppedFile.path.split('.').last;

        setState(() {
          _imageBytes = bytes;
          _imageExtension = extension;
        });
      }
    }
  }

  Future<String?> _uploadImageToSupabase() async {
    if (_imageBytes == null || user == null) return null;

    try {
      if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
        try {
          final uri = Uri.parse(_currentPhotoUrl!);
          final oldFileName = uri.pathSegments.last;
          await SupabaseService.client.storage.from('photos').remove([
            'profile/${user!.uid}/$oldFileName',
          ]);
          print("Foto lama berhasil dihapus");
        } catch (e) {
          print("Gagal hapus foto lama (mungkin tidak ada): $e");
        }
      }
      String safeExt = _imageExtension ?? "jpg";

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      final path = 'profile/${user!.uid}/$fileName';

      await SupabaseService.client.storage
          .from('photos')
          .uploadBinary(
            path,
            _imageBytes!,
            fileOptions: FileOptions(
              contentType: 'image/$safeExt',
              upsert: true,
            ),
          );

      final imageUrl = SupabaseService.client.storage
          .from('photos')
          .getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      print("GAGAL PROSES SUPABASE: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => isSaving = true);

    try {
      String? newPhotoUrl;

      if (_imageBytes != null) {
        newPhotoUrl = await _uploadImageToSupabase();
        if (newPhotoUrl == null) {
          throw Exception("Gagal upload gambar. Cek koneksi atau format file.");
        }
      }
      List<String> generateSearchKeywords(String name) {
        String cleanedName = name
            .toLowerCase()
            .replaceAll('.', '')
            .replaceAll(',', '');
        List<String> words = cleanedName.split(' ');
        return words.where((word) => word.isNotEmpty).toList();
      }

      Map<String, dynamic> updateData = {
        'nama': nameCtrl.text,
        'search_keywords': generateSearchKeywords(nameCtrl.text),
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
          if (newPhotoUrl != null) _currentPhotoUrl = newPhotoUrl;
          _imageBytes = null;
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan!')),
        );
      }
    } catch (e) {
      print("Error Saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          },
        ),
        title: const Text("Profil", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: isSaving
                ? null
                : () {
                    setState(() {
                      isEditing = !isEditing;
                      if (!isEditing) {
                        _imageBytes = null;
                        _loadUserData();
                      }
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
              child: Column(
                children: [
                  Container(
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
                        Stack(
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
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
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
                            if (isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nameCtrl.text.isEmpty ? "Fotografer" : nameCtrl.text,
                          style: const TextStyle(
                            color: Colors.black,
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
                        const Text(
                          "Pengaturan Personal",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          "Nama Lengkap",
                          nameCtrl,
                          enabled: isEditing,
                        ),
                        _buildField(
                          "Jenis Kelamin",
                          genderCtrl,
                          enabled: isEditing,
                        ),
                        _buildEmailField("Email", user?.email ?? ""),
                        _buildField("Alamat", addressCtrl, enabled: isEditing),
                        _buildField(
                          "Sosial Media (Link)",
                          socialMediaCtrl,
                          enabled: isEditing,
                        ),
                        _buildField(
                          "Tentang saya",
                          descCtrl,
                          maxLines: 3,
                          enabled: isEditing,
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Kontrol Akun",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        if (isEditing)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow[800],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Simpan Perubahan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),

                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Hapus Profil",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
      return Image.network(
        _currentPhotoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.red),
          );
        },
      );
    }

    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: value),
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal),
                ),
                child: const Icon(Icons.verified, color: Colors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
