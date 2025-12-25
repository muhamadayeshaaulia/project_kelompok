import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_kelompok/services/supabase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhotoBoothPage extends StatefulWidget {
  const PhotoBoothPage({super.key});

  @override
  State<PhotoBoothPage> createState() => _PhotoBoothPageState();
}

class _PhotoBoothPageState extends State<PhotoBoothPage> {
  final List<File?> _imageFiles = List.filled(4, null);
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFiles[index] = File(pickedFile.path));
    }
  }

  Future<void> _saveBooth() async {
    if (_imageFiles.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi semua foto dulu ya!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      for (int i = 0; i < _imageFiles.length; i++) {
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        await SupabaseService.client.storage
            .from('photos')
            .upload('uploads/$userId/$fileName', _imageFiles[i]!);
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Photostrip")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: Container(
              width: 200,
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (index) => GestureDetector(
                  onTap: () => _pickImage(index),
                  child: Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.grey[300],
                    child: _imageFiles[index] == null 
                        ? const Icon(Icons.add_a_photo) 
                        : Image.file(_imageFiles[index]!, fit: BoxFit.cover),
                  ),
                )),
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveBooth,
        child: const Icon(Icons.check),
      ),
    );
  }
}