import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import KEDUA halaman editor kamu
import 'package:project_kelompok/template/photoboothpage2.dart'; // Yg 2 Foto
import 'package:project_kelompok/template/photoboothpage.dart';  // Yg 4 Foto (Pastikan nama filenya benar)

class CameraPage extends StatefulWidget {
  final int photoCount; // Bisa 2, bisa 4

  const CameraPage({
    super.key, 
    required this.photoCount // Wajib diisi saat dipanggil
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<File> capturedImages = [];
  bool isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (controller == null || !controller!.value.isInitialized || isTakingPicture) return;

    setState(() => isTakingPicture = true);
    HapticFeedback.mediumImpact();

    try {
      final image = await controller!.takePicture();
      
      setState(() {
        capturedImages.add(File(image.path));
        isTakingPicture = false;
      });

      // LOGIKA UTAMA: Cek apakah jumlah foto sudah sesuai target (2 atau 4)
      if (capturedImages.length < widget.photoCount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lanjut gaya ke-${capturedImages.length + 1}!"), 
              duration: const Duration(milliseconds: 500)
            ),
          );
        }
      } else {
        _finishAndNavigate();
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isTakingPicture = false);
    }
  }

  void _finishAndNavigate() {
    // ROUTING: Tentukan mau dibawa ke halaman mana
    if (widget.photoCount == 2) {
      // Ke Template 2 Foto
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage2(initialImages: capturedImages),
        ),
      );
    } else {
      // Ke Template 4 Foto (PhotoBoothPage)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage(initialImages: capturedImages),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Preview Kamera
          CameraPreview(controller!),

          // 2. Overlay Grid Dinamis
          // Membuat kotak-kotak sesuai jumlah foto (2 atau 4)
          Column(
            children: List.generate(widget.photoCount, (index) {
              // Cek apakah slot ini sedang aktif atau sudah difoto
              bool isTaken = index < capturedImages.length;
              bool isCurrent = index == capturedImages.length;

              return Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCurrent ? Colors.yellow : Colors.white24, // Kuning jika giliran sekarang
                      width: isCurrent ? 4 : 1,
                    ),
                  ),
                  child: isTaken
                      // Tampilkan hasil foto kecil jika sudah diambil
                      ? Image.file(capturedImages[index], fit: BoxFit.cover, color: Colors.black45, colorBlendMode: BlendMode.darken)
                      : null,
                ),
              );
            }),
          ),

          // 3. Info Teks
          Positioned(
            top: 40, left: 0, right: 0,
            child: Text(
              "FOTO ${capturedImages.length + 1} DARI ${widget.photoCount}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, 
                shadows: [Shadow(blurRadius: 4, color: Colors.black)]
              ),
            ),
          ),

          // 4. Tombol Shutter
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: FloatingActionButton.large(
                backgroundColor: Colors.white,
                onPressed: _takePhoto,
                child: const Icon(Icons.camera_alt, color: Colors.black),
              ),
            ),
          ),
          
          if (isTakingPicture)
             const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}