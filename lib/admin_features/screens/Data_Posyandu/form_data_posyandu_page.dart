import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import '../config.dart'; // Akses globalDataPosyandu & globalDataAnak

class FormDataPosyanduPage extends StatefulWidget {
  final String title; // Judul halaman (Tambah/Edit)
  final Map<String, dynamic>? dataEdit;
  final int? indexEdit;

  const FormDataPosyanduPage({
    super.key,
    required this.title,
    this.dataEdit,
    this.indexEdit,
  });

  @override
  State<FormDataPosyanduPage> createState() => _FormDataPosyanduPageState();
}

class _FormDataPosyanduPageState extends State<FormDataPosyanduPage> {
  // Controller Input
  final TextEditingController namaAnakCtl = TextEditingController();
  final TextEditingController tglLahirCtl = TextEditingController();
  final TextEditingController nikAnakCtl = TextEditingController();
  final TextEditingController tglPosyanduCtl = TextEditingController();
  final TextEditingController umurCtl = TextEditingController(); // Otomatis
  final TextEditingController bbCtl = TextEditingController();
  final TextEditingController tbCtl = TextEditingController();

  // State Pilihan
  String kondisi = "Sehat"; // Default

  // State Checkbox Vaksin
  bool isHepB = false;
  bool isBCG = false;
  bool isPolio = false;
  bool isDPT = false;
  bool isCampak = false;

  @override
  void initState() {
    super.initState();
    // Jika Mode Edit: Isi form dengan data lama
    if (widget.dataEdit != null) {
      namaAnakCtl.text = widget.dataEdit!['nama_anak'];
      tglPosyanduCtl.text = widget.dataEdit!['tgl_posyandu'];
      tbCtl.text = widget.dataEdit!['tb'];
      bbCtl.text = widget.dataEdit!['bb'];
      umurCtl.text = widget.dataEdit!['umur'];
      kondisi = widget.dataEdit!['kondisi'] ?? "Sehat";

      // Cek Vaksin yang sudah dipilih sebelumnya
      var vaksinList = widget.dataEdit!['vaksin'];
      String vaksinString = "";
      if (vaksinList is List) {
        vaksinString = vaksinList.join(",");
      } else {
        vaksinString = vaksinList.toString();
      }

      if (vaksinString.contains("Hepatitis B")) isHepB = true;
      if (vaksinString.contains("BCG")) isBCG = true;
      if (vaksinString.contains("Polio")) isPolio = true;
      if (vaksinString.contains("DPT")) isDPT = true;
      if (vaksinString.contains("Campak")) isCampak = true;
    } else {
      // Jika Mode Tambah: Default Tanggal Hari Ini
      DateTime now = DateTime.now();
      tglPosyanduCtl.text = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- APP BAR ---
      appBar: AppBar(
        title: Text(
          widget.title,
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
                  const Icon(Icons.monitor_weight, color: AdminColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Pilih nama anak terlebih dahulu untuk mengisi data otomatis.",
                      style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- BAGIAN 1: DATA ANAK ---
            _sectionTitle("Identitas Anak"),
            const SizedBox(height: 15),

            // Pilih Nama Anak (Dengan Tombol Pilih)
            _buildLabelInput("Nama Anak", 
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(controller: namaAnakCtl, hint: "Klik tombol pilih ->", readOnly: true),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _showPilihAnakDialog,
                    child: const Text("PILIH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ),
            const SizedBox(height: 15),
            
            // NIK & Tgl Lahir (ReadOnly)
            _buildTwoColumnRow(
              _buildLabelInput("NIK Anak", _buildTextField(controller: nikAnakCtl, hint: "Otomatis", readOnly: true)),
              _buildLabelInput("Tgl Lahir", _buildTextField(controller: tglLahirCtl, hint: "Otomatis", readOnly: true)),
            ),

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 15),

            // --- BAGIAN 2: DATA PEMERIKSAAN ---
            _sectionTitle("Data Pemeriksaan"),
            const SizedBox(height: 15),

            // Tgl Posyandu & Umur
            _buildTwoColumnRow(
              _buildLabelInput(
                "Tanggal Posyandu",
                _buildDatePickerField(tglPosyanduCtl),
              ),
              _buildLabelInput("Umur (Bulan)", _buildTextField(controller: umurCtl, hint: "Otomatis/Isi Manual", isNumber: true)),
            ),
            const SizedBox(height: 15),

            // BB & TB
            _buildTwoColumnRow(
              _buildLabelInput("Berat Badan (kg)", _buildTextField(controller: bbCtl, hint: "0.0", isNumber: true)),
              _buildLabelInput("Tinggi Badan (cm)", _buildTextField(controller: tbCtl, hint: "0.0", isNumber: true)),
            ),

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 15),

            // --- BAGIAN 3: KONDISI & VAKSIN ---
            _sectionTitle("Status Kesehatan"),
            const SizedBox(height: 15),

            // Kondisi Radio Button
            const Text("Kondisi Anak Saat Ini:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AdminColors.textDark)),
            Row(
              children: [
                _radioOption("Sehat"),
                const SizedBox(width: 20),
                _radioOption("Sakit"),
                const SizedBox(width: 20),
                _radioOption("Stunting"),
              ],
            ),
            const SizedBox(height: 20),

            // Vaksin Checkbox
            const Text("Vaksin yang Diberikan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AdminColors.textDark)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _checkboxOption("Hepatitis B", isHepB, (v) => setState(() => isHepB = v!)),
                  _checkboxOption("BCG", isBCG, (v) => setState(() => isBCG = v!)),
                  _checkboxOption("Polio", isPolio, (v) => setState(() => isPolio = v!)),
                  _checkboxOption("DPT", isDPT, (v) => setState(() => isDPT = v!)),
                  _checkboxOption("Campak", isCampak, (v) => setState(() => isCampak = v!)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- TOMBOL AKSI ---
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
    if (namaAnakCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama Anak Wajib Diisi!"), backgroundColor: Colors.red));
      return;
    }

    List<String> vaksinDipilih = [];
    if (isHepB) vaksinDipilih.add("Hepatitis B");
    if (isBCG) vaksinDipilih.add("BCG");
    if (isPolio) vaksinDipilih.add("Polio");
    if (isDPT) vaksinDipilih.add("DPT");
    if (isCampak) vaksinDipilih.add("Campak");

    final newData = {
      'nama_anak': namaAnakCtl.text,
      'tb': tbCtl.text,
      'bb': bbCtl.text,
      'umur': umurCtl.text,
      'tgl_posyandu': tglPosyanduCtl.text,
      'vaksin': vaksinDipilih.isEmpty ? ['-'] : vaksinDipilih,
      'kondisi': kondisi,
    };

    setState(() {
      if (widget.dataEdit == null) {
        globalDataPosyandu.add(newData);
      } else {
        if (widget.indexEdit != null) {
          globalDataPosyandu[widget.indexEdit!] = newData;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Berhasil Disimpan"), backgroundColor: AdminColors.menuOrtu));
    Navigator.pop(context, true);
  }

  // --- WIDGET HELPER ---

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminColors.textDark, decoration: TextDecoration.underline),
    );
  }

  Widget _buildLabelInput(String label, Widget inputWidget) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      inputWidget,
    ]);
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool readOnly = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDatePickerField(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "hh-bb-tttt",
        suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AdminColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onTap: () async {
        DateTime? p = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AdminColors.primary, onPrimary: Colors.white, onSurface: AdminColors.textDark),
              ),
              child: child!,
            );
          },
        );
        if (p != null) {
          ctrl.text = "${p.day.toString().padLeft(2, '0')}-${p.month.toString().padLeft(2, '0')}-${p.year}";
        }
      },
    );
  }

