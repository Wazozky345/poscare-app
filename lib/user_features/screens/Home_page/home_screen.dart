import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/user_features/screens/Ibu_Hamil_page/user_ibu_hamil_page.dart';
import '../../core/colors.dart';
// Import halaman fitur yang sudah kita buat
 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Warna background lebih soft
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo_poscare.jpeg', height: 40),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Poscare", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Healthcare at your doorstep", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. WELCOME CARD (Dinamis)
            _buildWelcomeCard(uid),
            
            const SizedBox(height: 25),
            const Text("Layanan Poscare", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),

            // 2. GRID MENU (Fitur Ibu Hamil ada di sini)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildMenuItem(
                  context, 
                  "Ibu Hamil", 
                  Icons.pregnant_woman, 
                  Colors.pink,
                  onTap: () {
                    // Logika: Ambil NIK dari Firestore lalu buka halaman UserIbuHamilPage
                    _navigateToIbuHamil(context, uid);
                  }
                ),
                _buildMenuItem(context, "Anak", Icons.child_care, Colors.blue),
                _buildMenuItem(context, "Vaksin", Icons.vaccines, Colors.orange),
                _buildMenuItem(context, "Artikel", Icons.newspaper, Colors.green),
              ],
            ),

            const SizedBox(height: 25),

            // 3. KARTU JADWAL POSYANDU
            _buildScheduleCard(),

            const SizedBox(height: 15),

            // 4. KARTU DATA ANAK / RINGKASAN
            _buildDataAnakCard(),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI NAVIGASI KE HALAMAN IBU HAMIL ---
  void _navigateToIbuHamil(BuildContext context, String? uid) async {
    if (uid == null) return;
    
    // Ambil data user untuk mendapatkan NIK
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String nik = userDoc['nik'] ?? "";

    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => UserIbuHamilPage(userNik: nik)
      ));
    }
  }

  // --- WIDGET HELPER: WELCOME CARD ---
  Widget _buildWelcomeCard(String? uid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryColor, Color(0xFFE91E63)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 14)),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              String nama = "User";
              if (snapshot.hasData && snapshot.data!.exists) {
                nama = snapshot.data!['nama'] ?? "User";
              }
              return Text(nama, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
            },
          ),
          const SizedBox(height: 10),
          const Text("Semoga kesehatan Anda selalu terjaga hari ini.", style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: MENU ITEM ---
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: KARTU JADWAL ---
  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.calendar_month, color: Colors.orange),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Jadwal Posyandu Terdekat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("Selasa, 04 Juni 2024 • 09:00", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPER: DATA ANAK ---
  Widget _buildDataAnakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          Icon(Icons.child_care, color: Colors.grey, size: 40),
          SizedBox(height: 10),
          Text("Belum Ada Data Anak", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text("Tambahkan data anak melalui admin posyandu", style: TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}