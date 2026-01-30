import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'form_edukasi_page.dart';
import 'dart:convert'; // Import required for base64 decoding

class HalamanEdukasi extends StatefulWidget {
  const HalamanEdukasi({super.key});

  @override
  State<HalamanEdukasi> createState() => _HalamanEdukasiState();
}

class _HalamanEdukasiState extends State<HalamanEdukasi> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchKeyword = "";

  // --- NAVIGASI KE FORM ---
  void _navigateToForm({String? docId, Map<String, dynamic>? data}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormEdukasiPage(
          docId: docId, 
          dataEdit: data,
        ),
      ),
    );
  }

  // --- HAPUS DATA (DIALOG POPUP GANTENG FULL NAVY) ---
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Tong Sampah Biru
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: AdminColors.primary, size: 40),
                ),
                const SizedBox(height: 20),
                
                const Text("Hapus Artikel?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminColors.primary)),
                const SizedBox(height: 10),
                const Text(
                  "Artikel ini akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // Tombol Aksi
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
                            await FirebaseFirestore.instance.collection('edukasi').doc(docId).delete();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Artikel berhasil dihapus"), backgroundColor: AdminColors.primary),
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
        title: const Text("Edukasi Kesehatan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                  onChanged: (v) {
                    setState(() {
                      _searchKeyword = v.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Cari judul artikel...",
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

                // Tombol Tambah
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToForm(),
                    icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                    label: const Text(
                      "BUAT ARTIKEL BARU",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary),
                    ),
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

          // 2. LIST ARTIKEL (STREAM FIRESTORE)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('edukasi')
                  .orderBy('dibuat_pada', descending: true) // Artikel terbaru di atas
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
                        Icon(Icons.article_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada artikel edukasi", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                // Filter Data berdasarkan Search Keyword (Manual di Client Side)
                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String judul = data['judul']?.toString().toLowerCase() ?? "";
                  return judul.contains(_searchKeyword);
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text("Artikel tidak ditemukan", style: TextStyle(color: Colors.grey[500])),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String docId = docs[index].id;

                    return _buildEdukasiCard(docId, data);
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
  Widget _buildEdukasiCard(String docId, Map<String, dynamic> item) {
    String? base64Image = item['gambar_url'];
    bool hasImage = base64Image != null && base64Image.isNotEmpty;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Atas: Gambar (Base64) atau Placeholder
          //  - This corresponds to 'gambar_url' field
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AdminColors.menuEdukasi.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              image: hasImage 
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(base64Image)), 
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage 
                ? null 
                : Center(
                    child: Icon(Icons.image, size: 40, color: AdminColors.menuEdukasi.withOpacity(0.5)),
                  ),
          ),
          
          // Bagian Isi
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['judul'] ?? "Tanpa Judul",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['isi'] ?? "-",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Tombol Aksi Vertical
                    Column(
                      children: [
                        InkWell(
                          onTap: () => _navigateToForm(docId: docId, data: item),
                          child: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () => _deleteData(docId),
                          child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),
                // Footer Card
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 5),
                    const Text("Diposting oleh Admin", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}