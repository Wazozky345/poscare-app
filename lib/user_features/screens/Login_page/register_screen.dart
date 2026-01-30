import 'package:flutter/material.dart';
// 1. IMPORT FIREBASE
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/colors.dart'; // Warna Pink kita

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller buat nangkep inputan text
  final TextEditingController _kkController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _nikAyahController = TextEditingController();
  final TextEditingController _namaAyahController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabel buat Dropdown & Password
  String? _selectedGolDarah;
  bool _isPasswordVisible = false;
  
  // Variabel Loading
  bool _isLoading = false;

  // List pilihan Golongan Darah
  final List<String> _golDarahOptions = ['A', 'B', 'AB', 'O','Belum Mengetahui'];

  // Fungsi buat munculin Kalender
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  // --- FUNGSI REGISTER FIREBASE ---
  void _handleRegister() async {
    // A. VALIDASI INPUT
    if (_kkController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _namaController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _teleponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi seluruh data wajib."), // Redaksi Formal
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // B. Mulai Loading
    setState(() => _isLoading = true);

    try {
      // C. BIKIN AKUN DI AUTH
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // D. SIMPAN DATA KE FIRESTORE
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'role': 'User', 
        'createdAt': DateTime.now().toIso8601String(),
        
        // Data Form
        'no_kk': _kkController.text.trim(),
        'email': _emailController.text.trim(),
        'nik': _nikController.text.trim(),
        'nama': _namaController.text.trim(),
        'tempat_lahir': _tempatLahirController.text.trim(),
        'tanggal_lahir': _tanggalLahirController.text.trim(),
        'gol_darah': _selectedGolDarah ?? "-",
        'nik_ayah': _nikAyahController.text.trim(),
        'nama_ayah': _namaAyahController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'noHp': _teleponController.text.trim(),
      });

      // E. SUKSES (Redaksi Formal)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi akun berhasil. Silakan login."), // <--- INI YG DIUBAH
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context); // Balik ke halaman Login
      }

    } on FirebaseAuthException catch (e) {
      // Handle Error (Redaksi Formal)
      String message = "Terjadi kesalahan pada sistem.";
      if (e.code == 'weak-password') {
        message = "Password terlalu lemah (minimal 6 karakter).";
      } else if (e.code == 'email-already-in-use') {
        message = "Email sudah terdaftar. Gunakan email lain.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memproses data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor), 
        title: const Text(
          "Registrasi",
          style: TextStyle(
            color: AppColors.primaryColor, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Nomor KK
            _buildLabel("Nomor Kartu Keluarga"),
            _buildTextField(
              controller: _kkController, 
              hint: "", 
              maxLength: 16,
              keyboardType: TextInputType.number
            ),

            // 2. Email
            _buildLabel("Email"),
            _buildTextField(controller: _emailController, hint: "", keyboardType: TextInputType.emailAddress),

            // 3. NIK
            _buildLabel("NIK"),
            _buildTextField(
              controller: _nikController, 
              hint: "", 
              maxLength: 16,
              keyboardType: TextInputType.number
            ),

            // 4. Nama
            _buildLabel("Nama"),
            _buildTextField(controller: _namaController, hint: ""),

            // 5. Tempat & Tanggal Lahir
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tempat Lahir"),
                      _buildTextField(controller: _tempatLahirController, hint: ""),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Tanggal Lahir"),
                      TextField(
                        controller: _tanggalLahirController,
                        readOnly: true, 
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          hintText: "YYYY-MM-DD",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),

            // 6. Golongan Darah
            _buildLabel("Golongan Darah"),
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGolDarah,
                  hint: const Text("Pilih Golongan Darah"),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                  items: _golDarahOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGolDarah = newValue;
                    });
                  },
                ),
              ),
            ),

            // 7. NIK Ayah
            _buildLabel("NIK Ayah"),
            _buildTextField(
              controller: _nikAyahController, 
              hint: "", 
              maxLength: 16,
              keyboardType: TextInputType.number
            ),

            // 8. Nama Ayah
            _buildLabel("Nama Ayah"),
            _buildTextField(controller: _namaAyahController, hint: ""),

            // 9. Alamat
            _buildLabel("Alamat"),
            _buildTextField(controller: _alamatController, hint: ""),

            // 10. Telepon
            _buildLabel("Telepon"),
            _buildTextField(controller: _teleponController, hint: "", keyboardType: TextInputType.phone),

            // 11. Password
            _buildLabel("Password"),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 12. Tombol REGISTER
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Widget Bantuan ---
  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryColor, 
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          counterText: maxLength != null ? null : "", 
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}