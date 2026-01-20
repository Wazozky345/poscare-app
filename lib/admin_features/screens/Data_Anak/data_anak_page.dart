import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // File data dummy (globalDataAnak)
import 'form_data_anak_page.dart'; // Halaman Form

class HalamanDataAnak extends StatefulWidget {
  const HalamanDataAnak({super.key});

  @override
  State<HalamanDataAnak> createState() => _HalamanDataAnakState();
}

class _HalamanDataAnakState extends State<HalamanDataAnak> {
  final TextEditingController _searchCtrl = TextEditingController();

  // --- LOGIC: FILTER SEARCH (TETAP SAMA) ---
  List<Map<String, dynamic>> get _filteredData {
    if (_searchCtrl.text.isEmpty) return globalDataAnak;
    return globalDataAnak
        .where((item) => item['nama'].toString().toLowerCase().contains(
              _searchCtrl.text.toLowerCase(),
            ))
        .toList();
  }

  // --- LOGIC: NAVIGASI KE FORM (TETAP SAMA) ---
  void _navigateToForm({Map<String, dynamic>? dataEdit, int? indexEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDataAnakPage(dataEdit: dataEdit, indexEdit: indexEdit),
      ),
    );

    // Refresh kalau balik dari form
    if (result == true) {
      setState(() {});
    }
  }

  // --- LOGIC: DELETE DATA (TETAP SAMA) ---
  void _deleteData(int originalIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus data ini? Data yang dihapus tidak bisa kembali."),
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
                globalDataAnak.removeAt(originalIndex);
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

  // --- LOGIC: DETAIL POPUP (TAMPILAN DIPERBAGUS DIKIT) ---
  void _showDetailDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            const Icon(Icons.info_outline, size: 50, color: AdminColors.primary),
            const SizedBox(height: 10),
            Text(
              "Detail Data Anak",
              style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _detailRow("NIK", data['nik']),
              _detailRow("Nama", data['nama']),
              _detailRow("JK", data['jk']),
              _detailRow("TTL", "${data['tempat_lahir'] ?? '-'}, ${data['tgl_lahir'] ?? '-'}"),
              _detailRow("Anak Ke", data['anak_ke'] ?? '-'),
              _detailRow("Gol. Darah", data['gol_darah'] ?? '-'),
              _detailRow("No KK", data['no_kk'] ?? '-'),
              _detailRow("Nama Ibu", data['ibu']),
              _detailRow("Nama Ayah", data['nama_ayah'] ?? '-'),
              _detailRow("Alamat", data['alamat'] ?? '-'),
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label :",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 12),
            ),
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
      backgroundColor: AdminColors.background, // Background Abu Bersih
      
      // APP BAR
      appBar: AppBar(
        title: const Text("Data Anak", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                
                // Tombol Tambah Data (Full Width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToForm(),
                    icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                    label: const Text(
                      "TAMBAH DATA ANAK",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Putih biar kontras sama Navy
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
                        Icon(Icons.folder_off, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Data tidak ditemukan", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      // Cari index asli di globalDataAnak buat fungsi Edit/Delete
                      int originalIndex = globalDataAnak.indexOf(item);

                      return _buildAnakCard(item, originalIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KARTU DATA (PENGGANTI TABEL) ---
  Widget _buildAnakCard(Map<String, dynamic> item, int originalIndex) {
    bool isLaki = item['jk'] == 'Laki-laki';

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
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // 1. Avatar Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLaki ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLaki ? Icons.face : Icons.face_3,
                color: isLaki ? Colors.blue : Colors.pink,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),

            // 2. Info Utama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "NIK: ${item['nik']}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    "Ibu: ${item['ibu']}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // 3. Tombol Aksi (Kecil-kecil di kanan)
            Column(
              children: [
                // Tombol Detail (Info)
                InkWell(
                  onTap: () => _showDetailDialog(item),
                  child: const Icon(Icons.info_outline, color: Colors.amber, size: 22),
                ),
                const SizedBox(height: 10),
                // Tombol Edit
                InkWell(
                  onTap: () => _navigateToForm(dataEdit: item, indexEdit: originalIndex),
                  child: const Icon(Icons.edit_note, color: AdminColors.primary, size: 24),
                ),
                 const SizedBox(height: 10),
                // Tombol Hapus
                InkWell(
                  onTap: () => _deleteData(originalIndex),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}