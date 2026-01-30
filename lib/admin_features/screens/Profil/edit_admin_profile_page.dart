// FILE: lib/admin_features/screens/Profil/edit_admin_profile_page.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';

class EditAdminProfilePage extends StatefulWidget {
  const EditAdminProfilePage({super.key});

  @override
  State<EditAdminProfilePage> createState() => _EditAdminProfilePageState();
}

class _EditAdminProfilePageState extends State<EditAdminProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  final _namaCtl = TextEditingController();
  final _hpCtl = TextEditingController();
  
  // Password Controllers
  final _oldPassCtl = TextEditingController();
  final _newPassCtl = TextEditingController();
  final _confirmPassCtl = TextEditingController();

  // Password Visibility State
  bool _isOldPassVisible = false;
  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;
  
  File? _imageFile;
  bool _isLoading = false;
  String? _currentPhotoBase64;

  // --- VARIABEL UNTUK CEK PERUBAHAN ---
  String _initialNama = "";
  String _initialHp = "";
  String? _initialPhotoBase64;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('admins').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          _namaCtl.text = doc['nama'] ?? '';
          _hpCtl.text = doc['noHp'] ?? '';
          _currentPhotoBase64 = doc['foto_profil']; 

          // Simpan data awal buat perbandingan
          _initialNama = doc['nama'] ?? '';
          _initialHp = doc['noHp'] ?? '';
          _initialPhotoBase64 = doc['foto_profil'];
        });
      }
    }
  }

  // --- AMBIL FOTO DARI GALERI ---
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 20); 
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // --- HAPUS FOTO ---
  void _deletePhoto() {
    setState(() {
      _imageFile = null;
      _currentPhotoBase64 = ''; 
    });
  }

  // --- SIMPAN PERUBAHAN ---
  Future<void> _saveChanges() async {
    // 1. CEK APAKAH ADA PERUBAHAN?
    bool isNameChanged = _namaCtl.text != _initialNama;
    bool isHpChanged = _hpCtl.text != _initialHp;
    bool isPhotoChanged = _imageFile != null; // Ada upload baru
    bool isPhotoDeleted = (_currentPhotoBase64 == '' && _initialPhotoBase64 != null && _initialPhotoBase64 != ''); // Foto dihapus
    bool isPasswordFilled = _oldPassCtl.text.isNotEmpty || _newPassCtl.text.isNotEmpty; // Ada niat ganti password

    // Kalau TIDAK ADA satupun yang berubah
    if (!isNameChanged && !isHpChanged && !isPhotoChanged && !isPhotoDeleted && !isPasswordFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak ada perubahan data yang perlu disimpan."),
          backgroundColor: Colors.orange, // Warna warning
          duration: Duration(seconds: 2),
        ),
      );
      return; // STOP DI SINI, JANGAN LANJUT KE FIREBASE
    }

    // --- KALAU ADA PERUBAHAN, LANJUT SIMPAN ---
    setState(() => _isLoading = true);
    try {
      // Logic Foto
      String? finalPhotoData = _currentPhotoBase64;
      
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        finalPhotoData = base64Encode(imageBytes); 
      }

      // Update Firestore
      await FirebaseFirestore.instance.collection('admins').doc(user!.uid).update({
        'nama': _namaCtl.text,
        'noHp': _hpCtl.text,
        'foto_profil': finalPhotoData, 
      });

      // Update Password
      if (_oldPassCtl.text.isNotEmpty && _newPassCtl.text.isNotEmpty) {
        if (_newPassCtl.text != _confirmPassCtl.text) {
          throw FirebaseAuthException(code: 'pass-mismatch', message: "Konfirmasi password baru tidak cocok.");
        }
        
        AuthCredential credential = EmailAuthProvider.credential(email: user!.email!, password: _oldPassCtl.text);
        await user!.reauthenticateWithCredential(credential);
        await user!.updatePassword(_newPassCtl.text);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil Berhasil Diperbarui!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      String msg = "Gagal: $e";
      if (e is FirebaseAuthException && e.code == 'wrong-password') {
        msg = "Password lama salah!";
      } else if (e is FirebaseAuthException && e.code == 'pass-mismatch') {
        msg = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ImageProvider? _getAvatarImage() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (_currentPhotoBase64 != null && _currentPhotoBase64!.isNotEmpty) {
      try { return MemoryImage(base64Decode(_currentPhotoBase64!)); } catch (e) { return null; }
    }
    return null; 
  }

  @override
  Widget build(BuildContext context) {
    bool hasPhoto = _getAvatarImage() != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- AREA FOTO PROFIL ---
            Center(
              child: SizedBox(
                width: 130, 
                height: 130,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _getAvatarImage(),
                          child: !hasPhoto
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),

                    if (hasPhoto)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          onTap: _deletePhoto,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.delete, color: Colors.white, size: 20),
                          ),
                        ),
                      ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE91E63), 
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            _buildInput("Nama Lengkap", _namaCtl, Icons.person_outline),
            const SizedBox(height: 15),
            _buildInput("No. Handphone", _hpCtl, Icons.phone_iphone, type: TextInputType.phone),
            
            const SizedBox(height: 30),
            const Divider(thickness: 1),
            const SizedBox(height: 15),
            
            const Align(alignment: Alignment.centerLeft, child: Text("Ubah Password (Opsional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.primary))),
            const SizedBox(height: 5),
            const Align(alignment: Alignment.centerLeft, child: Text("Isi hanya jika ingin mengganti password.", style: TextStyle(fontSize: 12, color: Colors.grey))),
            const SizedBox(height: 20),
            
            _buildPasswordInput("Password Lama", _oldPassCtl, _isOldPassVisible, () => setState(() => _isOldPassVisible = !_isOldPassVisible)),
            const SizedBox(height: 15),
            _buildPasswordInput("Password Baru", _newPassCtl, _isNewPassVisible, () => setState(() => _isNewPassVisible = !_isNewPassVisible)),
            const SizedBox(height: 15),
            _buildPasswordInput("Konfirmasi Password Baru", _confirmPassCtl, _isConfirmPassVisible, () => setState(() => _isConfirmPassVisible = !_isConfirmPassVisible)),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 3),
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctl, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      ),
    );
  }

  Widget _buildPasswordInput(String label, TextEditingController ctl, bool isVisible, VoidCallback onToggle) {
    return TextField(
      controller: ctl,
      obscureText: !isVisible, 
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      ),
    );
  }
}