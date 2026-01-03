import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
      debugPrint("Error loading data: $e");
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sesi habis. Masukkan kata sandi untuk menghapus akun."),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Kata Sandi"),
            ),
          ],
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Kata sandi salah.")),
                );
              }
            },
            child: const Text("Konfirmasi"),
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
        title: const Text("Hapus Akun & Semua Data?"),
        content: const Text(
          "Tindakan ini permanen. Semua postingan, komentar, dan like Anda akan dihapus.",
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
        final List<FileObject> profileFiles = await SupabaseService
            .client
            .storage
            .from('photos')
            .list(path: 'profile/$uid');
        final List<FileObject> postFiles = await SupabaseService.client.storage
            .from('photos')
            .list(path: 'uploads/$uid');
        if (profileFiles.isNotEmpty) {
          await SupabaseService.client.storage
              .from('photos')
              .remove(
                profileFiles.map((e) => 'profile/$uid/${e.name}').toList(),
              );
        }
        if (postFiles.isNotEmpty) {
          await SupabaseService.client.storage
              .from('photos')
              .remove(postFiles.map((e) => 'uploads/$uid/${e.name}').toList());
        }
      } catch (e) {
        debugPrint("Storage Skip: $e");
      }
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
      final myPosts = await firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();
      for (var doc in myPosts.docs) {
        final subC = await doc.reference.collection('comments').get();
        for (var c in subC.docs) {
          await c.reference.delete();
        }
        final subL = await doc.reference.collection('likes').get();
        for (var l in subL.docs) {
          await l.reference.delete();
        }
        await doc.reference.delete();
      }
      final userRef = firestore.collection('users').doc(uid);
      final myFollowers = await userRef.collection('followers').get();
      for (var doc in myFollowers.docs) {
        await doc.reference.delete();
      }
      final myFollowing = await userRef.collection('following').get();
      for (var doc in myFollowing.docs) {
        await doc.reference.delete();
      }
      await userRef.delete();
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

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Akun Berhasil Dihapus.')));
      }
    } catch (e) {
      debugPrint("Error Total: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // --- SAVE & PICK IMAGE ---
  Future<void> _saveProfile() async {
    if (user == null) return;
    setState(() => isSaving = true);
    try {
      String? newPhotoUrl;
      if (_imageBytes != null) newPhotoUrl = await _uploadImageToSupabase();
      Map<String, dynamic> updateData = {
        'nama': nameCtrl.text,
        'jenis_kelamin': genderCtrl.text,
        'alamat': addressCtrl.text,
        'keterangan': descCtrl.text,
        'sosmed_link': socialMediaCtrl.text,
        'updated_at': DateTime.now(),
      };
      if (newPhotoUrl != null) updateData['photo_url'] = newPhotoUrl;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set(updateData, SetOptions(merge: true));
      if (mounted) {
        setState(() {
          if (newPhotoUrl != null) _currentPhotoUrl = newPhotoUrl;
          isEditing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil disimpan!')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<String?> _uploadImageToSupabase() async {
    if (_imageBytes == null || user == null) return null;
    String safeExt = _imageExtension ?? "jpg";
    final path =
        'profile/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.$safeExt';
    await SupabaseService.client.storage
        .from('photos')
        .uploadBinary(
          path,
          _imageBytes!,
          fileOptions: FileOptions(contentType: 'image/$safeExt', upsert: true),
        );
    return SupabaseService.client.storage.from('photos').getPublicUrl(path);
  }

  Future<void> _pickImage() async {
    if (!isEditing) return;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageExtension = croppedFile.path.split('.').last;
        });
      }
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
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
                              nameCtrl.text.isEmpty
                                  ? "Fotografer"
                                  : nameCtrl.text,
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
                            _buildField(
                              "Alamat",
                              addressCtrl,
                              enabled: isEditing,
                            ),
                            _buildField(
                              "Sosial Media",
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
                            if (isEditing)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.yellow[800],
                                  ),
                                  child: const Text(
                                    "Simpan Perubahan",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: isSaving ? null : _deleteAccount,
                                child: const Text(
                                  "Hapus Profil",
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

  Widget _buildProfileImage() {
    if (_imageBytes != null)
      return Image.memory(_imageBytes!, fit: BoxFit.cover);
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
      return Image.network(_currentPhotoUrl!, fit: BoxFit.cover);
    return const Icon(Icons.person, size: 50, color: Colors.grey);
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
}
