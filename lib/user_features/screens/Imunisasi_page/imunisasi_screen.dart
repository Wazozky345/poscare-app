// lib/screens/imunisasi_screen.dart
import 'package:flutter/material.dart';
import '../../core/colors.dart';
import 'imunisasi_detail_screen.dart';

class ImunisasiScreen extends StatelessWidget {
  const ImunisasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Imunisasi",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Teks Himbauan
            const Text(
              "Yuk, Bunda! Pastikan anak kita mendapatkan imunisasi lengkap dan rutin memeriksakan kesehatan di posyandu. Kesehatan si kecil adalah investasi terbesar untuk masa depannya yang cerah!",
              style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
            ),
            
            const SizedBox(height: 20),

            // 2. Kartu Profil Anak
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Anak Header
                  RichText(
                    text: const TextSpan(
                      text: "Nama Anak: ",
                      style: TextStyle(color: AppColors.primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: "mevy kumalasari", // Sesuai desain
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 30),
                  
                  // Detail Data
                  _buildDetailRow("NIK Anak", "2313132913921839"),
                  _buildDetailRow("Tempat Lahir Anak", "Bondowoso"),
                  _buildDetailRow("Tanggal Lahir Anak", "2024-06-01"),
                  _buildDetailRow("Golongan Darah", "AB"),
                  _buildDetailRow("Anak Ke", "1"),
                  _buildDetailRow("Jenis Kelamin", "Perempuan"),

                  const SizedBox(height: 20),

                  // Tombol Lihat Riwayat
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigasi ke Detail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImunisasiDetailScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor, // Tombol Pink
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Lihat Riwayat Posyandu",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget kecil buat baris text biar rapi
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Lebar label biar rata
            child: Text("$label :", style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}