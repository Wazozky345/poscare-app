// FILE: lib/user_features/screens/Profil/profile_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/colors.dart';
import '../Login_page/login_screen.dart';
import 'edit_profile_screen.dart';
import 'detail_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controller buat input password saat hapus akun
  final TextEditingController _passwordConfirmController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  // ==========================================================
  // 1. LOGIKA LOGOUT (LANGSUNG TENDANG KE LOGIN SCREEN)
  // ==========================================================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Sudut Estetik
        title: Column(
          children: [
            // Icon Logout dengan Background Tipis
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1), // Warna tema transparan
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.primaryColor, size: 40),
            ),
            const SizedBox(height: 15),
            const Text(
              "Konfirmasi Keluar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari aplikasi?",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
        actions: [
          Row(
            children: [
              // TOMBOL BATAL (OUTLINE PINK)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primaryColor), // Border Pink
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Batal", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)), // Teks Pink
                ),
              ),
              const SizedBox(width: 15),
              
              // TOMBOL YA, KELUAR (FULL PINK)
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Tutup Dialog
                    
                    // Proses Logout
                    await FirebaseAuth.instance.signOut();

                    if (mounted) {
                      // Tendang ke Login Screen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor, // Warna Tema
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ==========================================================
  // 2. LOGIKA HAPUS AKUN (TAMPILAN JADI GUEST VIEW)
  // ==========================================================
  void _showDeleteAccountDialog() {
    _passwordConfirmController.clear();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Sudut tumpul estetik
              title: const Column(
                children: [
                   // Icon Sampah Besar biar jelas tapi estetik
                   Icon(Icons.warning_amber_rounded, color: AppColors.primaryColor, size: 50),
                   SizedBox(height: 10),
                   Text(
                    "Hapus Akun?", 
                    style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Semua data Anda akan hilang permanen. Masukan password untuk konfirmasi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordConfirmController,
                    obscureText: _isObscure,
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      labelText: "Password Saya",
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2), // Fokus Pink
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off, color: AppColors.primaryColor), // Mata Pink
                        onPressed: () {
                          setStateDialog(() => _isObscure = !_isObscure);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center, // Tombol di tengah
              actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              actions: [
                Row(
                  children: [
                    // TOMBOL BATAL (OUTLINE PINK - REVISI)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context), 
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.primaryColor), // Border Pink
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Batal", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)), // Teks Pink
                      ),
                    ),
                    const SizedBox(width: 10),
                    
                    // TOMBOL HAPUS (FULL PINK)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleDeleteAccount(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primaryColor, // <--- WARNA TEMA PINK
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteAccount(BuildContext dialogContext) async {
    if (_passwordConfirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi password!")));
      return;
    }

    setState(() => _isLoading = true); 
    
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        // 1. Re-Authentikasi
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, 
          password: _passwordConfirmController.text
        );
        await user.reauthenticateWithCredential(credential);

        // 2. Hapus Data Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // 3. Hapus Akun Auth
        await user.delete();

        if (mounted) {
          Navigator.pop(dialogContext); // Tutup Dialog
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Akun berhasil dihapus."), backgroundColor: Colors.red),
          );

          // 4. JANGAN PINDAH HALAMAN, CUKUP REFRESH (Sesuai Request)
          // Nanti di method build() dia bakal nampilin Guest View karena user == null
          setState(() {}); 
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(dialogContext);
      String msg = "Gagal menghapus akun.";
      if (e.code == 'wrong-password') msg = "Password salah!";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==========================================================
  // TAMPILAN GUEST (YANG MUNCUL HABIS HAPUS AKUN)
  // ==========================================================
  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_off_rounded, size: 80, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 20),
              const Text(
                "Akun Tidak Ditemukan",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
              ),
              const SizedBox(height: 10),
              const Text(
                "Akun Anda telah dihapus atau Anda belum login. Silakan login kembali.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Tombol ini baru ngarahin ke Login
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("LOGIN / REGISTRASI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MAIN BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Kalau user null (Hapus Akun / Belum Login), tampil Guest View
    if (user == null) {
      return _buildGuestView();
    }

    // Kalau user ada, tampil Profil Asli
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Kasus User Auth ada tapi Data DB ilang -> Tampil Guest View juga
            return _buildGuestView(); 
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String nama = data['nama'] ?? 'User';
          String email = data['email'] ?? '-';
          
          String? base64Foto = data['foto_base64']; 
          ImageProvider? photoProvider;

          if (base64Foto != null && base64Foto.isNotEmpty) {
            try {
              photoProvider = MemoryImage(base64Decode(base64Foto));
            } catch (e) {
              photoProvider = null;
            }
          }

          return Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const Text("Profil Saya", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: photoProvider,
                      child: photoProvider == null
                          ? const Icon(Icons.person, size: 60, color: AppColors.primaryColor)
                          : null,
                    ),

                    const SizedBox(height: 10),
                    Text(nama, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // MENU LIST
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildMenuButton(
                      icon: Icons.assignment_ind,
                      text: "Lihat Biodata Lengkap",
                      color: AppColors.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailProfileScreen(data: data)),
                        );
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildMenuButton(
                      icon: Icons.edit,
                      text: "Edit Profil",
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfileScreen(currentData: data)),
                        );
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildMenuButton(
                      icon: Icons.delete_forever,
                      text: "Hapus Akun",
                      color: Colors.red,
                      onTap: _showDeleteAccountDialog,
                    ),
                    const SizedBox(height: 15),

                    _buildMenuButton(
                      icon: Icons.logout,
                      text: "Keluar Aplikasi",
                      color: Colors.grey,
                      onTap: _showLogoutDialog,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon, required String text, required Color color, required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(text, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}