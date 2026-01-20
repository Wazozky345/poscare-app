import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN (BIAR SERAGAM) ---
import 'package:poscare/admin_features/core/admin_colors.dart';

// --- IMPORT CONFIG (BUAT DATA DUMMY) ---
// Pastikan path ini bener sesuai folder lu
import '../config.dart'; 

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _namaCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  String _jenisKelamin = 'Laki-laki';
  bool _isPasswordVisible = false; // Biar bisa liat password

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- APP BAR SIMPEL ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Tombol Back Navy
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
            // Header Kecil
            const Text(
              "Tambah Data Admin Baru",
              style: TextStyle(
                color: AdminColors.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            // --- INPUT NAMA ---
            _buildLabel("Nama Lengkap"),
            TextField(
              controller: _namaCtl,
              decoration: _inputDecoration(hint: "Masukkan nama lengkap"),
            ),
            const SizedBox(height: 20),

            // --- INPUT EMAIL ---
            _buildLabel("Email"),
            TextField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(hint: "admin@poscare.com"),
            ),
            const SizedBox(height: 20),

            // --- INPUT PASSWORD ---
            _buildLabel("Password"),
            TextField(
              controller: _passCtl,
              obscureText: !_isPasswordVisible,
              decoration: _inputDecoration(hint: "********").copyWith(
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

            // --- INPUT JENIS KELAMIN ---
            _buildLabel("Jenis Kelamin"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400), // Border abu biar gak kaku
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
                // TOMBOL SIMPAN (NAVY)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleSimpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary, // Warna Navy
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      child: const Text(
                        "SIMPAN",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // TOMBOL BATAL (ABU)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "BATAL",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
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

  // --- WIDGET HELPER (Biar Kodingan Bersih) ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text, 
        style: const TextStyle(
          color: AdminColors.primary, 
          fontWeight: FontWeight.bold, 
          fontSize: 14
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AdminColors.primary, width: 2), // Fokus jadi Navy
      ),
    );
  }

  void _handleSimpan() {
    if (_namaCtl.text.isEmpty || _emailCtl.text.isEmpty || _passCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data tidak boleh kosong"), backgroundColor: Colors.red),
      );
      return;
    }
    
    // --- LOGIKA SIMPAN DUMMY (SESUAI REQUEST) ---
    databaseUser.add({
      'username': _emailCtl.text,
      'password': _passCtl.text,
      'nama': _namaCtl.text,
      'role': 'Admin',
      'jk': _jenisKelamin,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data Admin Berhasil Ditambahkan!"),
        backgroundColor: AdminColors.menuOrtu, // Hijau
      ),
    );
    Navigator.pop(context);
  }
}