// FILE: lib/admin_features/screens/Edukasi/form_edukasi_page.dart

import 'dart:convert'; // Buat teknik 69 (Base64)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Wajib ada
import 'package:poscare/admin_features/core/admin_colors.dart';

class FormEdukasiPage extends StatefulWidget {
  final String? docId; 
  final Map<String, dynamic>? dataEdit; 

  const FormEdukasiPage({super.key, this.docId, this.dataEdit});

  @override
  State<FormEdukasiPage> createState() => _FormEdukasiPageState();
}

class _FormEdukasiPageState extends State<FormEdukasiPage> {
  late TextEditingController judulCtl;
  late TextEditingController isiCtl;
  bool _isLoading = false;
  
  // VARIABLE BUAT GAMBAR
  String? _base64Image; 
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    judulCtl = TextEditingController(text: widget.dataEdit?['judul']);
    isiCtl = TextEditingController(text: widget.dataEdit?['isi']);
    
    // Kalau mode Edit, ambil foto lama
    if (widget.dataEdit != null && widget.dataEdit!['gambar_url'] != null) {
      _base64Image = widget.dataEdit!['gambar_url'];
    }
  }

  @override
  void dispose() {
    judulCtl.dispose();
    isiCtl.dispose();
    super.dispose();
  }

  // --- LOGIC PICK IMAGE (TEKNIK 69) ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompres biar database gak meledak
      maxWidth: 800, // Kecilin resolusi
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes); // Jadiin String sakti
      });
    }
  }

  // --- LOGIC SIMPAN KE FIRESTORE ---
  Future<void> _saveToFirestore() async {
    if (judulCtl.text.isEmpty || isiCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Isi tidak boleh kosong!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'judul': judulCtl.text,
        'isi': isiCtl.text,
        'gambar_url': _base64Image ?? '', // Simpan string base64
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.docId == null) {
        // TAMBAH BARU
        data['dibuat_pada'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('edukasi').add(data);
      } else {
        // UPDATE
        await FirebaseFirestore.instance.collection('edukasi').doc(widget.docId).update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Artikel Berhasil Disimpan"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.docId == null ? "Tambah Edukasi" : "Edit Edukasi",
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
                  const Icon(Icons.lightbulb_outline, color: AdminColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Bagikan informasi kesehatan yang bermanfaat untuk ibu dan anak.",
                      style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Input Judul
            _buildLabelInput("Judul Artikel", 
              _buildTextField(controller: judulCtl, hint: "Contoh: Pentingnya Imunisasi Campak")
            ),
            const SizedBox(height: 20),

            // Input Isi
            _buildLabelInput("Isi Artikel", 
              _buildTextArea(controller: isiCtl, hint: "Tulis isi materi edukasi secara lengkap di sini...")
            ),
            
            const SizedBox(height: 20),
            
            // --- AREA UPLOAD FOTO (Bisa Diklik) ---
            const Text("Foto Cover", style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            
            InkWell(
              onTap: _pickImage, // Klik buat ambil gambar
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(10),
                  image: _base64Image != null && _base64Image!.isNotEmpty
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_base64Image!)), // Decode String sakti
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _base64Image != null && _base64Image!.isNotEmpty
                    ? null // Kalau ada gambar, icon ilang
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text("Klik untuk Upload Foto", style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
              ),
            ),
            // Tombol Hapus Foto (Optional, muncul kalo ada foto)
            if (_base64Image != null && _base64Image!.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _base64Image = ''),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  label: const Text("Hapus Foto", style: TextStyle(color: Colors.red)),
                ),
              ),

            const SizedBox(height: 40),

            // TOMBOL AKSI
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      onPressed: _isLoading ? null : _saveToFirestore,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SIMPAN ARTIKEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("BATAL", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
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

  // --- WIDGET HELPER ---
  Widget _buildLabelInput(String label, Widget inputWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        inputWidget,
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildTextArea({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      maxLines: 8,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}