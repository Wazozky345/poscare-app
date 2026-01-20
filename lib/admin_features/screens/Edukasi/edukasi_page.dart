import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses globalDataEdukasi
import 'form_edukasi_page.dart'; // Form Edukasi

class HalamanEdukasi extends StatefulWidget {
  const HalamanEdukasi({super.key});

  @override
  State<HalamanEdukasi> createState() => _HalamanEdukasiState();
}

class _HalamanEdukasiState extends State<HalamanEdukasi> {
  final TextEditingController _searchCtrl = TextEditingController();

  // --- LOGIC: FILTER SEARCH ---
  List<Map<String, dynamic>> get _filteredData {
    if (_searchCtrl.text.isEmpty) return globalDataEdukasi;
    return globalDataEdukasi
        .where((item) => item['judul']!.toString().toLowerCase().contains(
              _searchCtrl.text.toLowerCase(),
            ))
        .toList();
  }

  // --- LOGIC: NAVIGASI KE FORM ---
  void _navigateToForm({Map<String, dynamic>? dataEdit, int? indexEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormEdukasiPage(dataEdit: dataEdit, indexEdit: indexEdit),
      ),
    );
    if (result == true) setState(() {});
  }

  // --- LOGIC: HAPUS DATA ---
  void _deleteData(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Artikel?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus artikel edukasi ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                globalDataEdukasi.removeAt(index);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Artikel berhasil dihapus"), backgroundColor: Colors.red),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UI UTAMA (THEME NAVY PREMIUM)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,

      // --- APP BAR ---
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
            decoration: BoxDecoration(
              color: AdminColors.primary,
              borderRadius: const BorderRadius.only(
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

          // 2. LIST ARTIKEL (CARD STYLE)
          Expanded(
            child: _filteredData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada artikel edukasi", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      int originalIndex = globalDataEdukasi.indexOf(item);

                      return _buildEdukasiCard(item, originalIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD ARTIKEL ---
  Widget _buildEdukasiCard(Map<String, dynamic> item, int index) {
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
          // Bagian Atas: Placeholder Gambar / Icon
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AdminColors.menuEdukasi.withOpacity(0.1), // Teal Transparan
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Center(
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
                          onTap: () => _navigateToForm(dataEdit: item, indexEdit: index),
                          child: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () => _deleteData(index),
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