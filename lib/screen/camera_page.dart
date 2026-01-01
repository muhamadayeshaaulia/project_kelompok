import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_kelompok/template/photoboothpage.dart';
import 'package:project_kelompok/template/photoboothpage2.dart';


class CameraPage extends StatefulWidget {
  final int photoCount; // Masukkan angka 2 saat memanggil halaman ini
  const CameraPage({super.key, required this.photoCount});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final List<File> _capturedPhotos = []; // Keranjang penampung foto
  final ImagePicker _picker = ImagePicker();

  // Fungsi Buka Kamera Bawaan
  Future<void> _takeNextPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.front, // Kamera depan
      );

      if (photo != null) {
        setState(() {
          _capturedPhotos.add(File(photo.path));
        });
      }
    } catch (e) {
      debugPrint("Error ambil foto: $e");
    }
  }

  // Fungsi Reset (Ulang Foto)
  void _resetPhotos() {
    setState(() {
      _capturedPhotos.clear();
    });
  }

  void _goToEditingPage() {
    if (widget.photoCount == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage2(
            initialImages: _capturedPhotos,
          ),
        ),
      );
    } else if (widget.photoCount == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage(
            initialImages: _capturedPhotos,
          ),
        ),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Template untuk ${widget.photoCount} foto belum tersedia.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah jumlah foto sudah sesuai target (misal: 2)
    bool isComplete = _capturedPhotos.length >= widget.photoCount;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Ambil Foto (${_capturedPhotos.length}/${widget.photoCount})"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _resetPhotos,
            icon: const Icon(Icons.refresh),
            tooltip: "Ulangi Foto",
          )
        ],
      ),
      body: Column(
        children: [
          // --- BAGIAN 1: PREVIEW GRID SEDERHANA ---
          // Ini cuma buat user liat dia udah foto apa aja sebelum masuk template asli
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.photoCount == 2 ? 1 : 2, // 1 kolom kalau 2 foto
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 4/3,
                ),
                itemCount: widget.photoCount,
                itemBuilder: (context, index) {
                  if (index < _capturedPhotos.length) {
                    // Tampilkan Foto yang sudah diambil
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: FileImage(_capturedPhotos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    // Tampilkan Kotak Kosong (Placeholder)
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white54, 
                            fontSize: 40, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // --- BAGIAN 2: TOMBOL KONTROL ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isComplete)
                  // TOMBOL JEPRET (Muncul kalau foto belum lengkap)
                  ElevatedButton.icon(
                    onPressed: _takeNextPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text("Ambil Foto #${_capturedPhotos.length + 1}"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  // TOMBOL LANJUT (Muncul kalau foto sudah lengkap)
                  ElevatedButton.icon(
                    onPressed: _goToEditingPage, // <-- PANGGIL FUNGSI PINDAH HALAMAN
                    icon: const Icon(Icons.edit),
                    label: const Text("Lanjut Edit Frame"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      backgroundColor: Colors.green, // Warna hijau tanda siap
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}