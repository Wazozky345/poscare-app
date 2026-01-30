import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

// --- IMPORT WARNA ---
import 'package:poscare/admin_features/core/admin_colors.dart';

// --- IMPORT FILE LAIN (Pastikan path ini benar di project kamu) ---
import 'package:poscare/admin_features/screens/Jadwal_Posyandu/jadwal_posyandu_page.dart';
import 'package:poscare/admin_features/screens/Data_Anak/data_anak_page.dart';
import 'package:poscare/admin_features/screens/Data_Orangtua/data_orangtua_page.dart';
import 'package:poscare/admin_features/screens/Data_Imunisasi/data_imunisasi_page.dart';
import 'package:poscare/admin_features/screens/Edukasi/edukasi_page.dart';
import 'package:poscare/admin_features/screens/Data_Posyandu/data_posyandu_page.dart';
import 'package:poscare/admin_features/screens/Cetak_Laporan/cetak_laporan_page.dart';
import 'package:poscare/admin_features/screens/Pengaturan_akun/pengaturan_akun_page.dart'; 
import 'package:poscare/admin_features/screens/Data_Ibu_Hamil/data_ibu_hamil_page.dart'; 
import 'package:poscare/user_features/screens/Login_page/login_screen.dart';
import 'package:poscare/admin_features/screens/Profil/admin_profile_page.dart';

