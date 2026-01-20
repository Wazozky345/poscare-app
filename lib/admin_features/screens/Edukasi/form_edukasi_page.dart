import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses globalDataEdukasi

class FormEdukasiPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit;
  final int? indexEdit;

  const FormEdukasiPage({super.key, this.dataEdit, this.indexEdit});

  @override
  State<FormEdukasiPage> createState() => _FormEdukasiPageState();
}

class _FormEdukasiPageState extends State<FormEdukasiPage> {
  late TextEditingController judulCtl;
  late TextEditingController isiCtl;

  @override
  void initState() {
    super.initState();
    judulCtl = TextEditingController(text: widget.dataEdit?['judul']);
    isiCtl = TextEditingController(text: widget.dataEdit?['isi']);
  }

  @override
  void dispose() {
    judulCtl.dispose();
    isiCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- APP BAR ---
      appBar: AppBar(
        title: Text(
          widget.dataEdit == null ? "Tambah Edukasi" : "Edit Edukasi",
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

            // Input Isi (TextArea)
            _buildLabelInput("Isi Artikel", 
              _buildTextArea(controller: isiCtl, hint: "Tulis isi materi edukasi secara lengkap di sini...")
            ),
            
            const SizedBox(height: 15),
            // Placeholder Tombol Upload Foto (Visual Only)
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text("Upload Foto Cover (Opsional)", style: TextStyle(color: Colors.grey.shade500)),
                ],
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
                      onPressed: _handleSave,
                      child: const Text("SIMPAN ARTIKEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // --- LOGIC SIMPAN ---
  void _handleSave() {
    if (judulCtl.text.isEmpty || isiCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Isi tidak boleh kosong!"), backgroundColor: Colors.red),
      );
      return;
    }

    final newData = {
      'judul': judulCtl.text,
      'isi': isiCtl.text,
      'foto': '', 
    };

    setState(() {
      if (widget.dataEdit == null) {
        // Mode Tambah
        globalDataEdukasi.add(newData);
      } else {
        // Mode Edit
        if (widget.indexEdit != null) {
          globalDataEdukasi[widget.indexEdit!] = newData;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Artikel Berhasil Disimpan"), backgroundColor: AdminColors.menuOrtu), // Hijau
    );
    Navigator.pop(context, true);
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
      maxLines: 8, // Area lebih besar buat nulis artikel
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