// FILE: lib/user_features/screens/Profil/edit_profile_screen.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/colors.dart'; // Pastikan path ini benar

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({super.key, required this.currentData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController namaController;
  late TextEditingController hpController;
  late TextEditingController alamatController;

  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  File? _pickedImage; 
  bool _isDeletePhoto = false; 

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // --- VARIABEL UNTUK CEK PERUBAHAN ---
  late String _initialNama;
  late String _initialHp;
  late String _initialAlamat;
  String? _initialPhotoBase64;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Data Awal
    _initialNama = widget.currentData['nama'] ?? '';
    _initialHp = widget.currentData['noHp'] ?? '';
    _initialAlamat = widget.currentData['alamat'] ?? '';
    _initialPhotoBase64 = widget.currentData['foto_base64'];

    // Pasang ke Controller
    namaController = TextEditingController(text: _initialNama);
    hpController = TextEditingController(text: _initialHp);
    alamatController = TextEditingController(text: _initialAlamat);
  }

  // --- AMBIL FOTO ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 20); 

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _isDeletePhoto = false;
      });
    }
  }

  // --- HAPUS FOTO ---
  void _deletePhoto() {
    setState(() {
      _pickedImage = null;
      _isDeletePhoto = true; 
    });
  }

  // --- FUNGSI SIMPAN PROFIL ---
  void _saveProfile() async {
    // 1. CEK PERUBAHAN
    bool isNameChanged = namaController.text.trim() != _initialNama;
    bool isHpChanged = hpController.text.trim() != _initialHp;
    bool isAlamatChanged = alamatController.text.trim() != _initialAlamat;
    bool isPhotoChanged = _pickedImage != null; // Ada upload baru
    bool isPhotoDeleted = (_isDeletePhoto && _initialPhotoBase64 != null); // Foto lama dihapus

    // Kalau TIDAK ADA satupun yang berubah
    if (!isNameChanged && !isHpChanged && !isAlamatChanged && !isPhotoChanged && !isPhotoDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak ada perubahan data yang perlu disimpan."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return; // STOP PROSES
    }

    // --- LANJUT SIMPAN ---
    setState(() => _isLoading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      Map<String, dynamic> dataToUpdate = {
        'nama': namaController.text.trim(),
        'noHp': hpController.text.trim(),
        'alamat': alamatController.text.trim(),
      };

      // Logic Foto Base64
      if (_pickedImage != null) {
        List<int> imageBytes = await _pickedImage!.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        dataToUpdate['foto_base64'] = base64Image;
      } 
      else if (_isDeletePhoto) {
        dataToUpdate['foto_base64'] = FieldValue.delete();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update(dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI GANTI PASSWORD ---
  void _changePassword() async {
    if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi Password Lama dan Baru!"), backgroundColor: Colors.red));
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konfirmasi Password tidak cocok!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      User user = FirebaseAuth.instance.currentUser!;
      String email = user.email!;
      
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: _oldPassController.text);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPassController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Berhasil Diubah!"), backgroundColor: Colors.green));
        _oldPassController.clear(); 
        _newPassController.clear(); 
        _confirmPassController.clear();
      }
    } on FirebaseAuthException catch (e) {
        String msg = "Gagal Mengubah Password";
        if (e.code == 'wrong-password') msg = "Password lama salah!";
        if (e.code == 'weak-password') msg = "Password baru terlalu lemah!";
        
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    
    // LOGIKA TAMPILAN FOTO
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } 
    else if (!_isDeletePhoto && widget.currentData['foto_base64'] != null) {
      try {
        imageProvider = MemoryImage(base64Decode(widget.currentData['foto_base64']));
      } catch (e) {
        imageProvider = null;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: AppColors.primaryColor, 
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryColor, width: 2)),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageProvider,
                      child: imageProvider == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0, 
                    child: InkWell(
                      onTap: _pickImage, 
                      child: Container(
                        padding: const EdgeInsets.all(8), 
                        decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle), 
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20)
                      )
                    )
                  ),
                  if (imageProvider != null) 
                    Positioned(
                      bottom: 0, left: 0, 
                      child: InkWell(
                        onTap: _deletePhoto, 
                        child: Container(
                          padding: const EdgeInsets.all(8), 
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), 
                          child: const Icon(Icons.delete, color: Colors.white, size: 20)
                        )
                      )
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            _buildInput("Nama Lengkap", namaController, Icons.person),
            const SizedBox(height: 15),
            _buildInput("Nomor HP", hpController, Icons.phone),
            const SizedBox(height: 15),
            _buildInput("Alamat Domisili", alamatController, Icons.home),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity, 
              height: 50, 
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile, 
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SIMPAN PERUBAHAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              )
            ),
            
            const SizedBox(height: 40),
            const Divider(),
            
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent), 
              child: ExpansionTile(
                title: const Text("Ubah Password", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)), 
                leading: const Icon(Icons.lock_reset, color: AppColors.primaryColor), 
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10), 
                    child: Column(
                      children: [
                        _buildPasswordInput("Password Lama", _oldPassController), 
                        const SizedBox(height: 10), 
                        _buildPasswordInput("Password Baru", _newPassController), 
                        const SizedBox(height: 10), 
                        _buildPasswordInput("Konfirmasi Password Baru", _confirmPassController), 
                        const SizedBox(height: 20), 
                        SizedBox(
                          width: double.infinity, 
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _changePassword, 
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
                            child: const Text("GANTI PASSWORD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon) => TextField(
    controller: controller, 
    decoration: InputDecoration(
      labelText: label, 
      prefixIcon: Icon(icon, color: AppColors.primaryColor), 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
    )
  );
  
  Widget _buildPasswordInput(String label, TextEditingController controller) => TextField(
    controller: controller, 
    obscureText: !_isPasswordVisible, 
    decoration: InputDecoration(
      labelText: label, 
      prefixIcon: const Icon(Icons.lock, color: Colors.grey), 
      suffixIcon: IconButton(
        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey), 
        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)
      ), 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
    )
  );
}