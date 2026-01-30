// FILE: lib/admin_features/screens/Data_Orangtua/data_orangtua_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';

class HalamanDataOrangTua extends StatefulWidget {
  const HalamanDataOrangTua({super.key});

  @override
  State<HalamanDataOrangTua> createState() => _HalamanDataOrangTuaState();
}

class _HalamanDataOrangTuaState extends State<HalamanDataOrangTua> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  // 1. Target ke collection 'users'
  final CollectionReference _dbUsers = FirebaseFirestore.instance.collection('users');

  // --- DETAIL POPUP ---
  void _showDetail(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Column(
            children: [
              Icon(Icons.family_restroom, size: 50, color: AdminColors.primary),
              SizedBox(height: 10),
              Text(
                "Detail Data Orang Tua",
                style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _detailRow("Nomor KK", data['no_kk'] ?? data['kk']), 
                const Divider(),
                _detailRow("Nama Ibu", data['nama']), 
                _detailRow("NIK Ibu", data['nik']),
                _detailRow("Email", data['email']),
                _detailRow("Gol. Darah", data['gol_darah']),
                const Divider(),
                _detailRow("Nama Ayah", data['nama_ayah']), 
                _detailRow("NIK Ayah", data['nik_ayah']), 
                const Divider(),
                _detailRow("Alamat", data['alamat']),
                
                // --- PERBAIKAN UTAMA DISINI BANG ---
                // Sesuai screenshot DB Queen, fieldnya adalah 'noHp'
                _detailRow("Telepon", 
                  data['noHp'] ??       // <-- Ini yang dipake Queen
                  data['telepon'] ??    // Jaga-jaga format lama
                  data['no_hp'] ??      // Variasi lain
                  "-"
                ), 
                // -----------------------------------
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("$label :", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 12)),
          ),
          Expanded(
            child: Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        title: const Text("Data Orang Tua", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. HEADER (SEARCH)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Cari nama ibu...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: AdminColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ),

          // 2. LIST DATA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _dbUsers.orderBy('nama').snapshots(), 
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Terjadi kesalahan pada Firebase"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;

                // Filter Pencarian Lokal
                if (_searchCtrl.text.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return (data['nama'] ?? '').toString().toLowerCase().contains(_searchCtrl.text.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.family_restroom, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada data user terdaftar", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final item = doc.data() as Map<String, dynamic>;
                    
                    return _buildOrangTuaCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrangTuaCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.people, color: Colors.green, size: 24),
        ),
        title: Text(
          item['nama'] ?? "Tanpa Nama", 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Ayah: ${item['nama_ayah'] ?? '-'}", style: const TextStyle(fontSize: 12)),
            Text("KK: ${item['no_kk'] ?? item['kk'] ?? '-'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: InkWell(
          onTap: () => _showDetail(item),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.info_outline, color: Colors.blue, size: 22),
          ),
        ),
      ),
    );
  }
}