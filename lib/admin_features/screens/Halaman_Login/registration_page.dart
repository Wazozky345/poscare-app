// FILE: lib/admin_features/screens/Halaman_Login/registration_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _namaCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _hpCtl = TextEditingController(); // Controller No HP
  String _jenisKelamin = 'Laki-laki';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Registrasi Admin",
          style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Buat akun baru untuk Administrator Posyandu.",
              style: TextStyle(color: AdminColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            _buildLabel("Nama Lengkap"),
            TextField(
              controller: _namaCtl,
              decoration: _inputDecoration(hint: "Masukkan nama lengkap"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Email"),
            TextField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(hint: "Masukkan E-mail"),
            ),
            const SizedBox(height: 20),

            // --- INPUT NO HP ---
            _buildLabel("No. Handphone"),
            TextField(
              controller: _hpCtl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(hint: "Contoh: 08123456789"),
            ),
            const SizedBox(height: 20),
            // -------------------

            _buildLabel("Password"),
            TextField(
              controller: _passCtl,
              obscureText: !_isPasswordVisible,
              decoration: _inputDecoration(hint: "Password Anda").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AdminColors.textGrey,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("Jenis Kelamin"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _jenisKelamin,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AdminColors.primary),
                  items: ['Laki-laki', 'Perempuan'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: AdminColors.textDark)),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _jenisKelamin = newValue!),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- TOMBOL AKSI ---
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSimpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            "DAFTAR",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("BATAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
    );
  }

  // --- LOGIKA SIMPAN KE FIREBASE ---
  Future<void> _handleSimpan() async {
    // Validasi Form
    if (_namaCtl.text.isEmpty || _emailCtl.text.isEmpty || _passCtl.text.isEmpty || _hpCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. BUAT AKUN DI FIREBASE AUTH
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtl.text.trim(),
        password: _passCtl.text.trim(),
      );

      // 2. SIMPAN DETAIL ADMIN KE FIRESTORE (Collection 'admins')
      await FirebaseFirestore.instance.collection('admins').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nama': _namaCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'noHp': _hpCtl.text.trim(), // Simpan No HP
        'role': 'Admin', 
        'jk': _jenisKelamin,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi Admin Berhasil!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Kembali ke Login Page
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Gagal registrasi";
      if (e.code == 'email-already-in-use') msg = "Email sudah digunakan!";
      if (e.code == 'weak-password') msg = "Password terlalu lemah (min. 6 karakter)!";
      if (e.code == 'invalid-email') msg = "Format email salah!";
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}