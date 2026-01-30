// FILE: lib/user_features/screens/Imunisasi_page/user_imunisasi_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart'; 
import 'imunisasi_detail_screen.dart'; 

class UserImunisasiPage extends StatelessWidget {
  const UserImunisasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
        return const Scaffold(body: Center(child: Text("Anda belum login")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], 
      appBar: AppBar(
        title: const Text(
          "Riwayat Imunisasi", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: AppColors.primaryColor, 
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('data_kesehatan_anak')
            .where('parent_uid', isEqualTo: uid)
            .orderBy('tgl_posyandu', descending: true) 
            .snapshots(),
        
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Belum ada riwayat imunisasi"));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              
              // --- PARSING DATA ---
              String namaAnak = data['nama_anak'] ?? 'Anak';
              Timestamp? tgl = data['tgl_posyandu'];
              String tglStr = tgl != null ? DateFormat('dd MMM yyyy').format(tgl.toDate()) : '-';
              
              String listVaksin = "-";
              if (data['vaksin'] is List) {
                 List<dynamic> v = data['vaksin'];
                 if (v.isNotEmpty) listVaksin = v.join(", ");
              } else if (data['vaksin'] is String) {
                 listVaksin = data['vaksin'];
              }
              if (listVaksin == "" || listVaksin == "-") listVaksin = "Pemeriksaan Rutin";

              String bb = data['bb']?.toString() ?? '0';
              String tb = data['tb']?.toString() ?? '0';
              
              // --- DATA BARU: STATUS KESEHATAN ---
              String kondisi = data['kondisi'] ?? 'Sehat';
              
              // Logic Warna Badge Status
              Color statusColor;
              Color statusBg;
              if (kondisi == 'Sakit') {
                statusColor = Colors.red;
                statusBg = Colors.red.shade50;
              } else if (kondisi == 'Stunting') {
                statusColor = Colors.orange;
                statusBg = Colors.orange.shade50;
              } else {
                statusColor = Colors.green;
                statusBg = Colors.green.shade50;
              }

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImunisasiDetailScreen(data: data),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1), 
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.vaccines, color: AppColors.primaryColor, size: 24),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Baris Judul & Status (NEW)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(listVaksin, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ),
                                      // BADGE STATUS
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: statusColor.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          kondisi,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(tglStr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.person, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(namaAnak, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _infoChip("BB: $bb kg"),
                                      const SizedBox(width: 8),
                                      _infoChip("TB: $tb cm"),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100], 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold)),
    );
  }
}