class DashboardAdminPage extends StatefulWidget {
  final String namaUser;
  const DashboardAdminPage({super.key, required this.namaUser});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withOpacity(0.1), 
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AdminColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              const Text("Konfirmasi Keluar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Apakah Anda yakin ingin keluar?", textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (c) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
                      child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.primary,
        elevation: 0,
        title: const Text("Poscare Admin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        automaticallyImplyLeading: false, 
        actions: [
          _buildProfileIcon(),
        ],
      ),
      // MENGGUNAKAN NESTED STREAM UNTUK MENGHITUNG DATA DARI 3 KOLEKSI BERBEDA
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('data_anak').snapshots(),
        builder: (context, snapshotAnak) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('ibu_hamil').snapshots(),
            builder: (context, snapshotHamil) {
              return StreamBuilder<QuerySnapshot>(
                // Mengambil data orang tua dari koleksi users dengan role User
                stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'User').snapshots(),
                builder: (context, snapshotOrtu) {
                  
                  // Hitung jumlah dokumen secara real-time
                  int totalAnak = snapshotAnak.hasData ? snapshotAnak.data!.docs.length : 0;
                  int totalIbuHamil = snapshotHamil.hasData ? snapshotHamil.data!.docs.length : 0;
                  int totalOrangTua = snapshotOrtu.hasData ? snapshotOrtu.data!.docs.length : 0;
                  int totalSemuaWarga = totalAnak + totalOrangTua + totalIbuHamil;

                  // Hitung proporsi untuk diagram (0.0 sampai 1.0)
                  double pAnak = totalSemuaWarga == 0 ? 0 : totalAnak / totalSemuaWarga;
                  double pOrtu = totalSemuaWarga == 0 ? 0 : totalOrangTua / totalSemuaWarga;
                  double pHamil = totalSemuaWarga == 0 ? 0 : totalIbuHamil / totalSemuaWarga;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Ringkasan Data Warga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              
                              // Kotak Diagram
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _chartSection("Proporsi Data", pAnak, pOrtu, pHamil),
                                    _buildLegendSection(totalAnak, totalOrangTua, totalIbuHamil),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),
                              _buildGridStats(totalAnak, totalOrangTua, totalIbuHamil),
                              
                              const SizedBox(height: 25),
                              const Text("Menu Pintasan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 15),
                              _buildGridMenu(context), 
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGET PROFIL ---
  Widget _buildProfileIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProfilePage())),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('admins').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
          builder: (context, snapshot) {
            ImageProvider? avatarImage;
            if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              String? base64Photo = data['foto_profil']; 
              if (base64Photo != null && base64Photo.isNotEmpty) {
                avatarImage = MemoryImage(base64Decode(base64Photo));
              }
            }
            return CircleAvatar(
              radius: 18, backgroundColor: Colors.white,
              backgroundImage: avatarImage,
              child: avatarImage == null ? const Icon(Icons.person, color: AdminColors.primary, size: 20) : null,
            );
          },
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: AdminColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.admin_panel_settings, color: Colors.white)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(widget.namaUser, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // --- STATS GRID ---
  Widget _buildGridStats(int anak, int ortu, int hamil) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard("Total Anak", anak.toString(), Icons.child_care, Colors.blue),
        _buildStatCard("Ibu Hamil", hamil.toString(), Icons.pregnant_woman, Colors.pink),
        _buildStatCard("Orang Tua", ortu.toString(), Icons.people_alt, Colors.orange),
        _buildStatCard("Total Warga", (anak + ortu + hamil).toString(), Icons.analytics, AdminColors.primary),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 30),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ],
      ),
    );
  }

  // --- DIAGRAM & LEGEND ---
  Widget _chartSection(String title, double pAnak, double pOrtu, double pHamil) {
    return Column(
      children: [
        SizedBox(
          height: 100, width: 100,
          child: CustomPaint(
            painter: MultiPieChartPainter(pAnak: pAnak, pOrtu: pOrtu, pHamil: pHamil),
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLegendSection(int anak, int ortu, int hamil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _legendItem("Anak ($anak)", Colors.blue),
        _legendItem("Orang Tua ($ortu)", Colors.orange),
        _legendItem("Ibu Hamil ($hamil)", Colors.pink),
      ],
    );
  }

  Widget _legendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // --- MENU GRID ---
  Widget _buildGridMenu(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildMenuBtn(context, "Data Anak", Icons.face, AdminColors.menuAnak, const HalamanDataAnak()),
        _buildMenuBtn(context, "Data Ortu", Icons.family_restroom, AdminColors.menuOrtu, const HalamanDataOrangTua()),
        _buildMenuBtn(context, "Imunisasi", Icons.vaccines, AdminColors.menuImunisasi, const HalamanDataImunisasi()),
        _buildMenuBtn(context, "Ibu Hamil", Icons.pregnant_woman, Colors.pinkAccent, const DataIbuHamilPage()),
        _buildMenuBtn(context, "Jadwal", Icons.calendar_month, AdminColors.menuJadwal, const HalamanJadwalPosyandu()),
        _buildMenuBtn(context, "Edukasi", Icons.menu_book, AdminColors.menuEdukasi, const HalamanEdukasi()),
        _buildMenuBtn(context, "Posyandu", Icons.local_hospital, AdminColors.menuPosyandu, const HalamanDataPosyandu()),
        _buildMenuBtn(context, "Laporan", Icons.print, AdminColors.menuLaporan, const HalamanCetakLaporan()),
        _buildMenuBtn(context, "Akun", Icons.manage_accounts, Colors.blueGrey, const HalamanPengaturanAkun()), 
        _buildMenuBtn(context, "Keluar", Icons.logout, Colors.red, null, isLogout: true),
      ],
    );
  }

  Widget _buildMenuBtn(BuildContext context, String label, IconData icon, Color color, Widget? page, {bool isLogout = false}) {
    return InkWell(
      onTap: () => isLogout ? _confirmLogout(context) : Navigator.push(context, MaterialPageRoute(builder: (c) => page!)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- PAINTER DIAGRAM ---
class MultiPieChartPainter extends CustomPainter {
  final double pAnak;
  final double pOrtu;
  final double pHamil;

  MultiPieChartPainter({required this.pAnak, required this.pOrtu, required this.pHamil});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;

    if (pAnak > 0) {
      paint.color = Colors.blue;
      double sweep = 2 * pi * pAnak;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    if (pOrtu > 0) {
      paint.color = Colors.orange;
      double sweep = 2 * pi * pOrtu;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    if (pHamil > 0) {
      paint.color = Colors.pink;
      double sweep = 2 * pi * pHamil;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
    }
    
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}