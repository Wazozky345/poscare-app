import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses globalDataOrangTua

class FormDataOrangTuaPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit;
  final int? indexEdit;

  const FormDataOrangTuaPage({super.key, this.dataEdit, this.indexEdit});

  @override
  State<FormDataOrangTuaPage> createState() => _FormDataOrangTuaPageState();
}

class _FormDataOrangTuaPageState extends State<FormDataOrangTuaPage> {
  // Controllers
  late TextEditingController noKkCtl;
  late TextEditingController nikIbuCtl;
  late TextEditingController namaIbuCtl;
  late TextEditingController tempatLahirIbuCtl;
  late TextEditingController tglLahirIbuCtl;
  late TextEditingController nikAyahCtl;
  late TextEditingController namaAyahCtl;
  late TextEditingController alamatCtl;
  late TextEditingController teleponCtl;

  late String selectedGolDarahIbu;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Data
    noKkCtl = TextEditingController(text: widget.dataEdit?['no_kk']);
    nikIbuCtl = TextEditingController(text: widget.dataEdit?['nik_ibu']);
    namaIbuCtl = TextEditingController(text: widget.dataEdit?['nama_ibu']);
    tempatLahirIbuCtl = TextEditingController(text: widget.dataEdit?['tempat_lahir_ibu']);
    tglLahirIbuCtl = TextEditingController(text: widget.dataEdit?['tgl_lahir_ibu']);
    nikAyahCtl = TextEditingController(text: widget.dataEdit?['nik_ayah']);
    namaAyahCtl = TextEditingController(text: widget.dataEdit?['nama_ayah']);
    alamatCtl = TextEditingController(text: widget.dataEdit?['alamat']);
    teleponCtl = TextEditingController(text: widget.dataEdit?['telepon']);

    selectedGolDarahIbu = widget.dataEdit?['gol_darah_ibu'] ?? 'A';
  }

  @override
  void dispose() {
    noKkCtl.dispose();
    nikIbuCtl.dispose();
    namaIbuCtl.dispose();
    tempatLahirIbuCtl.dispose();
    tglLahirIbuCtl.dispose();
    nikAyahCtl.dispose();
    namaAyahCtl.dispose();
    alamatCtl.dispose();
    teleponCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- APP BAR ---
      appBar: AppBar(
        title: Text(
          widget.dataEdit == null ? "Tambah Data Orang Tua" : "Edit Data Orang Tua",
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
          children: [
            // HEADER INFO
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.family_restroom, color: AdminColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Pastikan NIK dan Nomor KK sesuai dengan Kartu Keluarga asli.",
                      style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // SECTION 1: DATA IBU
            _sectionTitle("Data Ibu"),
            const SizedBox(height: 15),
            _buildTwoColumnRow(
              _buildLabelInput("NO KK", _buildTextField(controller: noKkCtl, hint: "16 Digit No. KK", isNumber: true)),
              _buildLabelInput("NIK Ibu", _buildTextField(controller: nikIbuCtl, hint: "16 Digit NIK", isNumber: true)),
            ),
            const SizedBox(height: 15),
            _buildTwoColumnRow(
              _buildLabelInput("Nama Ibu", _buildTextField(controller: namaIbuCtl, hint: "Nama Lengkap Ibu")),
              _buildLabelInput(
                "Gol. Darah Ibu",
                _buildDropdownField(
                  value: selectedGolDarahIbu,
                  items: ['A', 'B', 'AB', 'O'],
                  onChanged: (v) => setState(() => selectedGolDarahIbu = v!),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildTwoColumnRow(
              _buildLabelInput("Tempat Lahir", _buildTextField(controller: tempatLahirIbuCtl, hint: "Kota Lahir")),
              _buildLabelInput("Tanggal Lahir", _buildDatePickerField()),
            ),
            
            const SizedBox(height: 25),
            const Divider(),
            
            // SECTION 2: DATA AYAH & KONTAK
            const SizedBox(height: 15),
            _sectionTitle("Data Ayah & Kontak"),
            const SizedBox(height: 15),
            _buildTwoColumnRow(
              _buildLabelInput("NIK Ayah", _buildTextField(controller: nikAyahCtl, hint: "16 Digit NIK", isNumber: true)),
              _buildLabelInput("Nama Ayah", _buildTextField(controller: namaAyahCtl, hint: "Nama Lengkap Ayah")),
            ),
            const SizedBox(height: 15),
            _buildTwoColumnRow(
              _buildLabelInput("No Telepon", _buildTextField(controller: teleponCtl, hint: "08xx-xxxx-xxxx", isNumber: true)),
              Container(), // Spacer kosong biar layout tetep 2 kolom
            ),
            const SizedBox(height: 15),
            _buildLabelInput("Alamat Lengkap", _buildTextField(controller: alamatCtl, hint: "Jalan, RT/RW, Desa...")),

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
                      child: const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    if (noKkCtl.text.isEmpty || namaIbuCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data wajib (NO KK, Nama Ibu)!"), backgroundColor: Colors.red),
      );
      return;
    }

    final newData = {
      'no_kk': noKkCtl.text,
      'nik_ibu': nikIbuCtl.text,
      'nama_ibu': namaIbuCtl.text,
      'tempat_lahir_ibu': tempatLahirIbuCtl.text,
      'tgl_lahir_ibu': tglLahirIbuCtl.text,
      'gol_darah_ibu': selectedGolDarahIbu,
      'nik_ayah': nikAyahCtl.text,
      'nama_ayah': namaAyahCtl.text,
      'alamat': alamatCtl.text,
      'telepon': teleponCtl.text,
    };

    setState(() {
      if (widget.dataEdit == null) {
        globalDataOrangTua.add(newData);
      } else {
        if (widget.indexEdit != null) {
          globalDataOrangTua[widget.indexEdit!] = newData;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data Berhasil Disimpan"), backgroundColor: AdminColors.menuOrtu), // Hijau
    );
    Navigator.pop(context, true);
  }

  // ===============================================
  // WIDGET HELPER (STYLING MODERN)
  // ===============================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16, 
        fontWeight: FontWeight.bold, 
        color: AdminColors.textDark,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildLabelInput(String label, Widget inputWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        inputWidget,
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  Widget _buildDropdownField({required String value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: AdminColors.primary),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return TextField(
      controller: tglLahirIbuCtl,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "hh/bb/tttt",
        suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AdminColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AdminColors.primary, onPrimary: Colors.white, onSurface: AdminColors.textDark),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            tglLahirIbuCtl.text = "${picked.day}/${picked.month}/${picked.year}";
          });
        }
      },
    );
  }

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 15),
        Expanded(child: right),
      ],
    );
  }
}