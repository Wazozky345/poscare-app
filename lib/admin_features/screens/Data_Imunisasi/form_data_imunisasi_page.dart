import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses globalDataImunisasi

class FormDataImunisasiPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit;
  final int? indexEdit;

  const FormDataImunisasiPage({super.key, this.dataEdit, this.indexEdit});

  @override
  State<FormDataImunisasiPage> createState() => _FormDataImunisasiPageState();
}

class _FormDataImunisasiPageState extends State<FormDataImunisasiPage> {
  late TextEditingController namaVaksinCtl;

  @override
  void initState() {
    super.initState();
    namaVaksinCtl = TextEditingController(
      text: widget.dataEdit?['nama_vaksin'],
    );
  }

  @override
  void dispose() {
    namaVaksinCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- APP BAR ---
      appBar: AppBar(
        title: Text(
          widget.dataEdit == null ? "Tambah Data Imunisasi" : "Edit Data Imunisasi",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      // --- BODY FORM ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.vaccines, color: AdminColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Masukkan nama vaksin baru yang tersedia di Posyandu.",
                      style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input Nama Vaksin
            const Text(
              "Nama Vaksin",
              style: TextStyle(
                color: AdminColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaVaksinCtl,
              decoration: InputDecoration(
                hintText: "Contoh: Polio, Campak, BCG...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: const Icon(Icons.medication, color: AdminColors.primary),
              ),
            ),

            const SizedBox(height: 40),

            // Tombol Aksi
            Row(
              children: [
                // TOMBOL SIMPAN
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      onPressed: _handleSave,
                      child: const Text(
                        "SIMPAN",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // TOMBOL BATAL
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "BATAL",
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (namaVaksinCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama Vaksin tidak boleh kosong!"), backgroundColor: Colors.red),
      );
      return;
    }

    final newData = {'nama_vaksin': namaVaksinCtl.text};

    setState(() {
      if (widget.dataEdit == null) {
        // Mode Tambah
        globalDataImunisasi.add(newData);
      } else {
        // Mode Edit
        if (widget.indexEdit != null) {
          globalDataImunisasi[widget.indexEdit!] = newData;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data Berhasil Disimpan"), backgroundColor: AdminColors.menuOrtu), // Hijau
    );
    Navigator.pop(context, true);
  }
}