import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:intl/intl.dart'; // Tambahkan package intl di pubspec.yaml untuk format tanggal

class FormIbuHamilPage extends StatefulWidget {
  final String? userId;
  final Map<String, dynamic>? existingData;
  const FormIbuHamilPage({super.key, this.userId, this.existingData});

  @override
  State<FormIbuHamilPage> createState() => _FormIbuHamilPageState();
}

class _FormIbuHamilPageState extends State<FormIbuHamilPage> {
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _usiaController = TextEditingController();
  final _hplController = TextEditingController();
  final _tdController = TextEditingController();
  final _bbController = TextEditingController();
  final _riwayatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _namaController.text = widget.existingData?['nama'] ?? '';
      _nikController.text = widget.existingData?['nik'] ?? '';
      _usiaController.text = widget.existingData?['usia_kehamilan'] ?? '';
      _hplController.text = widget.existingData?['hpl'] ?? '';
      _tdController.text = widget.existingData?['tekanan_darah'] ?? '';
      _bbController.text = widget.existingData?['berat_badan'] ?? '';
      _riwayatController.text = widget.existingData?['riwayat_kesehatan'] ?? '';
    }
  }

  // --- FUNGSI SHOW DATE PICKER ---
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format tanggal menjadi yyyy-MM-dd agar konsisten
        _hplController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveData() async {
    final String id = widget.userId ?? FirebaseFirestore.instance.collection('ibu_hamil').doc().id;
    
    await FirebaseFirestore.instance.collection('ibu_hamil').doc(id).set({
      'nama': _namaController.text,
      'nik': _nikController.text,
      'usia_kehamilan': _usiaController.text,
      'hpl': _hplController.text,
      'tekanan_darah': _tdController.text,
      'berat_badan': _bbController.text,
      'riwayat_kesehatan': _riwayatController.text,
      'last_update': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.userId == null ? "Data Berhasil Disimpan" : "Data Berhasil Diperbarui"))
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary, fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: readOnly ? const Icon(Icons.calendar_today, size: 20, color: AdminColors.primary) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == null ? "Tambah Data Ibu Hamil" : "Edit Data Ibu Hamil", style: const TextStyle(color: Colors.white)),
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AdminColors.primary),
                  SizedBox(width: 10),
                  Expanded(child: Text("Gunakan pemilih tanggal untuk mengisi HPL agar format data tetap seragam.", style: TextStyle(fontSize: 12, color: Colors.black54))),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Center(child: Text("Data Identitas Ibu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("Nama Ibu"), _buildTextField(_namaController, "Nama Lengkap")])),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("NIK Ibu"), _buildTextField(_nikController, "16 Digit NIK")])),
              ],
            ),
            const SizedBox(height: 25),
            const Center(child: Text("Data Kesehatan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("Usia Hamil"), _buildTextField(_usiaController, "Minggu")])),
                const SizedBox(width: 15),
                // --- FIELD HPL DENGAN DATE PICKER ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      _buildInputLabel("HPL"), 
                      _buildTextField(
                        _hplController, 
                        "yyyy-mm-dd",
                        readOnly: true, // Membuat keyboard tidak muncul
                        onTap: () => _selectDate(context), // Memanggil picker
                      )
                    ]
                  )
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("Tekanan Darah"), _buildTextField(_tdController, "120/80")])),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("Berat Badan"), _buildTextField(_bbController, "kg")])),
              ],
            ),
            _buildInputLabel("Riwayat Kesehatan"),
            _buildTextField(_riwayatController, "Catatan...", maxLines: 3),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _saveData,
              child: Text(widget.userId == null ? "SIMPAN DATA" : "UPDATE DATA", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}