// FILE: lib/user_features/screens/Edukasi_page/detail_edukasi_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert'; // Buat decode gambar
import '../../core/colors.dart';

class DetailEdukasiScreen extends StatelessWidget {
  final Map<String, dynamic> data; // Nerima data artikel dari halaman sebelumnya

  const DetailEdukasiScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String title = data['judul'] ?? "Tanpa Judul";
    String content = data['isi'] ?? "Tidak ada isi artikel.";
    String base64Image = data['gambar_url'] ?? "";
    bool hasImage = base64Image.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- APP BAR + GAMBAR HEADER (FLEXIBLE) ---
          SliverAppBar(
            expandedHeight: 250.0, // Tinggi gambar header
            pinned: true, // Appbar tetep nempel pas discroll
            backgroundColor: AppColors.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), // Tombol back
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Image.memory(
                      base64Decode(base64Image),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey.shade400),
                      ),
                    ),
            ),
          ),

          // --- ISI KONTEN ---
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              // Geser dikit ke atas biar numpuk gambar dikit (efek modern)
              transform: Matrix4.translationValues(0.0, -20.0, 0.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Garis kecil di tengah (pemanis UI)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tag Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Edukasi Kesehatan",
                      style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // JUDUL ARTIKEL
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black87,
                      height: 1.3
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Info Tanggal / Admin
                  Row(
                    children: [
                      const Icon(Icons.account_circle, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      const Text("Admin Posyandu", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 15),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      const Text("Terbaru", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.grey, thickness: 0.5),
                  ),

                  // ISI ARTIKEL
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Colors.black87, 
                      height: 1.6 // Spasi antar baris biar enak dibaca
                    ),
                    textAlign: TextAlign.justify, // Rata kanan kiri
                  ),
                  
                  const SizedBox(height: 50), // Spasi bawah biar gak mentok
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}