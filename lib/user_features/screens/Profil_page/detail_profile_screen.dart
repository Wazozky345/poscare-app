import 'package:flutter/material.dart';
import '../../core/colors.dart';

class DetailProfileScreen extends StatelessWidget {
  // Kita butuh data user yang dikirim dari halaman sebelumnya
  final Map<String, dynamic> data;

  const DetailProfileScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Biodata Lengkap", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Data Pribadi"),
            _buildItem("Nama Lengkap", data['nama']),
            _buildItem("NIK", data['nik']),
            _buildItem("Tempat Lahir", data['tempat_lahir']),
            _buildItem("Tanggal Lahir", data['tanggal_lahir']),
            _buildItem("Golongan Darah", data['gol_darah']),
            _buildItem("Nomor HP", data['noHp']),
            _buildItem("Email", data['email']),

            const SizedBox(height: 20),
            _buildSectionHeader("Data Keluarga"),
            _buildItem("Nomor Kartu Keluarga (KK)", data['no_kk']),
            _buildItem("Nama Ayah", data['nama_ayah']),
            _buildItem("NIK Ayah", data['nik_ayah']),
            _buildItem("Alamat Keluarga", data['alamat']),
          ],
        ),
      ),
    );
  }

  // Widget Judul Bagian
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: AppColors.primaryColor
        ),
      ),
    );
  }

  // Widget Baris Data
  Widget _buildItem(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "-",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}