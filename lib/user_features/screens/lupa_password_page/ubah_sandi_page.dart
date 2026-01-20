import 'package:flutter/material.dart';

// --- WARNA UTAMA (PINK) SESUAI TEMA ---
const Color mainPink = Color(0xFFD81B60);

class UbahSandiPage extends StatefulWidget {
  const UbahSandiPage({super.key});

  @override
  State<UbahSandiPage> createState() => _UbahSandiPageState();
}

class _UbahSandiPageState extends State<UbahSandiPage> {
  // Controller Text
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  // State untuk Mata (Show/Hide Password)
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Ubah Kata Sandi Baru",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink, // Pink
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // --- 1. ILUSTRASI ---
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.pink[50], // Background Pink Muda
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset, 
                size: 60,
                color: mainPink, // Icon Pink
              ),
            ),
            const SizedBox(height: 30),

            // --- 2. TEKS INSTRUKSI ---
            const Text(
              "Silahkan masukan password baru\nanda",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),

            // --- 3. INPUT PASSWORD BARU ---
            _buildPasswordField("Password", _passCtrl, _isObscure1, (val) {
              setState(() => _isObscure1 = val);
            }),
            const SizedBox(height: 20),

            // --- 4. INPUT KONFIRMASI PASSWORD ---
            _buildPasswordField(
              "Konfirmasi Password",
              _confirmPassCtrl,
              _isObscure2,
              (val) {
                setState(() => _isObscure2 = val);
              },
            ),
            const SizedBox(height: 40),

            // --- 5. TOMBOL SIMPAN ---
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
                  // Tampilkan Notifikasi Sukses
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green, // Snack bar ijo sukses
                      content: Text(
                        "Password berhasil diubah! Silahkan Login.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                  // Kembali ke halaman Login (Pop sampai awal)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper biar kodingan rapi (Input Password + Mata)
  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
    bool isObscure,
    Function(bool) onToggle,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: isObscure,
      cursorColor: mainPink,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: mainPink, width: 2), // Fokus Pink
        ),
        // Tombol Mata
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: mainPink, // Mata Pink
          ),
          onPressed: () => onToggle(!isObscure),
        ),
      ),
    );
  }
}