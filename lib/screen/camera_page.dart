import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:project_kelompok/template/photoboothpage.dart';
import 'package:project_kelompok/template/photoboothpage2.dart';
import 'package:project_kelompok/template/template_vintage.dart';

class CameraPage extends StatefulWidget {
  final int photoCount;
  final String templateType;

  const CameraPage({
    super.key,
    required this.photoCount,
    required this.templateType,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<File?> _capturedPhotos;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _capturedPhotos = List<File?>.filled(widget.photoCount, null);
  }

  void _takeNextPhoto() {
    final nextIndex = _capturedPhotos.indexWhere((photo) => photo == null);
    if (nextIndex != -1) {
      _showImageOptions(nextIndex);
    }
  }

  Future<void> _takePhoto(int index) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      preferredCameraDevice: CameraDevice.front,
    );

    if (photo != null) {
      _processImage(File(photo.path), index);
    }
  }

  Future<void> _pickFromGallery(int index) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);

    if (photo != null) {
      _processImage(File(photo.path), index);
    }
  }

  Future<void> _processImage(File originalFile, int index) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: originalFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Atur Foto',
          toolbarColor: Colors.yellow[700],
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Atur Foto'),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _capturedPhotos[index] = File(croppedFile.path);
      });
    }
  }

  void _resetPhotos() {
    setState(() {
      _capturedPhotos = List<File?>.filled(widget.photoCount, null);
    });
  }

  void _goToEditingPage() {
    List<File> finalImages = _capturedPhotos.whereType<File>().toList();

    if (widget.templateType == 'vintage') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage3(initialImages: finalImages),
        ),
      );
    } else if (widget.photoCount == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage2(initialImages: finalImages),
        ),
      );
    } else if (widget.photoCount == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoBoothPage(initialImages: finalImages),
        ),
      );
    }
  }

  void _showImageOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto Baru (Kamera)'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = !_capturedPhotos.contains(null);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Kelola Foto"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _resetPhotos, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.photoCount == 2 ? 1 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: widget.photoCount,
                itemBuilder: (context, index) {
                  final photo = _capturedPhotos[index];
                  return GestureDetector(
                    onTap: () => _showImageOptions(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        border: Border.all(
                          color: photo != null
                              ? Colors.yellow[700]!
                              : Colors.grey,
                          width: photo != null ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: photo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(photo, fit: BoxFit.cover),
                                  Container(
                                    color: Colors.black26,
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white54,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Isi Foto ${index + 1}",
                                  style: const TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isComplete)
                  ElevatedButton.icon(
                    onPressed: _takeNextPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text("Ambil Foto"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _goToEditingPage,
                    icon: const Icon(Icons.edit),
                    label: const Text("Lanjut Edit Frame"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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
