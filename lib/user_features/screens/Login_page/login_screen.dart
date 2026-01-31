import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/colors.dart';
import '../main_screen.dart';
import 'register_screen.dart';
import '../lupa_password_page/lupa_password_page.dart';
import 'package:poscare/admin_features/screens/Halaman_Login/admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIKA UPDATE TOKEN SAAT LOGIN ---
  Future<void> _updateFCMToken(String uid) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Memberikan timeout agar jika FCM gagal, login tetap bisa lanjut
      NotificationSettings settings = await messaging.requestPermission().timeout(const Duration(seconds: 5));
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        String? token = await messaging.getToken().timeout(const Duration(seconds: 5));

        if (token != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({
            'fcmToken': token,
            'lastLogin': FieldValue.serverTimestamp(),
          });
          debugPrint("FCM Token Updated: $token");
        }
      }
    } catch (e) {
      // Jika error pada notifikasi, kita hanya log saja agar login tidak stuck
      debugPrint("Warning: Gagal update FCM Token: $e");
    }
  }

  // --- LOGIKA LOGIN USER ---
  void _handleUserLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Harap isi Email dan Password.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Proses Autentikasi
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Cek apakah dokumen user ada di Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // 3. Update Token (dengan penanganan agar tidak membuat stuck)
        await _updateFCMToken(userCredential.user!.uid);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        // Jika akun ada di Auth tapi tidak ada di koleksi 'users'
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          _showSnackBar("Akun ini tidak terdaftar sebagai Pengguna.", Colors.orange);
        }
      }

    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan sistem.";
      
      // Perbaikan logika pesan error agar lebih akurat
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = "Email atau Password salah.";
      } else if (e.code == 'wrong-password') {
        message = "Kata sandi salah.";
      } else if (e.code == 'network-request-failed') {
        message = "Koneksi internet bermasalah.";
      }

      if (mounted) _showSnackBar(message, Colors.red);
      
    } catch (e) {
      if (mounted) _showSnackBar("Gagal masuk: ${e.toString()}", Colors.red);
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
        duration: const Duration(seconds: 3),
      ),
    );
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
              Image.asset('assets/images/logo_poscare.png', height: 100),
              const SizedBox(height: 30),
              const Text(
                'Login Pengguna',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Silahkan masuk untuk melanjutkan.', style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 30),

              const Text("Email", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan E-mail',
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
                  hintText: 'Masukkan Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LupaPasswordPage())),
                  child: const Text("Lupa Password?", style: TextStyle(color: AppColors.secondaryColor)),
                ),
              ),
              
              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUserLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

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

              Center(
                child: InkWell(
                  onTap: () {
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
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
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