// lib/screens/edukasi_screen.dart
import 'package:flutter/material.dart';
import '../../core/colors.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy Artikel (Biar dinamis dikit)
    final List<Map<String, String>> articles = [
      {
        "title": "Ketahui 6 Ciri-ciri Anak Sehat dan Cara Menjaga Kesehatan Anak",
        "image": "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&q=80&w=600" // Gambar Anak Main
      },
      {
        "title": "Pentingnya Makanan Gizi Seimbang untuk Dukung Perkembangan Anak",
        "image": "https://images.unsplash.com/photo-1566004100631-35d015d6a491?auto=format&fit=crop&q=80&w=600" // Gambar Anak Makan
      },
      {
        "title": "Begini Membentuk Pola Makan Sehat Balita",
        "image": "https://images.unsplash.com/photo-1544945582-35804f3693fb?auto=format&fit=crop&q=80&w=600" // Gambar Keluarga
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Gak perlu tombol back di menu utama
        title: const Text(
          "Edukasi",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
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

          // 2. List Artikel
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: articles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildArticleCard(
                  title: articles[index]['title']!,
                  imageUrl: articles[index]['image']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard({required String title, required String imageUrl}) {
    return Container(
      height: 180, // Tinggi kartu
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(imageUrl), // Tarik gambar dari internet
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient Gelap di Bawah (Biar tulisan kebaca)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8), // Hitam transparan di bawah
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
                    color: AppColors.primaryColor, // Pink Poscare
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
                    fontSize: 14,
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