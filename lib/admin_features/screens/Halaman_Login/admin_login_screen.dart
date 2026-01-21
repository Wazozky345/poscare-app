import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. IMPORT FIREBASE AUTH

// --- IMPORT WARNA ADMIN ---
import 'package:poscare/admin_features/core/admin_colors.dart'; 

// --- IMPORT DASHBOARD ---
import 'package:poscare/admin_features/Dashboard/dashboard_page.dart'; 

// --- IMPORT REGISTRASI ---
import 'registration_page.dart'; 

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false; // 2. TAMBAHKAN STATE LOADING
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 3. FUNGSI HANDLE LOGIN DENGAN FIREBASE
  Future<void> _handleAdminLogin() async {
    // Validasi input kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password harus diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai loading

    try {
      // PROSES LOGIN KE FIREBASE
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // Jika berhasil, pindah ke Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardAdminPage(
              namaUser: userCredential.user?.email?.split('@')[0] ?? "Admin",
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // HANDLING ERROR SPESIFIK FIREBASE
      String message = "Terjadi kesalahan saat login";
      if (e.code == 'user-not-found') {
        message = "Email tidak terdaftar sebagai admin";
      } else if (e.code == 'wrong-password') {
        message = "Password yang Anda masukkan salah";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid";
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // Berhenti loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.white, 
      appBar: AppBar(
        backgroundColor: AdminColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100), 
            const Icon(Icons.admin_panel_settings, size: 80, color: AdminColors.primary),
            const SizedBox(height: 20),
            const Text(
              'LOGIN ADMIN',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AdminColors.primary,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk untuk mengelola sistem Poscare.',
              style: TextStyle(fontSize: 14, color: AdminColors.textGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // INPUT EMAIL
            const Text("Email Admin", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              cursorColor: AdminColors.primary,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Masukkan E-mail',
                prefixIcon: const Icon(Icons.email_outlined, color: AdminColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // INPUT PASSWORD
            const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              cursorColor: AdminColors.primary,
              decoration: InputDecoration(
                hintText: 'Password Anda',
                prefixIcon: const Icon(Icons.lock_outline, color: AdminColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.primary, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AdminColors.primary,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL LOGIN (DENGAN INDIKATOR LOADING)
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAdminLogin, // Nonaktifkan jika sedang loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      "MASUK",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminColors.white),
                    ),
              ),
            ),

            const SizedBox(height: 30),

            // LINK KE REGISTRASI
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Belum punya akun admin? ",
                  style: TextStyle(color: AdminColors.textGrey),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationPage()),
                    );
                  },
                  child: const Text(
                    "Registrasi",
                    style: TextStyle(
                      color: AdminColors.primary, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}