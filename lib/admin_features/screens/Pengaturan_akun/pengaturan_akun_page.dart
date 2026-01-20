import 'package:flutter/material.dart';
// Pastikan path admin_colors ini benar
import '../../core/admin_colors.dart'; 
// Pastikan path config ini benar (untuk globalDataAkun)
import 'package:poscare/admin_features/screens/config.dart';
// File form lu tetep dipake
import 'form_pengaturan_akun_page.dart';

class HalamanPengaturanAkun extends StatefulWidget {
  const HalamanPengaturanAkun({super.key});

  @override
  State<HalamanPengaturanAkun> createState() => _HalamanPengaturanAkunState();
}

class _HalamanPengaturanAkunState extends State<HalamanPengaturanAkun> {
  final TextEditingController _searchCtrl = TextEditingController();

  // Logika Filter Search (Tetap dipakai)
  List<Map<String, dynamic>> get _filteredData {
    if (_searchCtrl.text.isEmpty) return globalDataAkun;
    return globalDataAkun
        .where(
          (item) => item['nama']!.toString().toLowerCase().contains(
            _searchCtrl.text.toLowerCase(),
          ),
        )
        .toList();
  }

  // Navigasi ke Form (Tetap dipakai)
  void _navigateToForm({Map<String, dynamic>? dataEdit, int? indexEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormPengaturanAkunPage(dataEdit: dataEdit, indexEdit: indexEdit),
      ),
    );
    if (result == true) setState(() {});
  }

  // Hapus Data
  void _deleteData(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Admin?"),
        content: const Text("Yakin ingin menghapus data admin ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => globalDataAkun.removeAt(index));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text("Data berhasil dihapus")),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background, // Background Abu Lembut
      appBar: AppBar(
        title: const Text(
          "Pengaturan Data Admin", // JUDUL BARU
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AdminColors.primary, // Navy Premium
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      
      // Floating Action Button buat Tambah (Lebih Modern)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AdminColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Admin", style: TextStyle(color: Colors.white)),
      ),

      body: Column(
        children: [
          // --- HEADER: SEARCH BAR ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: "Cari Nama Admin...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- LIST DATA (CARD STYLE) ---
          Expanded(
            child: _filteredData.isEmpty
                ? const Center(
                    child: Text("Data tidak ditemukan.", style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      // Cari index asli biar gak salah hapus kalau lagi di-search
                      int originalIndex = globalDataAkun.indexOf(item);
                      bool isLaki = item['jk'] == 'Laki-laki';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // 1. FOTO PROFIL (AVATAR)
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: isLaki ? Colors.blue.shade50 : Colors.pink.shade50,
                                child: Icon(
                                  isLaki ? Icons.face : Icons.face_3,
                                  color: isLaki ? Colors.blue : Colors.pink,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 15),

                              // 2. INFO TEXT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['nama'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AdminColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['email'] ?? '-',
                                      style: const TextStyle(fontSize: 12, color: AdminColors.textGrey),
                                    ),
                                    const SizedBox(height: 6),
                                    // Badge Gender
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isLaki ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['jk'] ?? '-',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isLaki ? Colors.blue : Colors.pink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 3. ACTION BUTTONS (Edit & Delete)
                              Column(
                                children: [
                                  // Edit Button
                                  InkWell(
                                    onTap: () => _navigateToForm(dataEdit: item, indexEdit: originalIndex),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.edit_rounded, size: 20, color: Colors.orange),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Delete Button
                                  InkWell(
                                    onTap: () => _deleteData(originalIndex),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}