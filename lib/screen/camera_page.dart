import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_kelompok/template/photoboothpage2.dart';
import 'package:project_kelompok/template/photoboothpage.dart';

class CameraPage extends StatefulWidget {
  final int photoCount;

  const CameraPage({
    super.key, 
    required this.photoCount
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
    if (widget.photoCount == 2) {
      // Ke Template 2 Foto
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage2(initialImages: capturedImages),
        ),
      );
    } else {
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
          CameraPreview(controller!),

          Column(
            children: List.generate(widget.photoCount, (index) {
              bool isTaken = index < capturedImages.length;
              bool isCurrent = index == capturedImages.length;

              return Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCurrent ? Colors.yellow : Colors.white24,
                    ),
                  ),
                  child: isTaken
                      ? Image.file(capturedImages[index], fit: BoxFit.cover, color: Colors.black45, colorBlendMode: BlendMode.darken)
                      : null,
                ),
              );
            }),
          ),

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