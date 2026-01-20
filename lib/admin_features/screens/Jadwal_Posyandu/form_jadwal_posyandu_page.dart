import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN & CONFIG ---
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:poscare/admin_features/screens/config.dart'; // Akses globalDataJadwal

class FormJadwalPosyanduPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit;
  final int? indexEdit; 

  const FormJadwalPosyanduPage({
    super.key,
    this.dataEdit,
    this.indexEdit,
  });

  @override
  State<FormJadwalPosyanduPage> createState() => _FormJadwalPosyanduPageState();
}

class _FormJadwalPosyanduPageState extends State<FormJadwalPosyanduPage> {
  late TextEditingController tglCtl;
  late TextEditingController jamBukaCtl;
  late TextEditingController jamTutupCtl;

  @override
  void initState() {
    super.initState();
    tglCtl = TextEditingController(text: widget.dataEdit?['tanggal']);
    jamBukaCtl = TextEditingController(text: widget.dataEdit?['jam_buka']);
    jamTutupCtl = TextEditingController(text: widget.dataEdit?['jam_tutup']);
  }

  @override
  void dispose() {
    tglCtl.dispose();
    jamBukaCtl.dispose();
    jamTutupCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- APP BAR ---
      appBar: AppBar(
        title: Text(
          widget.dataEdit == null ? "Tambah Jadwal" : "Edit Jadwal",
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
                  const Icon(Icons.access_alarm, color: AdminColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Atur jadwal kegiatan Posyandu agar orang tua mengetahui.",
                      style: TextStyle(color: AdminColors.textGrey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input Tanggal
            _buildLabelInput(
              "Tanggal Pelaksanaan",
              _buildTextField(
                controller: tglCtl,
                hint: "Pilih Tanggal",
                icon: Icons.calendar_month,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: AdminColors.primary),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      tglCtl.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Input Jam (Row 2 Kolom)
            Row(
              children: [
                Expanded(
                  child: _buildLabelInput(
                    "Jam Mulai",
                    _buildTextField(
                      controller: jamBukaCtl,
                      hint: "--:--",
                      icon: Icons.schedule,
                      onTap: () => _pickTime(jamBukaCtl),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildLabelInput(
                    "Jam Selesai",
                    _buildTextField(
                      controller: jamTutupCtl,
                      hint: "--:--",
                      icon: Icons.schedule_send,
                      onTap: () => _pickTime(jamTutupCtl),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- TOMBOL AKSI ---
            Row(
              children: [
                // Simpan
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _handleSave,
                      child: const Text("SIMPAN JADWAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Batal
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

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AdminColors.primary, onPrimary: Colors.white, onSurface: AdminColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- LOGIC SIMPAN (DUMMY LOKAL) ---
  void _handleSave() {
    if (tglCtl.text.isEmpty || jamBukaCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi data jadwal!"), backgroundColor: Colors.red));
      return;
    }

    final newData = {
      'tanggal': tglCtl.text,
      'jam_buka': jamBukaCtl.text,
      'jam_tutup': jamTutupCtl.text,
    };

    setState(() {
      if (widget.dataEdit == null) {
        // Mode Tambah
        globalDataJadwal.add(newData);
      } else {
        // Mode Edit
        if (widget.indexEdit != null) {
          globalDataJadwal[widget.indexEdit!] = newData;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jadwal Berhasil Disimpan"), backgroundColor: AdminColors.menuOrtu));
    Navigator.pop(context, true);
  }

  // --- WIDGET HELPER ---
  Widget _buildLabelInput(String label, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        input,
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, required VoidCallback onTap}) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        suffixIcon: Icon(icon, size: 20, color: AdminColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AdminColors.primary, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}