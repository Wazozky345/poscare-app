import 'package:flutter/material.dart';
// 1. IMPORT FIREBASE AUTH
import 'package:firebase_auth/firebase_auth.dart';

// --- IMPORT WARNA & HALAMAN ---
import '../../core/colors.dart';
import '../main_screen.dart';
import 'register_screen.dart';
import '../lupa_password_page/lupa_password_page.dart';

// --- IMPORT JEMBATAN KE ADMIN ---
import 'package:poscare/admin_features/screens/Halaman_Login/admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  // Tambahan Loading State
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- FUNGSI LOGIN SAKTI (FIREBASE) ---
  void _handleUserLogin() async {
    // 1. Validasi Input Kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan Password wajib diisi."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Mulai Loading (Muter-muter)
    setState(() => _isLoading = true);

    try {
      // 3. CEK KE SERVER FIREBASE
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 4. KALAU SUKSES (Gak ada error)
      if (mounted) {
        // Navigasi ke Halaman Utama (MainScreen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }

    } on FirebaseAuthException catch (e) {
      // 5. KALAU GAGAL (Handle Error biar User Tau Salahnya Dimana)
      String message = "Login Gagal.";
      
      if (e.code == 'user-not-found') {
        message = "Email tidak terdaftar. Silakan registrasi dulu.";
      } else if (e.code == 'wrong-password') {
        message = "Password salah.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      } else if (e.code == 'invalid-credential') {
        // Firebase versi baru sering pake kode ini kalau salah pass/email
        message = "Email atau Password salah.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Error Lainnya
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 6. Stop Loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. LOGO
              Image.asset('assets/images/logo_poscare.jpeg', height: 100),
              const SizedBox(height: 30),

              // 2. JUDUL
              const Text(
                'Login Pengguna',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Silahkan masuk untuk melanjutkan.', style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              
              const SizedBox(height: 30),

              // 3. INPUT FORM (Email & Password)
              const Text("Email", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // Keyboard @
                decoration: InputDecoration(
                  hintText: 'user@gmail.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: '********',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),

              // 4. OPSI LAIN (Ingat Saya & Lupa Pass)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primaryColor,
                        onChanged: (value) => setState(() => _rememberMe = value!),
                      ),
                      const Text("Ingat Saya"),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LupaPasswordPage())),
                    child: const Text("Lupa Password?", style: TextStyle(color: AppColors.secondaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. TOMBOL LOGIN USER (DENGAN LOADING)
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  // Kalau loading, tombol mati
                  onPressed: _isLoading ? null : _handleUserLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) // Animasi Muter
                    : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // 6. LINK REGISTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum Punya akun? "),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: const Text("Registrasi", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const SizedBox(height: 50), 

              // ==========================================================
              // 🔥 TOMBOL ADMIN ESTETIK (DI BAWAH) 🔥
              // ==========================================================
              Center(
                child: InkWell(
                  onTap: () {
                    // Pindah ke Halaman Admin
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: const [
                        Icon(Icons.admin_panel_settings_outlined, color: Colors.grey, size: 24),
                        SizedBox(height: 4),
                        Text(
                          "Masuk sebagai Admin",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}