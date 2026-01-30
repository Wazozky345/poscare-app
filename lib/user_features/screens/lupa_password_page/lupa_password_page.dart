import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- WARNA UTAMA (PINK) SESUAI TEMA ---
const Color mainPink = Color(0xFFD81B60); 

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false; 

  // --- 1. LOGIKA FIREBASE (TIDAK DIUBAH) ---
  Future<void> _handleResetPassword() async {
    String email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan masukkan email Anda")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mengirim email reset password otomatis dari Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (mounted) {
        // Beri tahu user bahwa email sudah dikirim
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Email Terkirim"),
            content: Text("Link untuk mengatur ulang kata sandi telah dikirim ke $email. Silakan cek Inbox atau folder Spam Anda."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Tutup Dialog
                  Navigator.pop(context); // Kembali ke Login
                },
                child: const Text("Tutup", style: TextStyle(color: mainPink)),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";
      if (e.code == 'user-not-found') message = "Email tidak terdaftar!";
      if (e.code == 'invalid-email') message = "Format email salah!";
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. UI YANG SUDAH DIBAGUSIN ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lupa Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink, 
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // Icon Besar di Tengah
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.pink[50], 
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 60,
                color: mainPink, 
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Silahkan masukkan email Anda untuk\nmelakukan verifikasi",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54, 
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // INPUT FIELD (DIBAGUSIN + ADA ICON)
            TextField(
              controller: _emailCtrl,
              cursorColor: mainPink,
              keyboardType: TextInputType.emailAddress, 
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Masukkan Email Anda",
                labelStyle: const TextStyle(color: Colors.grey),
                // INI YANG DITAMBAHKAN (ICON DI DALAM KOLOM)
                prefixIcon: const Icon(Icons.email_outlined, color: mainPink),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: mainPink),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: mainPink, width: 2), 
                ),
              ),
            ),
            const SizedBox(height: 30),

            // TOMBOL VERIFIKASI
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainPink, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "Kirim Link Verifikasi",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
            const SizedBox(height: 15),

            // TOMBOL CANCEL
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: mainPink), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: mainPink, fontSize: 16, fontWeight: FontWeight.bold), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}