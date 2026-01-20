import 'package:flutter/material.dart';
import 'ubah_sandi_page.dart'; // Pastikan nama file ini sesuai

// --- WARNA UTAMA (PINK) SESUAI TEMA ---
const Color mainPink = Color(0xFFD81B60); 

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lupa Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink, // Pink
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // --- 1. ILUSTRASI GAMBAR/ICON ---
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.pink[50], // Background Pink Muda
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 60,
                color: mainPink, // Icon Pink
              ),
            ),
            const SizedBox(height: 30),

            // --- 2. TEKS INSTRUKSI ---
            const Text(
              "Silahkan masukkan email Anda untuk\nmelakukan verifikasi",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87, // Hitam biar lebih kebaca
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),

            // --- 3. INPUT EMAIL ---
            TextField(
              controller: _emailCtrl,
              cursorColor: mainPink,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: Colors.grey),
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
                  borderSide: const BorderSide(color: mainPink, width: 2), // Fokus Pink
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- 4. TOMBOL VERIFIKASI ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainPink, // Tombol Pink
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Pindah ke Halaman Ubah Sandi
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const UbahSandiPage()),
                  );
                },
                child: const Text(
                  "Verifikasi",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- 5. TOMBOL CANCEL ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: mainPink), // Garis Pink
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: mainPink, fontSize: 16), // Teks Pink
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}