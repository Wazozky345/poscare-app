import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. IMPORT FIRESTORE
import 'package:poscare/admin_features/core/admin_colors.dart';

class FormDataAnakPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit; 
  final String? docId; // 2. UBAH DARI int index KE String docId

  const FormDataAnakPage({super.key, this.dataEdit, this.docId});

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
  
  bool _isLoading = false; // 3. LOADING STATE UNTUK PROSES FIREBASE

  @override
  void initState() {
    super.initState();
    nikCtl = TextEditingController(text: widget.dataEdit?['nik']);
    namaCtl = TextEditingController(text: widget.dataEdit?['nama']);
    tempatLahirCtl = TextEditingController(text: widget.dataEdit?['tempat_lahir']);
    tglLahirCtl = TextEditingController(text: widget.dataEdit?['tgl_lahir']);
    anakKeCtl = TextEditingController(text: widget.dataEdit?['anak_ke']?.toString()); // Pastikan String
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

  // --- LOGIC SIMPAN KE FIREBASE ---
  Future<void> _handleSave() async {
    if (nikCtl.text.isEmpty || namaCtl.text.isEmpty) {
      _showSnackBar("Mohon lengkapi data NIK dan Nama", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nik': nikCtl.text,
      'nama': namaCtl.text,
      'jk': selectedJk,
      'ibu': ibuCtl.text,
      'tempat_lahir': tempatLahirCtl.text,
      'tgl_lahir': tglLahirCtl.text,
      'anak_ke': int.tryParse(anakKeCtl.text) ?? 0, // Simpan sebagai number
      'gol_darah': selectedGolDarah,
      'no_kk': widget.dataEdit?['no_kk'] ?? '-',
      'nama_ayah': widget.dataEdit?['nama_ayah'] ?? '-',
      'alamat': widget.dataEdit?['alamat'] ?? 'Alamat Baru',
      'updated_at': FieldValue.serverTimestamp(), // Timestamp otomatis
    };

    try {
      final collection = FirebaseFirestore.instance.collection('data_anak');
      
      if (widget.docId == null) {
        // TAMBAH DATA BARU
        await collection.add(data);
      } else {
        // EDIT DATA LAMA
        await collection.doc(widget.docId).update(data);
      }

      if (mounted) {
        _showSnackBar("Data Berhasil Disimpan", Colors.green);
        Navigator.pop(context, true); 
      }
    } catch (e) {
      _showSnackBar("Gagal menyimpan data: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.docId == null ? "Tambah Data Anak" : "Edit Data Anak",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AdminColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AdminColors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Silahkan lengkapi data anak dengan benar.",
                          style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildTwoColumnRow(
                  _buildLabelInput("NIK Anak", _buildTextField(controller: nikCtl, hint: "16 digit NIK", isNumber: true)),
                  _buildLabelInput("Nama Anak", _buildTextField(controller: namaCtl, hint: "Nama Lengkap")),
                ),
                const SizedBox(height: 20),
                _buildTwoColumnRow(
                  _buildLabelInput("Tempat Lahir", _buildTextField(controller: tempatLahirCtl, hint: "Kota Lahir")),
                  _buildLabelInput("Tanggal Lahir", _buildDatePickerField()),
                ),
                const SizedBox(height: 20),
                _buildTwoColumnRow(
                  _buildLabelInput("Anak Ke-", _buildTextField(controller: anakKeCtl, hint: "1, 2, dst", isNumber: true)),
                  _buildLabelInput(
                    "Gol. Darah",
                    _buildDropdownField(
                      value: selectedGolDarah,
                      items: ['A', 'B', 'AB', 'O','Belum diketahui'],
                      onChanged: (v) => setState(() => selectedGolDarah = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTwoColumnRow(
                  _buildLabelInput(
                    "Jenis Kelamin",
                    _buildDropdownField(
                      value: selectedJk,
                      items: ['Laki-laki', 'Perempuan'],
                      onChanged: (v) => setState(() => selectedJk = v!),
                    ),
                  ),
                  _buildLabelInput("Nama Ibu", _buildTextField(controller: ibuCtl, hint: "Nama Ibu Kandung", suffixIcon: Icons.search)),
                ),
                const SizedBox(height: 40),
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
                          onPressed: _isLoading ? null : _handleSave,
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
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
          if (_isLoading) Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS TETAP SAMA ---
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

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isNumber = false, IconData? suffixIcon}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AdminColors.primary, size: 20) : null,
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
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
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
      controller: tglLahirCtl,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "hh-bb-tttt",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AdminColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AdminColors.primary)),
            child: child!,
          ),
        );
        if (pickedDate != null) {
          setState(() {
            tglLahirCtl.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
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