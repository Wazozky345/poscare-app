// FILE: lib/admin_features/screens/Profil/admin_profile_page.dart

import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'edit_admin_profile_page.dart';
import 'package:poscare/admin_features/screens/Halaman_Login/admin_login_screen.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  // --- HELPER FORMAT TANGGAL (Manual biar gak perlu package intl) ---
  String _formatJoinDate(DateTime? date) {
    if (date == null) return "-";
    const List<String> months = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", 
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    // Format: 29 Jan 2026
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  // --- LOGIC HAPUS AKUN ---
  Future<void> _deleteAccount() async {
    final passwordCtl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        bool isPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AdminColors.primary, size: 60),
                    const SizedBox(height: 15),
                    const Text(
                      "Hapus Akun?",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminColors.primary),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Semua data Anda akan hilang permanen. Masukkan password untuk konfirmasi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    
                    TextField(
                      controller: passwordCtl,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "Password Saya",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AdminColors.primary)),
                        suffixIcon: IconButton(
                          icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                          onPressed: () => setStateDialog(() => isPasswordVisible = !isPasswordVisible),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AdminColors.primary), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Batal", style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold)), 
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: isLoading ? null : () async {
                              setStateDialog(() => isLoading = true);
                              try {
                                AuthCredential credential = EmailAuthProvider.credential(
                                  email: user!.email!,
                                  password: passwordCtl.text,
                                );
                                await user!.reauthenticateWithCredential(credential);
                                await FirebaseFirestore.instance.collection('admins').doc(user!.uid).delete();
                                await user!.delete();

                                if (mounted) {
                                  Navigator.pop(ctx);
                                  Navigator.pushAndRemoveUntil(
                                    context, 
                                    MaterialPageRoute(builder: (context) => const AdminLoginScreen()), 
                                    (route) => false
                                  ); 
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Akun berhasil dihapus.")));
                                }
                              } on FirebaseAuthException catch (e) {
                                setStateDialog(() => isLoading = false);
                                String err = "Password salah!";
                                if (e.code != 'wrong-password') err = e.message ?? "Gagal hapus akun";
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                              }
                            },
                            child: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("Silakan Login")));

    // --- AMBIL TANGGAL GABUNG DARI METADATA ---
    String joinDate = _formatJoinDate(user!.metadata.creationTime);

    return Scaffold(
      backgroundColor: AdminColors.background, 
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('admins').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("Data tidak ditemukan"));

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String? base64Photo = data['foto_profil']; 
          String noHp = data['noHp'] ?? '-';
          String nama = data['nama'] ?? 'Admin';
          String email = data['email'] ?? '-';

          ImageProvider? avatarImage;
          if (base64Photo != null && base64Photo.isNotEmpty) {
            try {
              avatarImage = MemoryImage(base64Decode(base64Photo)); 
            } catch (e) {
              avatarImage = null;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER SECTION ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 30),
                  decoration: const BoxDecoration(
                    color: AdminColors.primary,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      // Foto Profil
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          backgroundImage: avatarImage, 
                          child: avatarImage == null
                              ? const Icon(Icons.person, size: 60, color: AdminColors.primary)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                      Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      
                      const SizedBox(height: 10),
                      // BADGE ADMINISTRATOR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30)
                        ),
                        child: const Text(
                          "Administrator",
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                
                // --- CONTENT SECTION ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 1. INFO CARD (DATA TAMBAHAN)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Informasi Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.primary)),
                            const SizedBox(height: 15),
                            _buildInfoRow(Icons.phone_iphone, "No. Handphone", noHp),
                            const Divider(height: 25, color: Colors.grey),
                            _buildInfoRow(Icons.verified_user_outlined, "Status Akun", "Aktif / Terverifikasi"),
                            const Divider(height: 25, color: Colors.grey),
                            
                            // DISINI YANG KITA UBAH JADI REALTIME DATE
                            _buildInfoRow(Icons.date_range, "Bergabung Sejak", joinDate), 
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2. MENU CARD
                      _buildMenuCard(
                        icon: Icons.edit_note_rounded,
                        title: "Edit Profil & Password",
                        subtitle: "Ubah nama, foto, dan kata sandi",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EditAdminProfilePage()));
                        },
                      ),
                      
                      const SizedBox(height: 15),

                      _buildMenuCard(
                        icon: Icons.delete_forever_rounded,
                        title: "Hapus Akun",
                        subtitle: "Hapus akun admin secara permanen",
                        isDanger: true,
                        onTap: _deleteAccount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({required IconData icon, required String title, String? subtitle, required VoidCallback onTap, bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xFFFFF0F0) : Colors.white, 
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDanger ? const Color(0xFFFFCDD2) : Colors.transparent),
          boxShadow: isDanger ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDanger ? Colors.red.withOpacity(0.1) : AdminColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDanger ? Colors.red : AdminColors.primary, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDanger ? Colors.red : Colors.black87)),
                  if (subtitle != null)
                    Text(subtitle, style: TextStyle(fontSize: 11, color: isDanger ? Colors.red.withOpacity(0.7) : Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDanger ? Colors.red.withOpacity(0.5) : Colors.grey),
          ],
        ),
      ),
    );
  }
}