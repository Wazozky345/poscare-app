import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. IMPORT FIREBASE

// --- WARNA UTAMA (PINK) SESUAI TEMA ---
const Color mainPink = Color(0xFFD81B60);

class UbahSandiPage extends StatefulWidget {
  const UbahSandiPage({super.key});

  @override
  State<UbahSandiPage> createState() => _UbahSandiPageState();
}

class _UbahSandiPageState extends State<UbahSandiPage> {
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _isObscure1 = true;
  bool _isObscure2 = true;
  bool _isLoading = false; // 2. LOADING STATE

  // 3. FUNGSI UPDATE PASSWORD KE FIREBASE
  Future<void> _handleUpdatePassword() async {
    String pass = _passCtrl.text.trim();
    String confirm = _confirmPassCtrl.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      _showSnackBar("Password tidak boleh kosong", Colors.red);
      return;
    }

    if (pass != confirm) {
      _showSnackBar("Konfirmasi password tidak cocok", Colors.red);
      return;
    }

    if (pass.length < 6) {
      _showSnackBar("Password minimal 6 karakter", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mengubah password user yang sedang login
      await FirebaseAuth.instance.currentUser?.updatePassword(pass);

      if (mounted) {
        _showSnackBar("Password berhasil diubah! Silahkan Login kembali.", Colors.green);
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Gagal mengubah password";
      if (e.code == 'requires-recent-login') {
        msg = "Sesi habis. Silahkan logout dan login kembali untuk ubah sandi.";
      }
      _showSnackBar(msg, Colors.red);
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Ubah Kata Sandi Baru",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.pink[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset, size: 60, color: mainPink),
            ),
            const SizedBox(height: 30),
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
            _buildPasswordField("Password Baru", _passCtrl, _isObscure1, (val) {
              setState(() => _isObscure1 = val);
            }),
            const SizedBox(height: 20),
            _buildPasswordField(
              "Konfirmasi Password",
              _confirmPassCtrl,
              _isObscure2,
              (val) {
                setState(() => _isObscure2 = val);
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _handleUpdatePassword, // 4. HUBUNGKAN KE FUNGSI
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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
          borderSide: const BorderSide(color: mainPink, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: mainPink,
          ),
          onPressed: () => onToggle(!isObscure),
        ),
      ),
    );
  }
}