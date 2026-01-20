import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses globalDataPosyandu
import 'form_data_posyandu_page.dart'; // Form Posyandu

class HalamanDataPosyandu extends StatefulWidget {
  const HalamanDataPosyandu({super.key});

  @override
  State<HalamanDataPosyandu> createState() => _HalamanDataPosyanduState();
}

class _HalamanDataPosyanduState extends State<HalamanDataPosyandu> {
  final TextEditingController _searchCtrl = TextEditingController();

  // --- LOGIC: FILTER SEARCH ---
  List<Map<String, dynamic>> get _filteredData {
    if (_searchCtrl.text.isEmpty) return globalDataPosyandu;
    return globalDataPosyandu
        .where((item) => item['nama_anak']!.toString().toLowerCase().contains(
              _searchCtrl.text.toLowerCase(),
            ))
        .toList();
  }

  // --- LOGIC: NAVIGASI KE FORM ---
  void _navigateToForm(String title, {Map<String, dynamic>? dataEdit, int? indexEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDataPosyanduPage(
          title: title,
          dataEdit: dataEdit,
          indexEdit: indexEdit,
        ),
      ),
    );
    if (result == true) setState(() {});
  }

  // --- LOGIC: HAPUS DATA ---
  void _deleteData(int originalIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus data posyandu ini?"),
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
                globalDataPosyandu.removeAt(originalIndex);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: Colors.red),
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
                
                // Row Tombol (Tambah & Data Terlambat)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToForm("Tambah Data Posyandu"),
                        icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                        label: const Text("DATA BARU", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToForm("Data Terlambat Imunisasi"),
                        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                        label: const Text("TERLAMBAT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
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
                        Icon(Icons.monitor_weight_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada data pemeriksaan", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      int originalIndex = globalDataPosyandu.indexOf(item);

                      return _buildPosyanduCard(item, originalIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD ---
  Widget _buildPosyanduCard(Map<String, dynamic> item, int index) {
    // Parsing Vaksin
    String vaksinText = "-";
    if (item['vaksin'] is List) {
      vaksinText = (item['vaksin'] as List).join(", ");
    } else if (item['vaksin'] is String) {
      vaksinText = item['vaksin'];
    }

    // Warna Badge Kondisi
    Color kondisiColor = Colors.green;
    if (item['kondisi'] == 'Stunting' || item['kondisi'] == 'Kurang Gizi') {
      kondisiColor = Colors.red;
    } else if (item['kondisi'] == 'Perlu Pantauan') {
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
                Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama_anak'] ?? "Tanpa Nama",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
                        ),
                        Text(
                          "${item['umur']} Bulan",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
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
                    item['kondisi'] ?? "-",
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
                _buildInfoColumn("Tinggi Badan", "${item['tb']} cm"),
                _buildInfoColumn("Berat Badan", "${item['bb']} kg"),
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
                      item['tgl_posyandu'] ?? "-",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Edit
                    InkWell(
                      onTap: () => _navigateToForm("Edit Data Posyandu", dataEdit: item, indexEdit: index),
                      child: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                    ),
                    const SizedBox(width: 15),
                    // Hapus
                    InkWell(
                      onTap: () => _deleteData(index),
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