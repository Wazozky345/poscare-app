import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poscare/admin_features/core/admin_colors.dart'; 

class AdminLupaPasswordPage extends StatefulWidget {
  const AdminLupaPasswordPage({super.key});

  @override
  State<AdminLupaPasswordPage> createState() => _AdminLupaPasswordPageState();
}

class _AdminLupaPasswordPageState extends State<AdminLupaPasswordPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false;

  // --- LOGIKA KIRIM EMAIL RESET ---
  Future<void> _handleResetPassword() async {
    String email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan masukkan email Admin Anda"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kirim link reset password
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Email Terkirim"),
            content: Text("Link reset password telah dikirim ke $email.\nSilakan cek Inbox atau Spam, lalu klik link tersebut untuk membuat password baru."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Tutup Dialog
                  Navigator.pop(context); // Kembali ke Login Screen
                },
                child: const Text("OK, Mengerti"),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Gagal mengirim email.";
      if (e.code == 'user-not-found') message = "Email Admin ini tidak terdaftar.";
      if (e.code == 'invalid-email') message = "Format email salah.";
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.white,
      appBar: AppBar(
        title: const Text(
          "Lupa Password Admin",
          style: TextStyle(color: AdminColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: AdminColors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50], // Nuansa Admin
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 60,
                color: AdminColors.primary,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Masukkan email Admin yang terdaftar.\nKami akan mengirimkan link untuk mengatur ulang kata sandi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AdminColors.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _emailCtrl,
              cursorColor: AdminColors.primary,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email Admin",
                prefixIcon: const Icon(Icons.email_outlined, color: AdminColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // TOMBOL KIRIM LINK
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Kirim Link Verifikasi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 15),

            // --- TOMBOL BATAL (BARU) ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AdminColors.primary), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: AdminColors.primary, fontSize: 16, fontWeight: FontWeight.bold), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}