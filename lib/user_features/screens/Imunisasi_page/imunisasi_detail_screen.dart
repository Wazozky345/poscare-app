// FILE: lib/user_features/screens/Imunisasi_page/imunisasi_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/intl.dart'; 
import '../../core/colors.dart';

class ImunisasiDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ImunisasiDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // --- OLAH DATA DARI DATABASE ---
    String namaAnak = data['nama_anak'] ?? '-';
    String bb = data['bb']?.toString() ?? '-';
    String tb = data['tb']?.toString() ?? '-';
    String umur = data['umur_bulan']?.toString() ?? '-';
    
    // DATA BARU: STATUS KESEHATAN
    String kondisi = data['kondisi'] ?? 'Sehat';
    
    // Logic Warna Text Status di Tabel
    Color statusColor;
    if (kondisi == 'Sakit') statusColor = Colors.red;
    else if (kondisi == 'Stunting') statusColor = Colors.orange;
    else statusColor = Colors.green;

    // Format Tanggal
    Timestamp? tgl = data['tgl_posyandu'];
    String tglStr = tgl != null 
        ? DateFormat('yyyy-MM-dd').format(tgl.toDate()) 
        : '-';

    // Format Vaksin
    String listVaksin = "-";
    if (data['vaksin'] is List) {
       List<dynamic> v = data['vaksin'];
       if (v.isNotEmpty) listVaksin = v.join(",\n");
    } else if (data['vaksin'] is String) {
       listVaksin = data['vaksin'];
    }
    if (listVaksin == "" || listVaksin == "-") listVaksin = "Pemeriksaan Rutin";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor, 
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
              child: Column(
                children: [
                  const Text(
                    "Riwayat Posyandu dan Imunisasi Anak",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Nama Anak: $namaAnak",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. Tabel Data (Updated dengan Kolom Status)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SingleChildScrollView( // Biar bisa scroll horizontal kalo layar kecil
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(AppColors.primaryColor),
                    headingTextStyle: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    columnSpacing: 20, // Jarak antar kolom agak renggang dikit
                    dataRowMinHeight: 60,
                    dataRowMaxHeight: double.infinity, 
                    columns: const [
                      DataColumn(label: Text("Tanggal")),
                      DataColumn(label: Text("TB")),
                      DataColumn(label: Text("BB")),
                      DataColumn(label: Text("Umur")),
                      DataColumn(label: Text("Status")), // KOLOM BARU
                      DataColumn(label: Text("Vaksin")),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text(tglStr, style: const TextStyle(fontSize: 12))),
                        DataCell(Text("$tb cm", style: const TextStyle(fontSize: 12))),
                        DataCell(Text("$bb kg", style: const TextStyle(fontSize: 12))),
                        DataCell(Text("$umur bln", style: const TextStyle(fontSize: 12))),
                        // CELL STATUS (Berwarna)
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              kondisi, 
                              style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold)
                            ),
                          )
                        ),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(listVaksin, style: const TextStyle(fontSize: 12)),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}