import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:poscare/admin_features/screens/config.dart'; // Akses globalDataJadwal
import 'form_jadwal_posyandu_page.dart';

class HalamanJadwalPosyandu extends StatefulWidget {
  const HalamanJadwalPosyandu({super.key});

  @override
  State<HalamanJadwalPosyandu> createState() => _HalamanJadwalPosyanduState();
}

class _HalamanJadwalPosyanduState extends State<HalamanJadwalPosyandu> {
  
  // --- LOGIC: NAVIGASI KE FORM ---
  void _navigateToForm({Map<String, dynamic>? dataEdit, int? indexEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormJadwalPosyanduPage(
          dataEdit: dataEdit,
          indexEdit: indexEdit, // Pake index array biasa
        ),
      ),
    );
    
    // Refresh halaman kalau ada data baru
    if (result == true) {
      setState(() {});
    }
  }

  // --- LOGIC: HAPUS DATA (LOKAL) ---
  void _deleteData(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Jadwal?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Yakin ingin menghapus jadwal ini?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                globalDataJadwal.removeAt(index); // Hapus dari List Dummy
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Jadwal berhasil dihapus"), backgroundColor: Colors.red),
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
        title: const Text("Jadwal Posyandu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // 1. HEADER (TOMBOL TAMBAH)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToForm(),
                icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                label: const Text(
                  "BUAT JADWAL BARU",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),

          // 2. LIST JADWAL (LIST VIEW BIASA)
          Expanded(
            child: globalDataJadwal.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada jadwal posyandu", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: globalDataJadwal.length,
                    itemBuilder: (context, index) {
                      final item = globalDataJadwal[index];
                      // Disini kita pake index sebagai ID sementara
                      return _buildJadwalCard(item, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD JADWAL ---
  Widget _buildJadwalCard(Map<String, dynamic> item, int index) {
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
        child: Row(
          children: [
            // Bagian Kiri (Icon Kalender)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminColors.menuJadwal.withOpacity(0.1), // Ungu Transparan
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_note, color: AdminColors.menuJadwal, size: 30),
            ),
            const SizedBox(width: 15),

            // Bagian Tengah (Info)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['tanggal'] ?? "-",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        "${item['jam_buka']} - ${item['jam_tutup']}",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bagian Kanan (Tombol Aksi)
            Row(
              children: [
                // Edit
                InkWell(
                  onTap: () => _navigateToForm(dataEdit: item, indexEdit: index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                // Hapus
                InkWell(
                  onTap: () => _deleteData(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}