// FILE: lib/admin_features/screens/Data_Ibu_Hamil/data_ibu_hamil_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'form_ibu_hamil_page.dart';

class DataIbuHamilPage extends StatefulWidget {
  const DataIbuHamilPage({super.key});

  @override
  State<DataIbuHamilPage> createState() => _DataIbuHamilPageState();
}

class _DataIbuHamilPageState extends State<DataIbuHamilPage> {
  String searchQuery = "";

  // --- LOGIKA HAPUS (FULL BIRU NAVY) ---
  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                // 1. ICON
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: AdminColors.primary, size: 40),
                ),
                const SizedBox(height: 20),

                // 2. JUDUL
                const Text("Hapus Data?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminColors.primary)),
                const SizedBox(height: 10),

                // 3. KONTEN
                const Text(
                  "Yakin ingin menghapus data ibu hamil ini? Data yang dihapus tidak bisa kembali.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // 4. TOMBOL AKSI
                Row(
                  children: [
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
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          try {
                            await FirebaseFirestore.instance.collection('ibu_hamil').doc(docId).delete();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Terhapus"), backgroundColor: AdminColors.primary));
                            }
                          } catch (e) {
                            // Handle Error
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

  // --- LOGIKA DETAIL (REVISI: WARNA BIRU NAVY) ---
  void _showDetail(Map<String, dynamic> data) {
    String parentUid = data['parent_uid'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.family_restroom, size: 60, color: AdminColors.primary),
              const SizedBox(height: 10),
              const Text("Detail Data Ibu Hamil", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminColors.primary)),
              
              const SizedBox(height: 20),
              
              // --- INFO AKUN USER (YANG PUNYA DATA) - WARNA BIRU NAVY ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withOpacity(0.1), // Background Biru Muda
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AdminColors.primary.withOpacity(0.3)), // Border Biru Tipis
                ),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(parentUid).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                    }
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Terhubung ke Akun User:", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary, fontSize: 12)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.account_circle, size: 30, color: AdminColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userData['nama'] ?? "Tanpa Nama", style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark)),
                                    Text(userData['email'] ?? "-", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return const Text("User tidak ditemukan / Terhapus", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic));
                  },
                ),
              ),

              const Divider(height: 30),
              
              // --- DATA DETAIL ---
              _buildDetailItem("Nama Ibu", data['nama']),
              _buildDetailItem("NIK Ibu", data['nik']),
              _buildDetailItem("Usia Hamil", "${data['usia_kehamilan'] ?? '-'} Bulan"),
              _buildDetailItem("HPL", data['hpl']),
              _buildDetailItem("Tekanan Darah", data['tekanan_darah']),
              _buildDetailItem("Berat Badan", "${data['berat_badan'] ?? '-'} kg"),
              _buildDetailItem("Riwayat", data['riwayat_kesehatan']),
              
              // Data Tambahan (Yang baru diinput)
              const Divider(),
              _buildDetailItem("Tinggi Fundus", "${data['tinggi_fundus'] ?? '-'} cm"),
              _buildDetailItem("Detak Jantung", "${data['detak_jantung_janin'] ?? '-'} bpm"),
              _buildDetailItem("LILA", "${data['lila'] ?? '-'} cm"),

              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("TUTUP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text("$label :", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value?.toString() ?? "-", style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
            decoration: const BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
                    const Expanded(child: Center(child: Text("Data Ibu Hamil", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
                    decoration: const InputDecoration(icon: Icon(Icons.search), hintText: "Cari nama ibu...", border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AdminColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FormIbuHamilPage(userId: '',))),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("TAMBAH DATA IBU HAMIL", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // List Data
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ibu_hamil').orderBy('last_update', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                var docs = snapshot.data!.docs.where((d) {
                  var data = d.data() as Map<String, dynamic>;
                  String nama = data.containsKey('nama') ? data['nama'].toString().toLowerCase() : "";
                  return nama.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) return const Center(child: Text("Data tidak ditemukan"));

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String docId = docs[index].id;

                    String namaIbu = data['nama'] ?? "Tanpa Nama";
                    String nikIbu = data['nik'] ?? "-";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: Colors.pink[50], radius: 25, child: const Icon(Icons.pregnant_woman, color: Colors.pink)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(namaIbu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("NIK: $nikIbu", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(onTap: () => _showDetail(data), child: Icon(Icons.info_outline, color: Colors.yellow[700], size: 24)),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => FormIbuHamilPage(docId: docId, existingData: data, userId: '',))),
                                child: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(onTap: () => _confirmDelete(docId), child: const Icon(Icons.delete_outline, color: Colors.red, size: 24)),
                            ],
                          )
                        ],
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
}