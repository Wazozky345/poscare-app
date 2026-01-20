// lib/screens/grafik_screen.dart
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'grafik_detail_screen.dart';

class GrafikScreen extends StatelessWidget {
  const GrafikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DATA DUMMY: Ceritanya ini data dari Database/Admin
    // Kalo mau liat tampilan kosong, hapus isi list ini jadi []
    final List<String> anakList = ["Mevy Kumalasari"]; 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Grafik",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Teks
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Timbanglah Anak Anda Setiap Bulan. Anak Sehat, Tambah Umur Tambah Berat, Tambah Pandai.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          
          Expanded(
            child: anakList.isEmpty
                ? _buildEmptyState() // Tampilan kalau belum ada data dari admin
                : ListView.builder(  // Tampilan kalau sudah ada data
                    padding: const EdgeInsets.all(20),
                    itemCount: anakList.length,
                    itemBuilder: (context, index) {
                      return _buildAnakCard(context, anakList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget Tampilan Kosong
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("Belum ada data grafik anak", style: TextStyle(color: Colors.grey)),
          Text("Data akan muncul setelah diinput oleh Kader", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget Kartu Nama Anak
  Widget _buildAnakCard(BuildContext context, String nama) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        title: Text(
          nama,
          style: const TextStyle(
            color: AppColors.primaryColor, // Nama jadi Pink biar senada
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
        onTap: () {
          // Navigasi ke Halaman Detail Grafik
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GrafikDetailScreen(namaAnak: nama),
            ),
          );
        },
      ),
    );
  }
}