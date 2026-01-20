import 'package:flutter/material.dart';
import 'dart:math';

// --- IMPORT WARNA ---
import 'package:poscare/admin_features/core/admin_colors.dart';

// --- IMPORT FILE LAIN ---
import 'package:poscare/admin_features/screens/Jadwal_Posyandu/jadwal_posyandu_page.dart';
import 'package:poscare/admin_features/screens/config.dart';
import 'package:poscare/admin_features/screens/Data_Anak/data_anak_page.dart';
import 'package:poscare/admin_features/screens/Data_Orangtua/data_orangtua_page.dart';
import 'package:poscare/admin_features/screens/Data_Imunisasi/data_imunisasi_page.dart';
import 'package:poscare/admin_features/screens/Edukasi/edukasi_page.dart';
import 'package:poscare/admin_features/screens/Data_Posyandu/data_posyandu_page.dart';
import 'package:poscare/admin_features/screens/Cetak_Laporan/cetak_laporan_page.dart';
import 'package:poscare/admin_features/screens/Pengaturan_Akun/pengaturan_akun_page.dart';
import 'package:poscare/admin_features/screens/Data_Ibu_Hamil/data_ibu_hamil_page.dart'; // Import Fitur Baru
import 'package:poscare/user_features/screens/Login_page/login_screen.dart';

class DashboardAdminPage extends StatelessWidget {
  final String namaUser;
  const DashboardAdminPage({super.key, required this.namaUser});

  // --- FUNGSI LOGOUT (CUSTOM DIALOG NAVY PREMIUM) ---
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AdminColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AdminColors.primary, size: 40),
            ),
            const SizedBox(height: 15),
            const Text(
              "Konfirmasi Keluar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AdminColors.textDark),
            ),
          ],
        ),
        content: const Text(
          "Yakin ingin keluar dari akun admin?",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Batal", style: TextStyle(color: Colors.black54)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (c) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA HITUNG DATA ---
    int totalAnak = globalDataAnak.length;
    int anakLaki = globalDataAnak.where((item) => item['jk'] == 'Laki-laki').length;
    int anakPerempuan = globalDataAnak.where((item) => item['jk'] == 'Perempuan').length;
    
    double persentaseLaki = totalAnak == 0 ? 0 : anakLaki / totalAnak;
    int totalOrangTua = globalDataOrangTua.length;
    double persentaseOrangTua = 1.0; 
  
    return Scaffold(
      backgroundColor: AdminColors.background,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: AdminColors.primary,
        elevation: 0,
        title: const Text(
          "Poscare Admin", 
          style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.white)
        ),
      ),

      // --- BODY UTAMA ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER ADMIN
            _buildHeader(),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 2. DIAGRAM LINGKARAN ---
                  const Text("Ringkasan Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AdminColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _chartSection("Gender Anak", persentaseLaki, AdminColors.chartLaki, AdminColors.chartPerempuan), 
                        _chartSection("Data Orang Tua", persentaseOrangTua, AdminColors.primary, Colors.grey),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- 3. KARTU STATISTIK ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard("Total Anak", totalAnak.toString(), Icons.child_care, Colors.blue),
                      _buildStatCard("Ibu Hamil", "Update", Icons.pregnant_woman, Colors.pink), // Tambahan statistik
                      _buildStatCard("Laki-laki", anakLaki.toString(), Icons.male, AdminColors.chartLaki),
                      _buildStatCard("Perempuan", anakPerempuan.toString(), Icons.female, AdminColors.chartPerempuan),
                      _buildStatCard("Orang Tua", totalOrangTua.toString(), Icons.people_alt, Colors.orange),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- 4. MENU PINTASAN ---
                  const Text("Menu Pintasan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  GridView.count(
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
                       _buildMenuBtn(context, "Pengaturan", Icons.settings, AdminColors.menuPengaturan, const HalamanPengaturanAkun()),
                       
                       // TOMBOL KELUAR
                       _buildMenuBtn(
                         context, 
                         "Keluar", 
                         Icons.logout, 
                         Colors.red, 
                         null, 
                         isLogout: true 
                       ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: AdminColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: AdminColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.admin_panel_settings, size: 35, color: AdminColors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(namaUser, style: const TextStyle(color: AdminColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AdminColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AdminColors.textDark)),
              Text(title, style: const TextStyle(fontSize: 12, color: AdminColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBtn(BuildContext context, String label, IconData icon, Color color, Widget? page, {bool isLogout = false}) {
    return InkWell(
      onTap: () {
        if (isLogout) {
          _confirmLogout(context); 
        } else if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => page));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AdminColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AdminColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _chartSection(String title, double percent, Color c1, Color c2) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: CustomPaint(
            painter: PieChartPainter(percentage: percent, color1: c1, color2: c2),
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        if (title.contains("Gender")) ...[
           Row(children: [Icon(Icons.circle, size: 8, color: c1), const SizedBox(width:4), const Text("Laki", style: TextStyle(fontSize:10))]),
           Row(children: [Icon(Icons.circle, size: 8, color: c2), const SizedBox(width:4), const Text("Pr", style: TextStyle(fontSize:10))]),
        ] else ...[
           Row(children: [Icon(Icons.circle, size: 8, color: c1), const SizedBox(width:4), const Text("Total", style: TextStyle(fontSize:10))]),
        ]
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double percentage;
  final Color color1;
  final Color color2;
  PieChartPainter({
    required this.percentage,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    paint.color = color2;
    canvas.drawCircle(center, radius, paint);
    paint.color = color1;
    double sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      true,
      paint,
    );
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}