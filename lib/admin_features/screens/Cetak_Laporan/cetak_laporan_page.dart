import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// --- IMPORT WARNA ADMIN ---
import 'package:poscare/admin_features/core/admin_colors.dart';

class HalamanCetakLaporan extends StatefulWidget {
  const HalamanCetakLaporan({super.key});

  @override
  State<HalamanCetakLaporan> createState() => _HalamanCetakLaporanState();
}

class _HalamanCetakLaporanState extends State<HalamanCetakLaporan> {
  String selectedMonth = "Januari";
  final List<String> months = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember",
  ];

  final Map<String, int> monthIndexes = {
    "Januari": 1, "Februari": 2, "Maret": 3, "April": 4, "Mei": 5, "Juni": 6,
    "Juli": 7, "Agustus": 8, "September": 9, "Oktober": 10, "November": 11, "Desember": 12,
  };

  // Helper format tanggal untuk UI & PDF
  String _formatTanggal(dynamic tgl) {
    if (tgl is Timestamp) {
      return DateFormat('dd-MM-yyyy').format(tgl.toDate());
    }
    return tgl?.toString() ?? "-";
  }

  // ==========================================
  // LOGIKA CETAK PDF (STYLE SESUAI CONTOH)
  // ==========================================
  Future<void> _handlePrint(List<QueryDocumentSnapshot> filteredDocs) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Landscape agar muat banyak kolom
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER KOP SURAT (Sesuai image_666b0f.png)
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("PEMERINTAH KOTA BANDUNG", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("DINAS KESEHATAN", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("PUSKESMAS MELATI 1", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Jln. Babakan Sari III Rt 03/Rw 09, Kota Bandung, Kode Pos 17143", style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Divider(thickness: 1.5),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text("LAPORAN BULANAN POSYANDU", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              ),
              pw.SizedBox(height: 15),

              // INFO HEADER TABEL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Posyandu : Bojongloa"),
                      pw.Text("Ketua Kader : ....................."),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Bulan / Tahun : $selectedMonth / ${DateTime.now().year}"),
                      pw.Text("Desa : Babakan Sari III"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // TABEL DATA (Sesuai image_70757f.png)
              pw.Table.fromTextArray(
                headers: ['No', 'Tanggal', 'Nama Anak', 'NIK Anak', 'Umur (Bln)', 'BB (kg)', 'TB (cm)', 'Kondisi'],
                data: List.generate(filteredDocs.length, (index) {
                  final item = filteredDocs[index].data() as Map<String, dynamic>;
                  return [
                    "${index + 1}",
                    _formatTanggal(item['tgl_posyandu']),
                    item['nama_anak'] ?? "-",
                    item['nik_anak'] ?? "-",
                    "${item['umur_bulan'] ?? "-"}",
                    "${item['bb'] ?? "-"}",
                    "${item['tb'] ?? "-"}",
                    item['kondisi'] ?? "-",
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.center,
                border: pw.TableBorder.all(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    int targetMonth = monthIndexes[selectedMonth]!;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text("Cetak Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AdminColors.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Memastikan koleksi sesuai dengan database
        stream: FirebaseFirestore.instance.collection('data_kesehatan_anak').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Filter data berdasarkan bulan dari Timestamp 'tgl_posyandu'
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            dynamic tgl = data['tgl_posyandu'];
            if (tgl is Timestamp) {
              return tgl.toDate().month == targetMonth;
            }
            return false;
          }).toList();

          return Column(
            children: [
              // HEADER UI
              _buildFilterSection(filteredDocs),
              
              const SizedBox(height: 20),

              // PREVIEW LIST
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("Ditemukan ${filteredDocs.length} Data di bulan $selectedMonth", 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ),

              Expanded(
                child: filteredDocs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final item = filteredDocs[index].data() as Map<String, dynamic>;
                          return _buildPreviewCard(item);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(List<QueryDocumentSnapshot> docs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AdminColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,
                isExpanded: true,
                items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => selectedMonth = val!),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: docs.isEmpty ? null : () => _handlePrint(docs),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("CETAK LAPORAN PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AdminColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(item['nama_anak'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("BB: ${item['bb']}kg | TB: ${item['tb']}cm | ${_formatTanggal(item['tgl_posyandu'])}"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: item['kondisi'] == 'Sehat' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(item['kondisi'] ?? "-", style: TextStyle(color: item['kondisi'] == 'Sehat' ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text("Data tidak ditemukan untuk periode ini", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}