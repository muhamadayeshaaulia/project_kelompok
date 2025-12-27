import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gal/gal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_kelompok/services/supabase_service.dart';

class PhotoBoothPage extends StatefulWidget {
  const PhotoBoothPage({super.key});

  @override
  State<PhotoBoothPage> createState() => _PhotoBoothPageState();
}

class _PhotoBoothPageState extends State<PhotoBoothPage> {
  // 1. VARIABLE WARNA FRAME (Default Putih)
  Color _frameColor = Colors.white;

  // Daftar Pilihan Warna
  final List<Color> _colorOptions = [
    Colors.white,
    Colors.black,
    const Color(0xFFF8BBD0), // Pink Soft
    const Color(0xFFBBDEFB), // Biru Soft
    const Color(0xFFC8E6C9), // Hijau Soft
    const Color(0xFFFFF9C4), // Kuning Soft
    Colors.redAccent,
    Colors.blueGrey,
  ];

  final List<Uint8List?> _imageBytesList = List.filled(4, null);
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isLoading = false;

  /// Fungsi Pick Image (Simple tanpa ribet setting web)
  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        // Kita pakai setting standard saja biar gak error
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Potong Foto'),
        ],
      );

      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        setState(() {
          _imageBytesList[index] = bytes;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  /// Fungsi Capture & Upload
  Future<void> _captureAndUpload() async {
    if (_imageBytesList.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua 4 foto dulu ya!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw "Login dulu bro.";

      await Future.delayed(const Duration(milliseconds: 100));
      RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw "Gagal render.";

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final fullImageBytes = byteData?.buffer.asUint8List();

      if (fullImageBytes == null) throw "Gambar kosong.";

      // Simpan ke Galeri HP
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/photostrip.png').create();
        await file.writeAsBytes(fullImageBytes);
        await Gal.putImage(file.path, album: 'PhotoBooth');
      }

      // Upload Supabase
      final fileName = 'strip_${DateTime.now().millisecondsSinceEpoch}.png';
      await SupabaseService.client.storage.from('photos').uploadBinary(
            'uploads/$userId/$fileName',
            fullImageBytes,
            fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mantap! Tersimpan & Terupload.")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna teks (Kalau background gelap, teks jadi putih)
    bool isDark = _frameColor.computeLuminance() < 0.5;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color borderColor = isDark ? Colors.white24 : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(title: const Text("Custom Photostrip")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // --- PREVIEW PHOTOSTRIP ---
                  Center(
                    child: RepaintBoundary( // Area yang akan di-screenshot
                      key: _boundaryKey,
                      child: AnimatedContainer( // Pakai Animated biar mulus transisi warnanya
                        duration: const Duration(milliseconds: 300),
                        width: 240, // Lebar strip
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _frameColor, // INI WARNA CUSTOMNYA
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Loop 4 Foto
                            ...List.generate(4, (index) {
                              return GestureDetector(
                                onTap: () => _pickImage(index),
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    border: Border.all(color: borderColor, width: 2),
                                  ),
                                  child: _imageBytesList[index] == null
                                      ? Icon(Icons.add_a_photo, color: Colors.grey[400])
                                      : Image.memory(
                                          _imageBytesList[index]!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              );
                            }),
                            
                            // Tulisan Bawah
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "MOMENTS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  fontSize: 12,
                                  color: textColor, // Warna teks menyesuaikan background
                                ),
                              ),
                            ),
                            Text(
                              "2025",
                              style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // --- PILIHAN WARNA (COLOR PICKER) ---
                  const Text("Pilih Warna Frame:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _colorOptions.length,
                      itemBuilder: (context, index) {
                        final color = _colorOptions[index];
                        final isSelected = _frameColor == color;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _frameColor = color;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey[300]!,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                              ]
                            ),
                            child: isSelected 
                              ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                              : null,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- TOMBOL SAVE ---
                  ElevatedButton.icon(
                    onPressed: _captureAndUpload,
                    icon: const Icon(Icons.save_alt, color: Colors.white),
                    label: const Text("Simpan Photostrip", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}