import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:poscare/admin_features/Dashboard/dashboard_page.dart';
import 'registration_page.dart';
// PENTING: Import file halaman lupa password yang baru dibuat di atas
// Sesuaikan path-nya dengan struktur folder abang
import 'package:poscare/admin_features/screens/lupa_password_page/admin_lupa_password_page.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIKA LOGIN ADMIN ---
  Future<void> _handleAdminLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      _showSnackBar("Harap lengkapi Email dan Password.", Colors.red);
      return;
    } else if (email.isEmpty) {
      _showSnackBar("Mohon isi Email Admin.", Colors.red);
      return;
    } else if (password.isEmpty) {
      _showSnackBar("Mohon isi Password.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. LOGIN FIREBASE
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. CEK DATABASE ADMIN
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();

      if (adminDoc.exists) {
        Map<String, dynamic>? data = adminDoc.data() as Map<String, dynamic>?;
        String realName = data?['nama'] ?? data?['name'] ?? userCredential.user?.email?.split('@')[0] ?? "Admin";

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardAdminPage(
                namaUser: realName,
              ),
            ),
          );
        }
      } else {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          _showSnackBar("Akses ditolak. Akun ini bukan Admin.", Colors.red);
        }
      }

    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan sistem.";
      
      if (e.code == 'user-not-found') {
        message = "Email Admin belum terdaftar.";
      } else if (e.code == 'wrong-password') {
        message = "Kata sandi yang Anda masukkan salah.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      } else if (e.code == 'too-many-requests') {
        message = "Terlalu banyak percobaan. Silakan tunggu sesaat.";
      } else if (e.code == 'invalid-credential') {
        message = "Kata sandi salah atau Email belum terdaftar.";
      }

      if (mounted) _showSnackBar(message, Colors.red);
      
    } catch (e) {
      if (mounted) _showSnackBar("Error: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
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
            const SizedBox(height: 50),
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

            // --- TAMBAHAN: TOMBOL LUPA PASSWORD ADMIN DI KANAN ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLupaPasswordPage()),
                  );
                },
                child: const Text("Lupa Password?", style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
            // -----------------------------------------------------

            const SizedBox(height: 20), // Jarak diubah sedikit biar pas

            // TOMBOL LOGIN
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAdminLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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