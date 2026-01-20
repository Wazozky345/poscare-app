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

  // --- LOGIKA HAPUS (IKON MERAH) ---
  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Data?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('ibu_hamil').doc(docId).delete();
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data Terhapus"), backgroundColor: Colors.red),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA DETAIL (IKON KUNING) ---
  void _showDetail(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.family_restroom, size: 60, color: AdminColors.primary),
            const SizedBox(height: 10),
            const Text("Detail Data Ibu Hamil", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminColors.primary)),
            const Divider(height: 40),
            _buildDetailItem("Nama Ibu", data['nama']),
            _buildDetailItem("NIK Ibu", data['nik']),
            _buildDetailItem("Usia Hamil", "${data['usia_kehamilan'] ?? '-'} Minggu"),
            _buildDetailItem("HPL", data['hpl']),
            _buildDetailItem("Tekanan Darah", data['tekanan_darah']),
            _buildDetailItem("Berat Badan", "${data['berat_badan'] ?? '-'} kg"),
            _buildDetailItem("Riwayat", data['riwayat_kesehatan']),
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
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text("$label :", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600))),
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
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const FormIbuHamilPage())),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("TAMBAH DATA IBU HAMIL", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // List Data dengan proteksi error field
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('ibu_hamil').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                // Filter dokumen secara aman
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

                    // Ambil nilai dengan default value untuk mencegah crash
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
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => FormIbuHamilPage(userId: docId, existingData: data))),
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