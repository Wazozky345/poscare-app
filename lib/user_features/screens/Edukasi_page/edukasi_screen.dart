// FILE: lib/user_features/screens/Edukasi_page/edukasi_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../../core/colors.dart';
import 'detail_edukasi_screen.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA CERDAS: CEK APAKAH BISA DI-BACK? ---
    // Kalau true = berarti dibuka dari Home (tampilkan tombol back)
    // Kalau false = berarti dibuka dari Navbar (sembunyikan tombol back)
    bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        // --- LOGIC TOMBOL BACK ---
        automaticallyImplyLeading: false, // Kita atur manual di bawah
        leading: canPop 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryColor),
                onPressed: () => Navigator.pop(context), // Balik ke Home
              )
            : null, // Kalau dari Navbar, gak ada tombol back
            
        title: const Text(
          "Edukasi",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: canPop ? true : false, // Kalau ada back, judul di tengah biar rapi
      ),
      body: Column(
        children: [
          // 1. Teks Pengantar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              "Yuk bunda, baca edukasi untuk memperoleh informasi tentang pola asuh, kesehatan untuk pertumbuhan balita.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),

          // 2. List Artikel (Realtime Firestore)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('edukasi')
                  .orderBy('dibuat_pada', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                }

                // Data Kosong
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada artikel edukasi", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                // Ada Data
                var docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String title = data['judul'] ?? "Tanpa Judul";
                    String base64Image = data['gambar_url'] ?? "";

                    // Navigasi ke Detail
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailEdukasiScreen(data: data),
                          ),
                        );
                      },
                      child: _buildArticleCard(
                        title: title,
                        base64Image: base64Image,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD ARTIKEL ---
  Widget _buildArticleCard({required String title, required String base64Image}) {
    bool hasImage = base64Image.isNotEmpty;

    return Container(
      height: 180, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade200,
        image: hasImage 
            ? DecorationImage(
                image: MemoryImage(base64Decode(base64Image)), 
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Gradient Gelap
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          
          // Isi Tulisan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tag "Edukasi"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor, 
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Edukasi",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 8),
                // Judul Artikel
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16, 
                    shadows: [
                      Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54), 
                    ]
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}