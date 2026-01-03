import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gal/gal.dart';
import 'package:project_kelompok/screen/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_kelompok/services/supabase_service.dart';

class PhotoBoothPage extends StatefulWidget {
  final List<File>? initialImages;

  const PhotoBoothPage({super.key, this.initialImages});

  @override
  State<PhotoBoothPage> createState() => _PhotoBoothPageState();
}

class _PhotoBoothPageState extends State<PhotoBoothPage> {
  Color _frameColor = Colors.white;

  final List<Color> _colorOptions = [
    Colors.white,
    Colors.black,
    const Color(0xFFF8BBD0),
    const Color(0xFFBBDEFB),
    const Color(0xFFC8E6C9),
    const Color(0xFFFFF9C4),
    Colors.redAccent,
    Colors.blueGrey,
  ];

  final List<Uint8List?> _imageBytesList = List.filled(4, null);
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null && widget.initialImages!.length == 4) {
      _loadCameraImages();
    }
  }

  Future<void> _loadCameraImages() async {
    try {
      final img1 = await widget.initialImages![0].readAsBytes();
      final img2 = await widget.initialImages![1].readAsBytes();
      final img3 = await widget.initialImages![2].readAsBytes();
      final img4 = await widget.initialImages![3].readAsBytes();

      setState(() {
        _imageBytesList[0] = img1;
        _imageBytesList[1] = img2;
        _imageBytesList[2] = img3;
        _imageBytesList[3] = img4;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: Colors.yellow[700],
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

  Future<void> _captureAndUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kamu belum login.")));
      return;
    }

    if (_imageBytesList.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi semua 4 foto dulu ya!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      RenderRepaintBoundary? boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) throw "Gagal render widget.";

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final fullImageBytes = byteData?.buffer.asUint8List();

      if (fullImageBytes == null) throw "Gambar kosong.";

      if (!kIsWeb) {
        try {
          await Gal.requestAccess();
          final tempDir = await getTemporaryDirectory();
          final file = await File(
            '${tempDir.path}/photostrip_${DateTime.now().millisecondsSinceEpoch}.png',
          ).create();
          await file.writeAsBytes(fullImageBytes);
          await Gal.putImage(file.path, album: 'Booth-Art');
        } catch (e) {
          debugPrint("Error: $e");
        }
      }

      final fileName = 'C4_strip_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = 'uploads/${user.uid}/$fileName';

      await SupabaseService.client.storage
          .from('photos')
          .uploadBinary(
            filePath,
            fullImageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil Disimpan!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = _frameColor.computeLuminance() < 0.5;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color borderColor = isDark ? Colors.white24 : Colors.grey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Classic 4",
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.yellow[700],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 240,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _frameColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...List.generate(4, (index) {
                            return GestureDetector(
                              onTap: () => _pickImage(index),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: _imageBytesList[index] == null
                                    ? Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey[400],
                                      )
                                    : Image.memory(
                                        _imageBytesList[index]!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "PHOTOBOOTH MOMENTS",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          ),
                          Text(
                            "2026",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Pilih Warna Frame:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                        onTap: () => setState(() => _frameColor = color),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: color.computeLuminance() > 0.5
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _captureAndUpload,
                  icon: const Icon(Icons.save_alt, color: Colors.white),
                  label: const Text(
                    "Simpan Photostrip",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
