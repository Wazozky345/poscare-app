import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses ke globalDataAnak

class FormDataAnakPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit; // Data jika mode edit
  final int? indexEdit; // Index array jika mode edit

  const FormDataAnakPage({super.key, this.dataEdit, this.indexEdit});

  @override
  State<FormDataAnakPage> createState() => _FormDataAnakPageState();
}

class _FormDataAnakPageState extends State<FormDataAnakPage> {
  // Controllers
  late TextEditingController nikCtl;
  late TextEditingController namaCtl;
  late TextEditingController tempatLahirCtl;
  late TextEditingController tglLahirCtl;
  late TextEditingController anakKeCtl;
  late TextEditingController ibuCtl;

  // Dropdown Values
  late String selectedJk;
  late String selectedGolDarah;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data (jika edit, ambil data lama. jika baru, kosongkan)
    nikCtl = TextEditingController(text: widget.dataEdit?['nik']);
    namaCtl = TextEditingController(text: widget.dataEdit?['nama']);
    tempatLahirCtl = TextEditingController(text: widget.dataEdit?['tempat_lahir']);
    tglLahirCtl = TextEditingController(text: widget.dataEdit?['tgl_lahir']);
    anakKeCtl = TextEditingController(text: widget.dataEdit?['anak_ke']);
    ibuCtl = TextEditingController(text: widget.dataEdit?['ibu']);

    selectedJk = widget.dataEdit?['jk'] ?? 'Laki-laki';
    selectedGolDarah = widget.dataEdit?['gol_darah'] ?? 'A';
  }

  @override
  void dispose() {
    nikCtl.dispose();
    namaCtl.dispose();
    tempatLahirCtl.dispose();
    tglLahirCtl.dispose();
    anakKeCtl.dispose();
    ibuCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Canvas putih bersih
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: AdminColors.primary, // Navy
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.dataEdit == null ? "Tambah Data Anak" : "Edit Data Anak",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),

      // --- BODY FORM ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Kecil
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AdminColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Silahkan lengkapi data anak dengan benar.",
                      style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ROW 1: NIK & NAMA
            _buildTwoColumnRow(
              _buildLabelInput("NIK Anak", _buildTextField(controller: nikCtl, hint: "16 digit NIK", isNumber: true)),
              _buildLabelInput("Nama Anak", _buildTextField(controller: namaCtl, hint: "Nama Lengkap")),
            ),
            const SizedBox(height: 20),

            // ROW 2: TEMPAT & TANGGAL LAHIR
            _buildTwoColumnRow(
              _buildLabelInput(
                "Tempat Lahir",
                _buildTextField(controller: tempatLahirCtl, hint: "Kota Lahir"),
              ),
              _buildLabelInput(
                "Tanggal Lahir",
                _buildDatePickerField(), // Custom Date Picker Field
              ),
            ),
            const SizedBox(height: 20),

            // ROW 3: ANAK KE & GOL DARAH
            _buildTwoColumnRow(
              _buildLabelInput("Anak Ke-", _buildTextField(controller: anakKeCtl, hint: "1, 2, dst", isNumber: true)),
              _buildLabelInput(
                "Gol. Darah",
                _buildDropdownField(
                  value: selectedGolDarah,
                  items: ['A', 'B', 'AB', 'O'],
                  onChanged: (v) => setState(() => selectedGolDarah = v!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ROW 4: JK & NAMA IBU
            _buildTwoColumnRow(
              _buildLabelInput(
                "Jenis Kelamin",
                _buildDropdownField(
                  value: selectedJk,
                  items: ['Laki-laki', 'Perempuan'],
                  onChanged: (v) => setState(() => selectedJk = v!),
                ),
              ),
              _buildLabelInput(
                "Nama Ibu",
                _buildTextField(
                  controller: ibuCtl, 
                  hint: "Nama Ibu Kandung",
                  suffixIcon: Icons.search, // Icon search kecil
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL AKSI
            Row(
              children: [
                // TOMBOL SIMPAN (NAVY)
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
                        "SIMPAN DATA",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // TOMBOL BATAL (OUTLINED)
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

  // --- LOGIC SIMPAN (TETAP SAMA) ---
  void _handleSave() {
    if (nikCtl.text.isEmpty || namaCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi data NIK dan Nama"), backgroundColor: Colors.red),
      );
      return;
    }

    final newData = {
      'nik': nikCtl.text,
      'nama': namaCtl.text,
      'jk': selectedJk,
      'ibu': ibuCtl.text,
      'tempat_lahir': tempatLahirCtl.text,
      'tgl_lahir': tglLahirCtl.text,
      'anak_ke': anakKeCtl.text,
      'gol_darah': selectedGolDarah,
      // Default data pelengkap
      'no_kk': widget.dataEdit?['no_kk'] ?? '-',
      'nama_ayah': widget.dataEdit?['nama_ayah'] ?? '-',
      'alamat': widget.dataEdit?['alamat'] ?? 'Alamat Baru',
    };

    // Update Global Variable langsung
    if (widget.dataEdit == null) {
      // Tambah Data Baru
      globalDataAnak.add(newData);
    } else {
      // Edit Data Lama
      if (widget.indexEdit != null) {
        globalDataAnak[widget.indexEdit!] = newData;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data Berhasil Disimpan"), backgroundColor: AdminColors.menuOrtu), // Hijau
    );
    Navigator.pop(context, true); // Kembali dengan sinyal sukses
  }

  // ===============================================
  // WIDGET HELPER (STYLING MODERN)
  // ===============================================

  // 1. Label Input
  Widget _buildLabelInput(String label, Widget inputWidget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AdminColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        inputWidget,
      ],
    );
  }

  // 2. Text Field Estetik
  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    bool isNumber = false,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AdminColors.primary, size: 20) : null,
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
      ),
    );
  }

  // 3. Dropdown Estetik
  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: AdminColors.primary),
      decoration: InputDecoration(
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
      ),
    );
  }

  // 4. Date Picker Field
  Widget _buildDatePickerField() {
    return TextField(
      controller: tglLahirCtl,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "hh-bb-tttt",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AdminColors.primary), // Icon Navy
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
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            // Custom Warna Date Picker biar Navy juga
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AdminColors.primary, // Header Navy
                  onPrimary: Colors.white, 
                  onSurface: AdminColors.textDark, 
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            tglLahirCtl.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
          });
        }
      },
    );
  }

  // 5. Layout Helper (2 Kolom)
  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Biar sejajar atas kalo tinggi beda
      children: [
        Expanded(child: left),
        const SizedBox(width: 15),
        Expanded(child: right),
      ],
    );
  }
}