import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'form_data_orangtua_page.dart';

class HalamanDataOrangTua extends StatefulWidget {
  const HalamanDataOrangTua({super.key});

  @override
  State<HalamanDataOrangTua> createState() => _HalamanDataOrangTuaState();
}

class _HalamanDataOrangTuaState extends State<HalamanDataOrangTua> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  // 1. Pastikan nama koleksi 'users' sama persis dengan yang ada di file Form
  final CollectionReference _dbOrangTua = FirebaseFirestore.instance.collection('users');

  // --- LOGIC: NAVIGASI KE FORM ---
  void _navigateToForm({Map<String, dynamic>? dataEdit, String? docId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDataOrangTuaPage(dataEdit: dataEdit, docId: docId),
      ),
    );
    // StreamBuilder akan menangani pembaruan data secara otomatis (Real-time)
  }

  // --- LOGIC: HAPUS DATA DARI FIREBASE ---
  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus data ini dari cloud?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _dbOrangTua.doc(docId).delete();
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                debugPrint("Error hapus: $e");
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
                _detailRow("Nomor KK", data['no_kk']),
                const Divider(),
                _detailRow("Nama Ibu", data['nama_ibu']),
                _detailRow("NIK Ibu", data['nik_ibu']),
                _detailRow("TTL Ibu", "${data['tempat_lahir_ibu'] ?? '-'}, ${data['tgl_lahir_ibu'] ?? '-'}"),
                _detailRow("Gol. Darah", data['gol_darah_ibu']),
                const Divider(),
                _detailRow("Nama Ayah", data['nama_ayah']),
                _detailRow("NIK Ayah", data['nik_ayah']),
                const Divider(),
                _detailRow("Alamat", data['alamat']),
                _detailRow("Telepon", data['telepon']),
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
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text("Data Orang Tua", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToForm(),
                    icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                    label: const Text("TAMBAH DATA ORANG TUA", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
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

          // 2. LIST DATA (STREAMBUILDER DARI FIREBASE)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Tambahkan orderBy 'updated_at' agar data terbaru muncul di atas
              stream: _dbOrangTua.orderBy('updated_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Terjadi kesalahan pada Firebase"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;

                // Filter Pencarian Lokal
                if (_searchCtrl.text.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['nama_ibu'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.family_restroom, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada data orang tua", style: TextStyle(color: Colors.grey[500])),
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
                    final String docId = doc.id; 

                    return _buildOrangTuaCard(item, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrangTuaCard(Map<String, dynamic> item, String docId) {
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
          decoration: BoxDecoration(color: AdminColors.menuOrtu.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.family_restroom, color: AdminColors.menuOrtu, size: 24),
        ),
        title: Text(
          item['nama_ibu'] ?? "Tanpa Nama",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Ayah: ${item['nama_ayah'] ?? '-'}", style: const TextStyle(fontSize: 12)),
            Text("KK: ${item['no_kk'] ?? '-'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(onTap: () => _showDetail(item), child: const Icon(Icons.info_outline, color: Colors.amber, size: 22)),
            const SizedBox(width: 10),
            InkWell(onTap: () => _navigateToForm(dataEdit: item, docId: docId), child: const Icon(Icons.edit_note, color: Colors.blue, size: 24)),
            const SizedBox(width: 10),
            InkWell(onTap: () => _deleteData(docId), child: const Icon(Icons.delete_outline, color: Colors.red, size: 22)),
          ],
        ),
      ),
    );
  }
}