  Widget _radioOption(String value) {
    return Row(children: [
      Radio(value: value, groupValue: kondisi, onChanged: (v) => setState(() => kondisi = v.toString()), activeColor: AdminColors.primary),
      Text(value),
    ]);
  }

  Widget _checkboxOption(String label, bool val, Function(bool?) onChange) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(value: val, onChanged: onChange, activeColor: AdminColors.primary),
      Text(label),
    ]);
  }

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(children: [Expanded(child: left), const SizedBox(width: 15), Expanded(child: right)]);
  }

  // DIALOG PILIH ANAK (Custom Style)
  void _showPilihAnakDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pilih Data Anak", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300, // Batasi tinggi biar bisa discroll
          child: ListView.separated(
            itemCount: globalDataAnak.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (ctx, i) {
              final anak = globalDataAnak[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AdminColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.face, color: AdminColors.primary),
                ),
                title: Text(anak['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Tgl Lahir: ${anak['tgl_lahir']}"),
                onTap: () {
                  setState(() {
                    namaAnakCtl.text = anak['nama'];
                    nikAnakCtl.text = anak['nik'];
                    tglLahirCtl.text = anak['tgl_lahir'];
                    // Hitung Umur Simple (Bulan)
                    try {
                      // Format tgl lahir di config biasanya dd-mm-yyyy atau yyyy-mm-dd
                      // Ini asumsi format tanggal konsisten ya bang.
                      // Kalau error parsing, umur jadi 0.
                      umurCtl.text = "12"; // Dummy hitung otomatis
                    } catch (e) {
                      umurCtl.text = "0";
                    }
                  });
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}