import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:poscare/admin_features/core/admin_colors.dart';

class FormJadwalPosyanduPage extends StatefulWidget {
  final String? docId; 
  final Map<String, dynamic>? dataEdit; 

  const FormJadwalPosyanduPage({
    super.key,
    this.docId,
    this.dataEdit,
  });

  @override
  State<FormJadwalPosyanduPage> createState() => _FormJadwalPosyanduPageState();
}

class _FormJadwalPosyanduPageState extends State<FormJadwalPosyanduPage> {
  late TextEditingController tglCtl;
  late TextEditingController jamBukaCtl;
  late TextEditingController jamTutupCtl;
  
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tglCtl = TextEditingController(text: widget.dataEdit?['tanggal_str']);
    jamBukaCtl = TextEditingController(text: widget.dataEdit?['jam_mulai']);
    jamTutupCtl = TextEditingController(text: widget.dataEdit?['jam_selesai']);
    
    if (widget.dataEdit != null && widget.dataEdit!['tanggal_date'] != null) {
      _selectedDate = (widget.dataEdit!['tanggal_date'] as Timestamp).toDate();
    }
  }

  @override
  void dispose() {
    tglCtl.dispose();
    jamBukaCtl.dispose();
    jamTutupCtl.dispose();
    super.dispose();
  }

  // --- LOGIKA SIMULASI NOTIFIKASI ---
  Future<void> _sendNotificationToAllUsers(String tanggal, String jam) async {
    try {
      QuerySnapshot userTokens = await FirebaseFirestore.instance
          .collection('users')
          .where('fcmToken', isNotEqualTo: null)
          .get();

      if (userTokens.docs.isEmpty) return;

      // PERBAIKAN: Menggunakan variabel agar tidak "unused_local_variable"
      String title = "🗓️ Jadwal Posyandu Baru";
      String body = "Halo Bunda/Ayah, besok ada jadwal Posyandu pada $tanggal pukul $jam WIB. Jangan lupa bawa buku KIA ya!";

      debugPrint("Kirim Notif: $title - $body ke ${userTokens.docs.length} user.");
      
    } catch (e) {
      debugPrint("Gagal kirim notifikasi: $e");
    }
  }

  // --- LOGIC SIMPAN KE FIRESTORE ---
  Future<void> _saveToFirestore() async {
    // Tambahkan pengecekan mounted sebelum menggunakan ScaffoldMessenger
    if (tglCtl.text.isEmpty || jamBukaCtl.text.isEmpty || jamTutupCtl.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua data wajib diisi!"), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'tanggal_date': _selectedDate, 
        'tanggal_str': tglCtl.text, 
        'jam_mulai': jamBukaCtl.text,
        'jam_selesai': jamTutupCtl.text,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.docId == null) {
        data['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('jadwal_posyandu').add(data);
        await _sendNotificationToAllUsers(tglCtl.text, jamBukaCtl.text);
      } else {
        await FirebaseFirestore.instance.collection('jadwal_posyandu').doc(widget.docId).update(data);
      }

      // PERBAIKAN: Gunakan if (!mounted) return untuk async gaps
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jadwal Berhasil Disimpan!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI PICKER TANGGAL & WAKTU ---
  Future<void> _pickDate() async {
    await initializeDateFormatting('id_ID', null); 

    // Simpan context ke variabel lokal sebelum async jika diperlukan
    if (!mounted) return;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
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

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        tglCtl.text = DateFormat('EEEE, dd-MM-yyyy', 'id_ID').format(picked); 
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    if (!mounted) return;
    
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AdminColors.primary, 
              onPrimary: Colors.white, 
              onSurface: AdminColors.primary
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final localizations = MaterialLocalizations.of(context);
      String formattedTime = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: true);
      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bagian Build tetap sama seperti sebelumnya
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.docId == null ? "Tambah Jadwal" : "Edit Jadwal",
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
          children: [
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

            _buildLabelInput(
              "Tanggal Pelaksanaan",
              _buildTextField(
                controller: tglCtl,
                hint: "Pilih Tanggal",
                icon: Icons.calendar_month,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 20),

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

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _saveToFirestore,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("SIMPAN JADWAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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