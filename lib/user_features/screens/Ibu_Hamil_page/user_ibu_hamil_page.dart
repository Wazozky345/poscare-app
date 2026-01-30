// FILE: lib/user_features/screens/Ibu_Hamil_page/user_ibu_hamil_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart'; 
import 'ibu_hamil_detail_screen.dart';

class UserIbuHamilPage extends StatelessWidget {
  const UserIbuHamilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Anda belum login")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Pemeriksaan Kehamilan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ibu_hamil') 
            .where('parent_uid', isEqualTo: uid) 
            .orderBy('tgl_pemeriksaan', descending: true)
            .snapshots(),
        
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          // TAMPILAN JIKA DATA KOSONG (SUDAH BERSIH)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.pink[50], shape: BoxShape.circle),
                    child: const Icon(Icons.pregnant_woman, size: 60, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 15),
                  // Teks info teknis sudah dihapus di sini
                  const Text("Belum ada data pemeriksaan", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              // --- PARSING DATA ---
              Timestamp? tgl = data['tgl_pemeriksaan'];
              String tglStr = tgl != null ? DateFormat('dd MMM yyyy').format(tgl.toDate()) : '-';
              
              String usia = data['usia_kehamilan']?.toString() ?? '-';
              String keluhan = data['riwayat_kesehatan'] ?? 'Sehat';
              String namaIbu = data['nama'] ?? 'Ibu';

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IbuHamilDetailScreen(data: data),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.pregnant_woman, color: AppColors.primaryColor, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(namaIbu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 5),
                              Text("Usia Kandungan: $usia Bulan", style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(tglStr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text("Kondisi: $keluhan", 
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.green, fontStyle: FontStyle.italic)
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}