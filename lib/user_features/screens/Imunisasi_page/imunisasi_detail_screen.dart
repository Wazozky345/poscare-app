// lib/screens/imunisasi_detail_screen.dart
import 'package:flutter/material.dart';
import '../../core/colors.dart';

class ImunisasiDetailScreen extends StatelessWidget {
  const ImunisasiDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor, // Header Pink
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Detail Imunisasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Header Judul
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  "Riwayat Posyandu dan Imunisasi Anak",
                  style: TextStyle(
                    color: AppColors.primaryColor, // Teks Pink
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. Tabel Data
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.primaryColor), // Header Tabel Pink
                  headingTextStyle: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold
                  ),
                  columnSpacing: 20, // Jarak antar kolom biar gak dempet
                  columns: const [
                    DataColumn(label: Text("Tanggal")),
                    DataColumn(label: Text("TB")),
                    DataColumn(label: Text("BB")),
                    DataColumn(label: Text("Umur")),
                    DataColumn(label: Text("Vaksin")),
                  ],
                  rows: const [
                    // DATA DUMMY SESUAI SCREENSHOT
                    DataRow(cells: [
                      DataCell(Text("2024-06-12", style: TextStyle(fontSize: 12))),
                      DataCell(Text("72 cm", style: TextStyle(fontSize: 12))),
                      DataCell(Text("2 kg", style: TextStyle(fontSize: 12))),
                      DataCell(Text("0 bulan", style: TextStyle(fontSize: 12))),
                      DataCell(Text("Hepatitis B,\nBCG", style: TextStyle(fontSize: 12))), // Pake \n biar turun baris
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}