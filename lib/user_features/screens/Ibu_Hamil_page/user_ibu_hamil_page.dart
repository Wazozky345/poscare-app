import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';

class UserIbuHamilPage extends StatelessWidget {
  final String userNik; // Identitas unik pengguna (misal dari hasil login)

  const UserIbuHamilPage({super.key, required this.userNik});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Kesehatan Ibu Hamil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AdminColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mencari data berdasarkan NIK yang login
        stream: FirebaseFirestore.instance
            .collection('ibu_hamil')
            .where('nik', isEqualTo: userNik)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(userData),
                const SizedBox(height: 25),
                const Text("Statistik Kesehatan Terakhir", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.primary)),
                const SizedBox(height: 15),
                _buildHealthGrid(userData),
                const SizedBox(height: 25),
                _buildInfoBanner(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Tampilan jika data tidak ditemukan
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 15),
          const Text("Data Kesehatan Belum Tersedia", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text("Silakan hubungi admin Posyandu untuk melengkapi data Anda.", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // Card Atas: Informasi Nama dan HPL
  Widget _buildHeaderCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AdminColors.primary, Color(0xFF2C3E50)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AdminColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['nama']?.toUpperCase() ?? "IBU HAMIL", 
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("NIK: ${data['nik'] ?? '-'}", style: const TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerInfoItem("Usia Hamil", "${data['usia_kehamilan'] ?? '-'} Minggu"),
              _headerInfoItem("Estimasi HPL", data['hpl'] ?? "-"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Grid Statistik: Tekanan Darah, Berat Badan, dll
  Widget _buildHealthGrid(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _statCard("Tekanan Darah", data['tekanan_darah'] ?? "-", Icons.speed, Colors.red),
        _statCard("Berat Badan", "${data['berat_badan'] ?? '-'} Kg", Icons.monitor_weight, Colors.blue),
        _statCard("Riwayat", "Lihat Catatan", Icons.history_edu, Colors.orange),
        _statCard("Status", "Normal", Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Banner Edukasi
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tips Kehamilan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                Text("Jangan lupa konsumsi asam folat dan rutin periksa ke Posyandu.", 
                    style: TextStyle(fontSize: 12, color: Colors.blue[800])),
              ],
            ),
          )
        ],
      ),
    );
  }
}