import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:poscare/admin_features/screens/config.dart'; // Akses globalDataPosyandu

class HalamanCetakLaporan extends StatefulWidget {
  const HalamanCetakLaporan({super.key});

  @override
  State<HalamanCetakLaporan> createState() => _HalamanCetakLaporanState();
}

class _HalamanCetakLaporanState extends State<HalamanCetakLaporan> {
  // Filter Bulan
  String selectedMonth = "Juni";
  final List<String> months = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember",
  ];

  // Ambil Data Laporan (Dari Data Posyandu)
  List<Map<String, dynamic>> get _laporanData {
    return globalDataPosyandu;
  }

  // ==========================================
  // LOGIKA CETAK PDF (JANGAN DIUBAH SEMBARANGAN)
  // ==========================================
  Future<void> _handlePrint() async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight(); // Font PDF

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // 1. KOP SURAT
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(bottom: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 1)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text("PEMERINTAH KOTA BANDUNG", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("DINAS KESEHATAN", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text("POSYANDU BOJONGLOA", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text("JL. SOEKARNO-HATTA NO.89 CIBADUYUT, KOTA BANDUNG", style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // 2. JUDUL LAPORAN
              pw.Text("LAPORAN BULAN ${selectedMonth.toUpperCase()}", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 15),

              // 3. TABEL DATA (PDF ONLY)
              pw.Table.fromTextArray(
                headers: ['No', 'Nama Anak', 'TB', 'BB', 'Umur', 'Kondisi'],
                data: List.generate(_laporanData.length, (index) {
                  final item = _laporanData[index];
                  return [
                    "${index + 1}",
                    item['nama_anak'],
                    "${item['tb']} cm",
                    "${item['bb']} kg",
                    "${item['umur']} bln",
                    item['kondisi'] ?? "-",
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900), // Header Tabel Navy di PDF
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                },
                border: pw.TableBorder.all(color: PdfColors.grey300),
              ),

              pw.SizedBox(height: 30),

              // 4. TANDA TANGAN
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text("Bandung, ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}"),
                    pw.Text("Ketua Posyandu"),
                    pw.SizedBox(height: 50),
                    pw.Text("_______________________"),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  // ==========================================
  // UI LAYAR HP (THEME NAVY PREMIUM)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,

      // --- APP BAR ---
      appBar: AppBar(
        title: const Text("Cetak Laporan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // 1. HEADER (FILTER & PRINT BUTTON)
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pilih Periode Laporan:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                
                // Dropdown Filter Bulan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      isExpanded: true,
                      icon: const Icon(Icons.calendar_month, color: AdminColors.primary),
                      items: months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month, style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedMonth = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Cetak Besar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _handlePrint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Tombol Putih
                      foregroundColor: AdminColors.primary, // Teks Navy
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.print),
                    label: const Text("CETAK / PREVIEW PDF", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. PREVIEW DATA (LIST CARD)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.visibility, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text("Preview Data (${_laporanData.length} Data)", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // List Data Preview
          Expanded(
            child: _laporanData.isEmpty 
            ? const Center(child: Text("Tidak ada data untuk dicetak"))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _laporanData.length,
                itemBuilder: (context, index) {
                  final item = _laporanData[index];
                  
                  // Format String Vaksin
                  String vaksinText = "-";
                  if (item['vaksin'] is List) {
                    vaksinText = (item['vaksin'] as List).join(", ");
                  } else {
                    vaksinText = item['vaksin'].toString();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama_anak'] ?? "-",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "TB: ${item['tb']} cm | BB: ${item['bb']} kg",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        // Badge Kondisi Kecil
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (item['kondisi'] == 'Sehat') ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            item['kondisi'] ?? "-",
                            style: TextStyle(
                              color: (item['kondisi'] == 'Sehat') ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
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