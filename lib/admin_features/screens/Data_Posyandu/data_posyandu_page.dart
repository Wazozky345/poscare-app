import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:intl/intl.dart';
import 'form_data_posyandu_page.dart';

class HalamanDataPosyandu extends StatefulWidget {
  const HalamanDataPosyandu({super.key});

  @override
  State<HalamanDataPosyandu> createState() => _HalamanDataPosyanduState();
}

class _HalamanDataPosyanduState extends State<HalamanDataPosyandu> {
  final TextEditingController _searchCtrl = TextEditingController();
  final CollectionReference _healthRef = FirebaseFirestore.instance.collection('data_kesehatan_anak');

  // --- LOGIC: NAVIGASI KE FORM ---
  void _navigateToForm(String title, {Map<String, dynamic>? dataEdit, String? docId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDataPosyanduPage(
          title: title,
          dataEdit: dataEdit,
          docId: docId, 
        ),
      ),
    );
  }

  // --- LOGIC: HAPUS DATA (BIRU ADMIN) ---
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
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withOpacity(0.1), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: AdminColors.primary, size: 40),
                ),
                const SizedBox(height: 20),
                const Text("Hapus Data?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminColors.primary)),
                const SizedBox(height: 10),
                const Text("Yakin ingin menghapus data pemeriksaan ini? Data yang dihapus tidak bisa kembali.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 25),
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
                            await _healthRef.doc(docId).delete();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: AdminColors.primary));
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red));
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

  // --- HELPER: FORMAT TANGGAL ---
  DateTime _parseDateSafe(dynamic value) {
    if (value == null) return DateTime(1900);
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try { return DateFormat('dd-MM-yyyy').parse(value); } catch (_) {}
      try { return DateTime.parse(value); } catch (_) {}
    }
    return DateTime(1900);
  }

  String _formatDisplayDate(dynamic value) {
    DateTime date = _parseDateSafe(value);
    if (date.year == 1900) return "-";
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text("Data Posyandu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // HEADER
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
                    hintText: "Cari nama anak...",
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
                    onPressed: () => _navigateToForm("Tambah Data Posyandu"),
                    icon: const Icon(Icons.add_circle_outline, color: AdminColors.primary),
                    label: const Text("INPUT DATA BARU", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
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

          // LIST DATA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _healthRef.snapshots(), 
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Terjadi kesalahan"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // 1. FILTER SEARCH
                docs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nama = (data['nama_anak'] ?? '').toString().toLowerCase();
                  return nama.contains(_searchCtrl.text.toLowerCase());
                }).toList();

                // 2. SORTING BERDASARKAN "WAKTU INPUT" (updated_at) 🏆
                // Biar data yang baru diinput admin langsung nongol paling atas
                docs.sort((a, b) {
                  var dataA = a.data() as Map<String, dynamic>;
                  var dataB = b.data() as Map<String, dynamic>;
                  
                  // Ambil field 'updated_at' (Sesuai Screenshot Database Abang)
                  dynamic timeA = dataA['updated_at'];
                  dynamic timeB = dataB['updated_at'];

                  // Kalo datanya kosong (data lama), kasih tanggal jadul biar di bawah
                  DateTime dtA = (timeA is Timestamp) ? timeA.toDate() : DateTime(2000);
                  DateTime dtB = (timeB is Timestamp) ? timeB.toDate() : DateTime(2000);

                  // Descending (Terbaru di Atas)
                  return dtB.compareTo(dtA); 
                });

                if (docs.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.monitor_weight_outlined, size: 80, color: Colors.grey[300]), const SizedBox(height: 10), Text("Belum ada data pemeriksaan", style: TextStyle(color: Colors.grey[500]))]));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    return _buildPosyanduCard(data, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosyanduCard(Map<String, dynamic> item, String docId) {
    String vaksinText = "-";
    if (item['vaksin'] is List) {
      List vaksins = item['vaksin'];
      if (vaksins.isEmpty || (vaksins.length == 1 && vaksins[0] == '-')) {
        vaksinText = "-";
      } else {
        vaksinText = vaksins.join(", ");
      }
    }

    String kondisi = item['kondisi'] ?? 'Sehat';
    Color kondisiColor = Colors.green;
    if (kondisi == 'Stunting' || kondisi == 'Kurang Gizi') kondisiColor = Colors.red;
    else if (kondisi == 'Sakit' || kondisi == 'Perlu Pantauan') kondisiColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AdminColors.menuPosyandu.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.child_care, color: AdminColors.menuPosyandu, size: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item['nama_anak'] ?? "Tanpa Nama", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("${item['umur_bulan'] ?? 0} Bulan", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ]),
                      ),
                    ],
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: kondisiColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: kondisiColor)), child: Text(kondisi, style: TextStyle(color: kondisiColor, fontWeight: FontWeight.bold, fontSize: 11))),
              ],
            ),
            const Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _buildInfoColumn("Tinggi Badan", "${item['tb'] ?? 0} cm"),
                _buildInfoColumn("Berat Badan", "${item['bb'] ?? 0} kg"),
                _buildInfoColumn("Vaksin", vaksinText, isLongText: true),
            ]),
            const Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(_formatDisplayDate(item['tgl_posyandu']), style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                Row(children: [
                    InkWell(onTap: () => _navigateToForm("Edit Data Posyandu", dataEdit: item, docId: docId), child: const Icon(Icons.edit_note, color: Colors.blue, size: 24)),
                    const SizedBox(width: 15),
                    InkWell(onTap: () => _deleteData(docId), child: const Icon(Icons.delete_outline, color: Colors.red, size: 22)),
                ]),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isLongText = false}) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isLongText ? AdminColors.primary : Colors.black87)),
      ]),
    );
  }
}