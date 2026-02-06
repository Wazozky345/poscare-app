import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';

class FormDataAnakPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit; 
  final String? docId; 

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
  late TextEditingController tbCtl; 
  late TextEditingController bbCtl;

  // Dropdown Values
  late String selectedJk;
  late String selectedGolDarah;
  String? selectedParentUid; 

  // List Orang Tua (User) - PENTING BUAT DROPDOWN
  List<Map<String, dynamic>> _parentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Controller
    nikCtl = TextEditingController(text: widget.dataEdit?['nik']);
    namaCtl = TextEditingController(text: widget.dataEdit?['nama']);
    tempatLahirCtl = TextEditingController(text: widget.dataEdit?['tempat_lahir']);
    tglLahirCtl = TextEditingController(text: widget.dataEdit?['tgl_lahir']);
    anakKeCtl = TextEditingController(text: widget.dataEdit?['anak_ke']?.toString());
    tbCtl = TextEditingController(text: widget.dataEdit?['tb']?.toString());
    bbCtl = TextEditingController(text: widget.dataEdit?['bb']?.toString());

    selectedJk = widget.dataEdit?['jk'] ?? 'Laki-laki';
    selectedGolDarah = widget.dataEdit?['gol_darah'] ?? 'Belum diketahui';
    
    // Ambil Data Orang Tua Dulu sebelum nampilin Dropdown
    _fetchParents();
  }

  // --- AMBIL DATA ORTU DARI FIREBASE ---
  Future<void> _fetchParents() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('users').orderBy('nama').get();
      List<Map<String, dynamic>> parents = [];
      
      for (var doc in snapshot.docs) {
        var data = doc.data();
        parents.add({
          'uid': doc.id,
          'label': "${data['nama'] ?? 'Tanpa Nama'} (${data['email'] ?? '-'})"
        });
      }

      if (mounted) {
        setState(() {
          _parentList = parents;
          
          // --- LOGIC ANTI CRASH ---
          // Cek apakah parent_uid yang lama MASIH ADA di daftar?
          String? oldParentId = widget.dataEdit?['parent_uid'];
          bool parentExists = _parentList.any((p) => p['uid'] == oldParentId);

          if (parentExists) {
            selectedParentUid = oldParentId; // Kalo ada, pake.
          } else {
            selectedParentUid = null; // Kalo ortunya udah dihapus, kosongin (JANGAN CRASH)
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetch parents: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nikCtl.dispose();
    namaCtl.dispose();
    tempatLahirCtl.dispose();
    tglLahirCtl.dispose();
    anakKeCtl.dispose();
    tbCtl.dispose();
    bbCtl.dispose();
    super.dispose();
  }

  // --- LOGIC SIMPAN ---
  Future<void> _handleSave() async {
    if (selectedParentUid == null) {
      _showSnackBar("Wajib memilih Orang Tua (Akun User)!", Colors.orange);
      return;
    }
    if (nikCtl.text.isEmpty || namaCtl.text.isEmpty) {
      _showSnackBar("Mohon lengkapi data NIK dan Nama Anak", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nik': nikCtl.text,
      'nama': namaCtl.text,
      'jk': selectedJk,
      'tempat_lahir': tempatLahirCtl.text,
      'tgl_lahir': tglLahirCtl.text,
      'anak_ke': int.tryParse(anakKeCtl.text) ?? 1, 
      'gol_darah': selectedGolDarah,
      'tb': double.tryParse(tbCtl.text.replaceAll(',', '.')) ?? 0.0,
      'bb': double.tryParse(bbCtl.text.replaceAll(',', '.')) ?? 0.0,
      'parent_uid': selectedParentUid, 
      'updated_at': FieldValue.serverTimestamp(),
    };

    try {
      final collection = FirebaseFirestore.instance.collection('data_anak');
      
      if (widget.docId == null) {
        await collection.add(data);
      } else {
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // BAGIAN 1: PILIH ORANG TUA (DROPDOWN)
                const Text("Pilih Orang Tua (Akun User)", style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedParentUid,
                  hint: const Text("Pilih Orang Tua..."),
                  items: _parentList.map((parent) {
                    return DropdownMenuItem<String>(
                      value: parent['uid'],
                      child: Text(parent['label'], style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedParentUid = val;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                
                if (selectedParentUid == null && widget.docId != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "*Orang tua sebelumnya tidak ditemukan. Silakan pilih ulang.",
                      style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),

                const SizedBox(height: 25),
                const Divider(thickness: 1),
                const SizedBox(height: 20),

                // BAGIAN 2: DATA ANAK
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
                  _buildLabelInput("Tinggi Badan (cm)", _buildTextField(controller: tbCtl, hint: "Cth: 50.5", isNumber: true)),
                  _buildLabelInput("Berat Badan (kg)", _buildTextField(controller: bbCtl, hint: "Cth: 3.2", isNumber: true)),
                ),
                const SizedBox(height: 20),
                _buildTwoColumnRow(
                  _buildLabelInput("Anak Ke-", _buildTextField(controller: anakKeCtl, hint: "1, 2, dst", isNumber: true)),
                  _buildLabelInput(
                    "Gol. Darah",
                    _buildDropdownField(
                      value: selectedGolDarah,
                      items: ['Belum diketahui', 'A', 'B', 'AB', 'O'],
                      onChanged: (v) => setState(() => selectedGolDarah = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabelInput(
                    "Jenis Kelamin",
                    _buildDropdownField(
                      value: selectedJk,
                      items: ['Laki-laki', 'Perempuan'],
                      onChanged: (v) => setState(() => selectedJk = v!),
                    ),
                  ),

                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _handleSave, 
                    child: const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // --- WIDGET HELPERS ---
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
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  // 👇 PERBAIKAN DI SINI (ANTI JEBOL KANAN) 👇
  Widget _buildDropdownField({required String value, required List<String> items, required Function(String?) onChanged}) {
    if (!items.contains(value)) {
      value = items[0];
    }
    
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true, // WAJIB: Biar gak nabrak kanan
      items: items.map((e) => DropdownMenuItem(
        value: e, 
        child: Text(
          e, 
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis, // WAJIB: Biar teks kepotong kalo kepanjangan
          maxLines: 1,
        )
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
        suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AdminColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
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