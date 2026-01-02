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
import 'package:project_kelompok/screen/home_page.dart'; // Pastikan import ini sesuai
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_kelompok/services/supabase_service.dart'; // Pastikan import ini sesuai

class TemplateVintage extends StatefulWidget {
  final List<File>? initialImages;

  const TemplateVintage({super.key, this.initialImages});

  @override
  State<TemplateVintage> createState() => _TemplateVintageState();
}

class _TemplateVintageState extends State<TemplateVintage> {
  Color _frameColor = const Color(0xFFFDF5E6);

  final List<Color> _colorOptions = [
    const Color(0xFFFDF5E6), // Old Lace (Krem)
    const Color(0xFF2C2C2C), // Charcoal (Hitam Pudar)
    const Color(0xFF8D6E63), // Antique Bronze
    const Color(0xFF556B2F), // Dark Olive
    const Color(0xFF8FBC8F), // Dark Sea Green
    const Color(0xFFD2B48C), // Tan
    const Color(0xFFBC8F8F), // Rosy Brown
    const Color(0xFFA9A9A9), // Dark Gray
  ];

  final List<Uint8List?> _imageBytesList = List.filled(2, null);
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isLoading = false;

  static const List<double> _sepiaMatrix = [
    0.393,
    0.769,
    0.189,
    0,
    0,
    0.349,
    0.686,
    0.168,
    0,
    0,
    0.272,
    0.534,
    0.131,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null && widget.initialImages!.length == 2) {
      _loadCameraImages();
    }
  }

  Future<void> _loadCameraImages() async {
    try {
      final img1 = await widget.initialImages![0].readAsBytes();
      final img2 = await widget.initialImages![1].readAsBytes();

      setState(() {
        _imageBytesList[0] = img1;
        _imageBytesList[1] = img2;
      });
    } catch (e) {
      debugPrint("Gagal memuat foto: $e");
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
            toolbarTitle: 'Potong Foto Vintage',
            toolbarColor: const Color(0xFF5D4037), // Coklat Tua
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFFD7CCC8),
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Potong Foto Vintage'),
        ],
      );

      if (croppedFile != null) {
        final bytes = await croppedFile.readAsBytes();
        setState(() {
          _imageBytesList[index] = bytes;
        });
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Isi semua foto dulu ya!")));
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
            '${tempDir.path}/vintage_strip_${DateTime.now().millisecondsSinceEpoch}.png',
          ).create();
          await file.writeAsBytes(fullImageBytes);
          await Gal.putImage(file.path, album: 'VintageBooth');
        } catch (e) {
          debugPrint("Skip galeri: $e");
        }
      }

      final fileName =
          'vintage_strip_${DateTime.now().millisecondsSinceEpoch}.png';
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
            content: Text("Tersimpan dalam kenangan!"),
            backgroundColor: Color(0xFF5D4037),
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
    Color textColor = isDark
        ? const Color(0xFFFDF5E6)
        : const Color(0xFF2C2C2C);
    Color borderColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: const Color(0xFFEEE0C9),
      appBar: AppBar(
        title: const Text(
          "VINTAGE BOOTH",
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5D4037),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Center(
              child: RepaintBoundary(
                key: _boundaryKey,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 260,
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
                  decoration: BoxDecoration(
                    color: _frameColor,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                    ],

                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...List.generate(2, (index) {
                        return GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7CCC8),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: _imageBytesList[index] == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[600],
                                        size: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "TAP TO ADD",
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  )
                                // Terapkan Filter Sepia pada Gambar
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(
                                      _sepiaMatrix,
                                    ),
                                    child: Image.memory(
                                      _imageBytesList[index]!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Text(
                              "MEMORIES",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace', // Font mesin tik
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5,
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              // Menampilkan tanggal hari ini
                              "${DateTime.now().day} . ${DateTime.now().month} . ${DateTime.now().year}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                letterSpacing: 2,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
