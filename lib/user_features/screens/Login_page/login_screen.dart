import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- WAJIB: Buat SystemNavigator.pop()
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
  
  // --- VARIABEL BUAT DOUBLE BACK EXIT ---
  DateTime? currentBackPressTime; 

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIKA UPDATE TOKEN SAAT LOGIN ---
  Future<void> _updateFCMToken(String uid) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      NotificationSettings settings = await messaging.requestPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw 'Request Permission Timeout',
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized || 
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        String? token = await messaging.getToken().timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw 'Get Token Timeout',
        );

        if (token != null) {
          debugPrint("======================================================");
          debugPrint("FCM TOKEN: $token");
          debugPrint("======================================================");

          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({
            'fcmToken': token,
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint("Warning: Gagal memproses FCM Token: $e");
    }
  }

  // --- LOGIKA LOGIN USER (VALIDASI SUDAH DIPERBAIKI SESUAI REQUEST) ---
  void _handleUserLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // 1. VALIDASI INPUT KOSONG (LEBIH SPESIFIK)
    if (email.isEmpty && password.isEmpty) {
      _showSnackBar("Harap lengkapi Email dan Password.", Colors.red);
      return;
    } else if (email.isEmpty) {
      _showSnackBar("Mohon isi Email.", Colors.red);
      return;
    } else if (password.isEmpty) {
      _showSnackBar("Mohon isi Password.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. PROSES LOGIN KE FIREBASE
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. CEK DATA DI FIRESTORE (COLLECTION USERS)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        // Update Token FCM
        await _updateFCMToken(userCredential.user!.uid);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        // Kalo login berhasil tapi gak ada datanya di collection 'users'
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          _showSnackBar("Akun ini tidak terdaftar di database pengguna.", Colors.orange);
        }
      }

    } on FirebaseAuthException catch (e) {
      String message = "Gagal masuk. Periksa kembali koneksi Anda.";
      
      // 4. VALIDASI ERROR FIREBASE (LEBIH SPESIFIK)
      if (e.code == 'user-not-found') {
        message = "Email belum terdaftar.";
      } else if (e.code == 'wrong-password') {
        message = "Password salah.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      } else if (e.code == 'invalid-credential') {
        // Beberapa versi firebase menggabungkan error, tapi kita coba tangkap user-not-found di atas
        message = "Email atau Password salah.";
      } else if (e.code == 'network-request-failed') {
        message = "Koneksi internet tidak stabil.";
      } else if (e.code == 'too-many-requests') {
        message = "Terlalu banyak percobaan login. Tunggu sebentar.";
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- BUNGKUS DENGAN POPSCOPE (FITUR DOUBLE BACK) ---
    return PopScope(
      canPop: false, // Tahan tombol back bawaan
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        DateTime now = DateTime.now();

        // Cek selisih waktu (apakah kurang dari 2 detik?)
        if (currentBackPressTime == null || 
            now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
          
          // Update waktu pencet terakhir
          currentBackPressTime = now;
          
          // TAMPILKAN PESAN KEREN (SNACKBAR HITAM)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text("Tekan sekali lagi untuk keluar"),
                ],
              ),
              backgroundColor: Colors.black87, // Hitam elegan
              behavior: SnackBarBehavior.floating, // Melayang
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.all(20), // Jarak aman
              duration: const Duration(seconds: 2), // Muncul 2 detik
            ),
          );
          return;
        }

        // KALO PENCET 2X CEPAT -> KELUAR DARI APLIKASI
        SystemNavigator.pop();
      },
      child: Scaffold(
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
      ),
    );
  }
}