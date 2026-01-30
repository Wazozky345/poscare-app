// FILE: lib/admin_features/screens/Data_Posyandu/data_posyandu_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'form_data_posyandu_page.dart';

class HalamanDataPosyandu extends StatefulWidget {
  const HalamanDataPosyandu({super.key});

  @override
  State<HalamanDataPosyandu> createState() => _HalamanDataPosyanduState();
}

class _HalamanDataPosyanduState extends State<HalamanDataPosyandu> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  // Referensi ke Collection Firestore
  final CollectionReference _healthRef = FirebaseFirestore.instance.collection('data_kesehatan_anak');

  // --- LOGIC: NAVIGASI KE FORM ---
  void _navigateToForm(String title, {Map<String, dynamic>? dataEdit, String? docId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDataPosyanduPage(
          title: title,
          dataEdit: dataEdit,
          docId: docId, // Pass Doc ID untuk Edit
        ),
      ),
    );
  }

  // --- LOGIC: HAPUS DATA (VERSI FULL BIRU / NAVY GANTENG) ---
  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Biar popup gak kegedean
              children: [
                // 1. ICON (BIRU NAVY)
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
                  "Hapus Data?",
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: AdminColors.primary 
                  ),
                ),
                const SizedBox(height: 10),

                // 3. KONTEN TEKS (YANG ABANG MINTA)
                const Text(
                  "Yakin ingin menghapus data pemeriksaan ini? Data yang dihapus tidak bisa kembali.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // 4. TOMBOL AKSI
                Row(
                  children: [
                    // TOMBOL BATAL (Outline Biru)
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
                    
                    // TOMBOL HAPUS (Full Biru)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primary, // Jadi Biru Navy
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx); // Tutup dialog dulu
                          try {
                            await _healthRef.doc(docId).delete();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: AdminColors.primary),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
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

  // Helper Format Tanggal dari Timestamp
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    }
    return timestamp.toString();
  }

  // ==========================================
  // UI UTAMA
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,

      // --- APP BAR ---
      appBar: AppBar(
        title: const Text("Data Posyandu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // 1. HEADER (SEARCH & ADD BUTTON)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Cari nama anak...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: AdminColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Tombol Tambah Data
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToForm("Tambah Data Posyandu"),
                    icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                    label: const Text("INPUT DATA BARU", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. LIST DATA (STREAM BUILDER)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _healthRef.orderBy('tgl_posyandu', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Terjadi kesalahan"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter Search Client-Side
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nama = (data['nama_anak'] ?? '').toString().toLowerCase();
                  return nama.contains(_searchCtrl.text.toLowerCase());
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monitor_weight_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada data pemeriksaan", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    return _buildPosyanduCard(data, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD ---
  Widget _buildPosyanduCard(Map<String, dynamic> item, String docId) {
    // Parsing Vaksin
    String vaksinText = "-";
    if (item['vaksin'] is List) {
      List vaksins = item['vaksin'];
      if (vaksins.isEmpty || (vaksins.length == 1 && vaksins[0] == '-')) {
        vaksinText = "-";
      } else {
        vaksinText = vaksins.join(", ");
      }
    }

    // Warna Badge Kondisi
    String kondisi = item['kondisi'] ?? 'Sehat';
    Color kondisiColor = Colors.green;
    if (kondisi == 'Stunting' || kondisi == 'Kurang Gizi') {
      kondisiColor = Colors.red;
    } else if (kondisi == 'Sakit' || kondisi == 'Perlu Pantauan') {
      kondisiColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
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
        child: Column(
          children: [
            // BARIS 1: NAMA & KONDISI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Pake Expanded biar teks panjang ga overflow
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminColors.menuPosyandu.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.child_care, color: AdminColors.menuPosyandu, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama_anak'] ?? "Tanpa Nama",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${item['umur_bulan'] ?? 0} Bulan",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge Kondisi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kondisiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kondisiColor),
                  ),
                  child: Text(
                    kondisi,
                    style: TextStyle(color: kondisiColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            
            // BARIS 2: DATA FISIK (TB, BB, VAKSIN)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn("Tinggi Badan", "${item['tb'] ?? 0} cm"),
                _buildInfoColumn("Berat Badan", "${item['bb'] ?? 0} kg"),
                _buildInfoColumn("Vaksin", vaksinText, isLongText: true),
              ],
            ),
            const Divider(height: 20),

            // BARIS 3: TANGGAL & AKSI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(item['tgl_posyandu']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Edit
                    InkWell(
                      onTap: () => _navigateToForm("Edit Data Posyandu", dataEdit: item, docId: docId),
                      child: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 15),
                    // Hapus (Panggil Dialog Baru)
                    InkWell(
                      onTap: () => _deleteData(docId),
                      child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Kolom Info
  Widget _buildInfoColumn(String label, String value, {bool isLongText = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isLongText ? AdminColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}