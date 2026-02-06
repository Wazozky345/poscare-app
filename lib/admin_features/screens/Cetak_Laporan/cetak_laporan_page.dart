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
  // 0 = Laporan Anak, 1 = Laporan Ibu Hamil
  int _selectedTab = 0; 
  
  String selectedMonth = "Januari";
  final List<String> months = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember",
  ];

  final Map<String, int> monthIndexes = {
    "Januari": 1, "Februari": 2, "Maret": 3, "April": 4, "Mei": 5, "Juni": 6,
    "Juli": 7, "Agustus": 8, "September": 9, "Oktober": 10, "November": 11, "Desember": 12,
  };

  String _formatTanggal(dynamic tgl) {
    if (tgl is Timestamp) {
      return DateFormat('dd-MM-yyyy').format(tgl.toDate());
    }
    return tgl?.toString() ?? "-";
  }

  // ==========================================
  // FUNGSI PRINT DINAMIS (BISA ANAK & IBU)
  // ==========================================
  Future<void> _handlePrint(List<QueryDocumentSnapshot> filteredDocs) async {
    final doc = pw.Document();
    final String currentYear = DateTime.now().year.toString();

    // Tentukan Judul & Nama File berdasarkan Tab yang dipilih
    String reportTitle = _selectedTab == 0 ? "LAPORAN BULANAN POSYANDU (ANAK)" : "LAPORAN BULANAN IBU HAMIL";
    String fileNamePrefix = _selectedTab == 0 ? "Laporan_Anak" : "Laporan_IbuHamil";
    
    final String cleanFileName = "${fileNamePrefix}_${selectedMonth}_$currentYear";

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- KOP SURAT ---
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
                child: pw.Text(reportTitle, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              ),
              pw.SizedBox(height: 15),

              // --- INFO HEADER ---
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
                      pw.Text("Bulan / Tahun : $selectedMonth / $currentYear"),
                      pw.Text("Desa : Babakan Sari III"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // --- TABEL DATA ---
              if (_selectedTab == 0) 
                // TABEL ANAK
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
                )
              else 
                // TABEL IBU HAMIL (FIX: SATUAN BULAN) 🛠️✅
                pw.Table.fromTextArray(
                  headers: ['No', 'Tanggal', 'Nama Ibu', 'NIK', 'Usia Hamil', 'Tensi', 'BB (kg)', 'Kondisi'],
                  data: List.generate(filteredDocs.length, (index) {
                    final item = filteredDocs[index].data() as Map<String, dynamic>;
                    return [
                      "${index + 1}",
                      _formatTanggal(item['tgl_pemeriksaan']), 
                      item['nama'] ?? "-", 
                      item['nik'] ?? "-", 
                      "${item['usia_kehamilan'] ?? "-"} Bulan", // <--- UDAH DIGANTI JADI 'Bulan'
                      item['tekanan_darah'] ?? "-", 
                      "${item['berat_badan'] ?? "-"}", 
                      item['riwayat_kesehatan'] ?? "Sehat", 
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '$cleanFileName.pdf', 
    );
  }

  @override
  Widget build(BuildContext context) {
    int targetMonth = monthIndexes[selectedMonth]!;
    
    String collectionName = _selectedTab == 0 ? 'data_kesehatan_anak' : 'ibu_hamil'; 
    String dateField = _selectedTab == 0 ? 'tgl_posyandu' : 'tgl_pemeriksaan';

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        title: const Text("Cetak Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AdminColors.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // --- HEADER & FILTER ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: const BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // TOMBOL GANTI MODE (TAB)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton("Laporan Anak", 0),
                      _buildTabButton("Laporan Ibu Hamil", 1),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // DROPDOWN BULAN
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
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // --- LIST DATA ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // 1. FILTER BULAN
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  dynamic tgl = data[dateField];
                  if (tgl is Timestamp) {
                    return tgl.toDate().month == targetMonth;
                  }
                  return false;
                }).toList();

                // 2. SORTING ASCENDING (Tanggal 1 - 30)
                filteredDocs.sort((a, b) {
                  var dataA = a.data() as Map<String, dynamic>;
                  var dataB = b.data() as Map<String, dynamic>;
                  
                  dynamic tA = dataA[dateField];
                  dynamic tB = dataB[dateField];

                  DateTime dateA = (tA is Timestamp) ? tA.toDate() : DateTime(3000);
                  DateTime dateB = (tB is Timestamp) ? tB.toDate() : DateTime(3000);
                  
                  return dateA.compareTo(dateB); 
                });

                return Column(
                  children: [
                    // TOMBOL PRINT & JUMLAH DATA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: filteredDocs.isEmpty ? null : () => _handlePrint(filteredDocs),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: Text("CETAK PDF (${_selectedTab == 0 ? 'ANAK' : 'IBU HAMIL'})"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AdminColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("Ditemukan ${filteredDocs.length} Data (Urut Tanggal 1 - Akhir)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    
                    // ISI LIST
                    Expanded(
                      child: filteredDocs.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
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
          ),
        ],
      ),
    );
  }

  // --- WIDGET TOMBOL TAB ---
  Widget _buildTabButton(String label, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? AdminColors.primary : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> item) {
    if (_selectedTab == 0) {
      // MODE ANAK
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.face, color: Colors.white)),
          title: Text(item['nama_anak'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("BB: ${item['bb']}kg | TB: ${item['tb']}cm | ${_formatTanggal(item['tgl_posyandu'])}"),
          trailing: _statusChip(item['kondisi']),
        ),
      );
    } else {
      // MODE IBU HAMIL (PREVIEW JUGA DIGANTI KE 'Bulan') 🛠️✅
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.pinkAccent, child: Icon(Icons.pregnant_woman, color: Colors.white)),
          title: Text(item['nama'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Hamil: ${item['usia_kehamilan']} Bulan | Tensi: ${item['tekanan_darah']} | ${_formatTanggal(item['tgl_pemeriksaan'])}"),
          trailing: const Icon(Icons.print, color: Colors.grey),
        ),
      );
    }
  }

  Widget _statusChip(String? status) {
    bool sehat = status == 'Sehat';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: sehat ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(status ?? "-", style: TextStyle(color: sehat ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_off, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          Text("Tidak ada data di bulan $selectedMonth", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}