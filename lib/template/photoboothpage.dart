import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';

class PhotoBoothPage extends StatefulWidget {
  const PhotoBoothPage({super.key});

  @override
  State<PhotoBoothPage> createState() => _PhotoBoothPageState();
}

class _PhotoBoothPageState extends State<PhotoBoothPage> {
  final List<File?> _imageFiles = List.filled(4, null);
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isLoading = false;

  Future<void> _pickImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Atur Posisi Foto',
          toolbarColor: Colors.yellow[700],
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Atur Posisi Foto'),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _imageFiles[index] = File(croppedFile.path);
      });
    }
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(
        pixelRatio: 3.0,
      );
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error manual capture: $e");
      return null;
    }
  }

  Future<void> _captureAndUpload() async {
    if (_imageFiles.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi ke-4 foto terlebih dahulu!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw "Sesi login habis.";

      final imageBytes = await _capturePng();
      if (imageBytes == null) throw "Gagal mengambil gambar. Coba lagi.";

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/photostrip_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(imageBytes);

      final fileName = 'strip_${DateTime.now().millisecondsSinceEpoch}.png';

      await SupabaseService.client.storage
          .from('photos')
          .upload('uploads/$userId/$fileName', file);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Gagal Simpan"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Photostrip")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.all(12),
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(
                              4,
                              (index) => GestureDetector(
                                onTap: () => _pickImage(index),
                                child: Container(
                                  height: 140,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: _imageFiles[index] == null
                                      ? const Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey,
                                        )
                                      : Image.file(
                                          _imageFiles[index]!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "PHOTOBOOTH MOMENT",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _captureAndUpload,
                    icon: const Icon(Icons.save_alt),
                    label: const Text("Simpan Photostrip"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }
}
