import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses globalDataImunisasi
import 'form_data_imunisasi_page.dart'; // Form Imunisasi

class HalamanDataImunisasi extends StatefulWidget {
  const HalamanDataImunisasi({super.key});

  @override
  State<HalamanDataImunisasi> createState() => _HalamanDataImunisasiState();
}

class _HalamanDataImunisasiState extends State<HalamanDataImunisasi> {
  final TextEditingController _searchCtrl = TextEditingController();

  // --- LOGIC: FILTER SEARCH ---
  List<Map<String, dynamic>> get _filteredData {
    if (_searchCtrl.text.isEmpty) return globalDataImunisasi;
    return globalDataImunisasi
        .where((item) => item['nama_vaksin']!.toString().toLowerCase().contains(
              _searchCtrl.text.toLowerCase(),
            ))
        .toList();
  }

  // --- LOGIC: NAVIGASI KE FORM ---
  void _navigateToForm({Map<String, dynamic>? dataEdit, int? indexEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDataImunisasiPage(dataEdit: dataEdit, indexEdit: indexEdit),
      ),
    );
    // Refresh halaman kalau ada perubahan data
    if (result == true) {
      setState(() {});
    }
  }

  // --- LOGIC: HAPUS DATA ---
  void _deleteData(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Vaksin?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus data vaksin ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              setState(() {
                globalDataImunisasi.removeAt(index);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data vaksin berhasil dihapus"), backgroundColor: Colors.red),
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
      backgroundColor: AdminColors.background, // Abu bersih

      // --- APP BAR ---
      appBar: AppBar(
        title: const Text("Data Imunisasi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary, // Navy
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
                    hintText: "Cari nama vaksin...",
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
                      "TAMBAH VAKSIN BARU",
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

          // 2. LIST DATA (CARD STYLE)
          Expanded(
            child: _filteredData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.vaccines_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada data vaksin", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      // Cari index asli
                      int originalIndex = globalDataImunisasi.indexOf(item);

                      return _buildVaksinCard(item, originalIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD VAKSIN ---
  Widget _buildVaksinCard(Map<String, dynamic> item, int index) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        
        // Ikon Vaksin (Merah biar khas medis)
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AdminColors.menuImunisasi.withOpacity(0.1), // Merah transparan
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.vaccines, color: AdminColors.menuImunisasi, size: 24),
        ),

        // Nama Vaksin
        title: Text(
          item['nama_vaksin'] ?? "Tanpa Nama",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
        ),
        subtitle: const Text(
          "Tersedia untuk Posyandu",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),

        // Tombol Aksi (Edit & Hapus)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToForm(dataEdit: item, indexEdit: index),
              tooltip: "Edit",
            ),
            // Hapus
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteData(index),
              tooltip: "Hapus",
            ),
          ],
        ),
      ),
    );
  }
}