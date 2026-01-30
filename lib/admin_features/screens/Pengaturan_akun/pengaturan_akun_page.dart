// FILE: lib/admin_features/screens/Pengaturan_akun/pengaturan_akun_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:intl/intl.dart'; 

class HalamanPengaturanAkun extends StatefulWidget {
  const HalamanPengaturanAkun({super.key});

  @override
  State<HalamanPengaturanAkun> createState() => _HalamanPengaturanAkunState();
}

class _HalamanPengaturanAkunState extends State<HalamanPengaturanAkun> {
  final TextEditingController _searchCtrl = TextEditingController();

  // --- POPUP DETAIL ADMIN ---
  void _showDetailAdmin(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: AdminColors.primary, 
              child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(data['nama'] ?? "Admin", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("Administrator", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            _detailRow(Icons.email, "Email", data['email']),
            _detailRow(Icons.phone, "No. HP", data['noHp'] ?? data['telepon'] ?? '-'),
            _detailRow(Icons.wc, "Jenis Kelamin", data['jk'] ?? '-'), // Tambah JK sesuai screenshot
            _detailRow(Icons.calendar_today, "Bergabung", _formatDate(data['createdAt'])),
            const Divider(),
          ],
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

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    try {
      if (timestamp is Timestamp) {
        DateTime date = timestamp.toDate();
        return DateFormat('dd MMM yyyy').format(date);
      }
    } catch (e) {
      return "-";
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        title: const Text(
          "Data Admin Terdaftar", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AdminColors.primary, 
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      
      body: Column(
        children: [
          // --- HEADER: SEARCH BAR ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: const BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: "Cari nama admin...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- LIST DATA (STREAM BUILDER) ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // PERBAIKAN DISINI BANG: Ganti 'users' jadi 'admins'
              stream: FirebaseFirestore.instance
                  .collection('admins') // Sesuai nama collection di screenshot lu
                  .snapshots(),
              
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                var docs = snapshot.data?.docs ?? [];

                // Filter Pencarian Lokal
                if (_searchCtrl.text.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return (data['nama'] ?? '').toString().toLowerCase().contains(_searchCtrl.text.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.admin_panel_settings_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Belum ada admin lain terdaftar.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    bool isLaki = (data['jk'] ?? '') == 'Laki-laki';
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: isLaki ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                          child: Icon(
                            isLaki ? Icons.face : Icons.face_3, 
                            color: isLaki ? Colors.blue : Colors.pink
                          ),
                        ),
                        title: Text(
                          data['nama'] ?? "Tanpa Nama",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(data['email'] ?? "-", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 2),
                            // Badge Role
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.green.shade200, width: 0.5),
                              ),
                              child: const Text("Admin", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        trailing: InkWell(
                          onTap: () => _showDetailAdmin(data),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.info_outline, size: 22, color: Colors.blue),
                          ),
                        ),
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