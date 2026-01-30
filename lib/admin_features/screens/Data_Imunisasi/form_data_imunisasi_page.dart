// FILE: lib/admin_features/screens/Data_Imunisasi/form_data_imunisasi_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';

class FormDataImunisasiPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit;
  final String? docId; // Ganti indexEdit dengan docId

  const FormDataImunisasiPage({super.key, this.dataEdit, this.docId});

  @override
  State<FormDataImunisasiPage> createState() => _FormDataImunisasiPageState();
}

class _FormDataImunisasiPageState extends State<FormDataImunisasiPage> {
  late TextEditingController namaVaksinCtl;
  bool _isLoading = false; // Loading state

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

  // --- LOGIC SIMPAN KE FIREBASE ---
  Future<void> _handleSave() async {
    if (namaVaksinCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama Vaksin tidak boleh kosong!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai loading

    try {
      final collection = FirebaseFirestore.instance.collection('jenis_vaksin');
      final data = {
        'nama_vaksin': namaVaksinCtl.text,
        'updated_at': FieldValue.serverTimestamp(), // Biar tau kapan diupdate
      };

      if (widget.docId == null) {
        // Mode Tambah
        await collection.add(data);
      } else {
        // Mode Edit
        await collection.doc(widget.docId).update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data Berhasil Disimpan"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // Stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.docId == null ? "Tambah Data Imunisasi" : "Edit Data Imunisasi",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
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
                      onPressed: _isLoading ? null : _handleSave, // Disable kalau loading
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
}