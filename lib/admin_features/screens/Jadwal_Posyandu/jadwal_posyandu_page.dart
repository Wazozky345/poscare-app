// FILE: lib/admin_features/screens/Jadwal_Posyandu/jadwal_posyandu_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'form_jadwal_posyandu_page.dart';

class HalamanJadwalPosyandu extends StatefulWidget {
  const HalamanJadwalPosyandu({super.key});

  @override
  State<HalamanJadwalPosyandu> createState() => _HalamanJadwalPosyanduState();
}

class _HalamanJadwalPosyanduState extends State<HalamanJadwalPosyandu> {
  
  // --- NAVIGASI KE FORM ---
  void _navigateToForm({String? docId, Map<String, dynamic>? data}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormJadwalPosyanduPage(
          docId: docId, // Kirim ID Dokumen (null = Tambah Baru)
          dataEdit: data, // Kirim Data Lama (null = Kosong)
        ),
      ),
    );
  }

  // --- HAPUS DATA (DIALOG POPUP GANTENG - FULL NAVY) ---
  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Sudut membulat modern
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Biar popup gak kegedean
              children: [
                // 1. ICON PERINGATAN (TONG SAMPAH BIRU)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withOpacity(0.1), // Background Biru Transparan
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: AdminColors.primary, size: 40),
                ),
                const SizedBox(height: 20),

                // 2. JUDUL
                const Text(
                  "Hapus Jadwal?",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: AdminColors.primary // Warna Navy tema Admin
                  ),
                ),
                const SizedBox(height: 10),

                // 3. KONTEN TEKS
                const Text(
                  "Jadwal ini akan dihapus secara permanen dari database. Tindakan ini tidak bisa dibatalkan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // 4. TOMBOL AKSI (BATAL & HAPUS)
                Row(
                  children: [
                    // TOMBOL BATAL (OUTLINE BIRU)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AdminColors.primary), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Batal", style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold)), 
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // TOMBOL HAPUS (FULL BIRU)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primary, // Full Biru Navy
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx); // Tutup dialog dulu
                          try {
                            // HAPUS DARI FIREBASE
                            await FirebaseFirestore.instance.collection('jadwal_posyandu').doc(docId).delete();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Jadwal berhasil dihapus"), backgroundColor: AdminColors.primary), // Snack bar biru juga
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        child: const Text("Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text("Jadwal Posyandu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. HEADER (TOMBOL TAMBAH)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToForm(), // Tambah Baru
                icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                label: const Text(
                  "BUAT JADWAL BARU",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),

          // 2. LIST JADWAL (STREAM FIRESTORE)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jadwal_posyandu')
                  .orderBy('tanggal_date', descending: false) // Urutkan dari tanggal terdekat (Lama -> Baru)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada jadwal posyandu", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String docId = docs[index].id;
                    
                    return _buildJadwalCard(docId, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD JADWAL (UPDATE LOGIC STATUS 3 KATEGORI) ---
  Widget _buildJadwalCard(String docId, Map<String, dynamic> item) {
    String tanggalStr = item['tanggal_str'] ?? "-";
    String jamBuka = item['jam_mulai'] ?? "-";
    String jamTutup = item['jam_selesai'] ?? "-";
    
    // Default Status (Masa Depan)
    String statusText = "Akan Datang";
    Color statusColor = Colors.green;
    Color textColor = AdminColors.textDark;
    Color iconColor = AdminColors.menuJadwal;
    Color cardColor = Colors.white;

    if (item['tanggal_date'] != null) {
      DateTime date = (item['tanggal_date'] as Timestamp).toDate();
      
      // Reset jam ke 00:00:00 biar perbandingan tanggalnya fair
      DateTime now = DateTime.now();
      DateTime todayStart = DateTime(now.year, now.month, now.day);
      DateTime jadwalDate = DateTime(date.year, date.month, date.day);
      
      if (jadwalDate.isBefore(todayStart)) {
        // 1. MASA LALU (Sudah Lewat)
        statusText = "Selesai";
        statusColor = Colors.grey;
        textColor = Colors.grey; 
        iconColor = Colors.grey; 
        cardColor = Colors.grey.shade50; 
      } else if (jadwalDate.isAtSameMomentAs(todayStart)) {
        // 2. HARI INI (Sedang Berlangsung)
        statusText = "Sedang Berlangsung";
        statusColor = Colors.blue; // Pake biru biar beda dari hijau
        textColor = Colors.black87; 
        iconColor = Colors.blue;
        cardColor = Colors.blue.shade50; // Background agak biru dikit biar highlight
      } 
      // 3. MASA DEPAN (Default else: "Akan Datang", Hijau)
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Bagian Kiri (Icon Kalender)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.event_note, color: iconColor, size: 30),
            ),
            const SizedBox(width: 15),

            // Bagian Tengah (Info)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BADGE STATUS
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      statusText, 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)
                    ),
                  ),
                  
                  Text(
                    tanggalStr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: textColor.withOpacity(0.6)),
                      const SizedBox(width: 5),
                      Text(
                        "$jamBuka - $jamTutup WIB",
                        style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bagian Kanan (Tombol Aksi)
            Row(
              children: [
                // Edit
                InkWell(
                  onTap: () => _navigateToForm(docId: docId, data: item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                // Hapus
                InkWell(
                  onTap: () => _deleteData(docId),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), // Ikon list tetep merah gapapa ya bang, buat bedain tombol hapus
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}