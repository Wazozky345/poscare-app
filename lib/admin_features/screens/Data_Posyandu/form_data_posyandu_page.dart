// FILE: lib/admin_features/screens/Data_Posyandu/form_data_posyandu_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:poscare/admin_features/core/admin_colors.dart';

class FormDataPosyanduPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? dataEdit;
  final String? docId; 

  const FormDataPosyanduPage({
    super.key,
    required this.title,
    this.dataEdit,
    this.docId,
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
  final TextEditingController umurCtl = TextEditingController();
  final TextEditingController bbCtl = TextEditingController();
  final TextEditingController tbCtl = TextEditingController();

  // State Pilihan
  String kondisi = "Sehat";
  String? selectedChildId; 
  String? selectedParentUid; 

  // --- UPGRADE: VAKSIN STABIL ---
  final Set<String> _selectedVaksin = {};
  List<String> _masterVaksinList = []; // Simpan list vaksin di sini biar gak loading terus
  bool _isLoadingVaksin = true;

  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    
    // Load Master Vaksin Dulu
    _fetchMasterVaksin();

    if (widget.dataEdit != null) {
      // MODE EDIT
      namaAnakCtl.text = widget.dataEdit!['nama_anak'] ?? '';
      tglPosyanduCtl.text = _formatTimestamp(widget.dataEdit!['tgl_posyandu']); 
      tbCtl.text = widget.dataEdit!['tb']?.toString() ?? '';
      bbCtl.text = widget.dataEdit!['bb']?.toString() ?? '';
      umurCtl.text = widget.dataEdit!['umur_bulan']?.toString() ?? '';
      kondisi = widget.dataEdit!['kondisi'] ?? "Sehat";
      
      selectedChildId = widget.dataEdit!['child_id'];
      selectedParentUid = widget.dataEdit!['parent_uid'];
      nikAnakCtl.text = widget.dataEdit!['nik_anak'] ?? ''; 

      // Load Vaksin Terpilih
      var vaksinList = widget.dataEdit!['vaksin'];
      if (vaksinList is List) {
        for (var v in vaksinList) {
          _selectedVaksin.add(v.toString());
        }
      }
    } else {
      // MODE TAMBAH
      DateTime now = DateTime.now();
      tglPosyanduCtl.text = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    }
  }

  // --- FETCH MASTER VAKSIN SEKALI AJA (BIAR GAK LOMPAT) ---
  Future<void> _fetchMasterVaksin() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('jenis_vaksin').orderBy('nama_vaksin').get();
      List<String> loadedVaksin = [];
      for (var doc in snapshot.docs) {
        loadedVaksin.add(doc['nama_vaksin'] ?? '');
      }
      if (mounted) {
        setState(() {
          _masterVaksinList = loadedVaksin;
          _isLoadingVaksin = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal load vaksin: $e");
      if (mounted) setState(() => _isLoadingVaksin = false);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "";
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return "${date.day.toString().padLeft(2,'0')}-${date.month.toString().padLeft(2,'0')}-${date.year}";
    }
    return timestamp.toString();
  }

  // --- LOGIC SIMPAN ---
  Future<void> _handleSave() async {
    if (selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih Data Anak Terlebih Dahulu!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    // Parse Tanggal
    DateTime tglSort;
    try {
        List<String> parts = tglPosyanduCtl.text.split('-');
        tglSort = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch(e) {
        tglSort = DateTime.now();
    }

    final dataKesehatan = {
      'child_id': selectedChildId, 
      'parent_uid': selectedParentUid, 
      'nama_anak': namaAnakCtl.text,
      'nik_anak': nikAnakCtl.text,
      'tgl_posyandu': tglSort, 
      'umur_bulan': int.tryParse(umurCtl.text) ?? 0,
      'tb': double.tryParse(tbCtl.text) ?? 0.0,
      'bb': double.tryParse(bbCtl.text) ?? 0.0,
      'kondisi': kondisi,
      'vaksin': _selectedVaksin.toList(), 
      'updated_at': FieldValue.serverTimestamp(),
    };

    try {
      final collection = FirebaseFirestore.instance.collection('data_kesehatan_anak');
      
      if (widget.docId == null) {
        await collection.add(dataKesehatan);
      } else {
        await collection.doc(widget.docId).update(dataKesehatan);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Kesehatan Berhasil Disimpan"), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- DIALOG PILIH ANAK ---
  void _showPilihAnakDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pilih Data Anak", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('data_anak').orderBy('nama').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Belum ada data anak."));
              }

              var docs = snapshot.data!.docs;
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  var data = docs[i].data() as Map<String, dynamic>;
                  String docId = docs[i].id;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AdminColors.primary.withOpacity(0.1),
                      child: Icon(
                        (data['jk'] == 'Laki-laki') ? Icons.face : Icons.face_3, 
                        color: AdminColors.primary
                      ),
                    ),
                    title: Text(data['nama'] ?? "Tanpa Nama", style: const TextStyle(fontWeight: FontWeight.bold)),
                    
                    // --- UPDATE DI SINI: LOAD DATA IBU SECARA REALTIME DARI TABEL USERS ---
                    subtitle: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(data['parent_uid']).get(),
                      builder: (context, snapshotOrtu) {
                        if (snapshotOrtu.connectionState == ConnectionState.waiting) {
                          return const Text("Ibu: Memuat...", style: TextStyle(fontSize: 12, color: Colors.grey));
                        }
                        if (snapshotOrtu.hasData && snapshotOrtu.data!.exists) {
                          var dataIbu = snapshotOrtu.data!.data() as Map<String, dynamic>;
                          String namaIbu = dataIbu['nama'] ?? "Tanpa Nama";
                          return Text("Ibu: $namaIbu", style: const TextStyle(color: AdminColors.textDark));
                        }
                        return const Text("Ibu: - (Data Ortu Hilang)");
                      },
                    ),
                    // --------------------------------------------------------------------

                    onTap: () {
                      setState(() {
                        namaAnakCtl.text = data['nama'] ?? '';
                        nikAnakCtl.text = data['nik'] ?? '';
                        tglLahirCtl.text = data['tgl_lahir'] ?? '';
                        selectedChildId = docId;
                        selectedParentUid = data['parent_uid'];
                        _hitungUmur(data['tgl_lahir']);
                      });
                      Navigator.pop(ctx);
                    },
                  );
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

  void _hitungUmur(String? tglLahirStr) {
    if (tglLahirStr == null || tglLahirStr.isEmpty) {
        umurCtl.text = "0";
        return;
    }
    try {
        List<String> parts = tglLahirStr.split('-');
        DateTime tglLahir = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        DateTime now = DateTime.now();
        
        int umurBulan = (now.year - tglLahir.year) * 12 + now.month - tglLahir.month;
        if (now.day < tglLahir.day) umurBulan--;
        
        umurCtl.text = umurBulan.toString();
    } catch (e) {
        umurCtl.text = "0"; 
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
            SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _sectionTitle("Identitas Anak"),
                const SizedBox(height: 15),
                _buildLabelInput("Nama Anak", 
                    Row(
                    children: [
                        Expanded(child: _buildTextField(controller: namaAnakCtl, hint: "Klik tombol pilih ->", readOnly: true)),
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
            
                _buildTwoColumnRow(
                    _buildLabelInput("NIK Anak", _buildTextField(controller: nikAnakCtl, hint: "Otomatis", readOnly: true)),
                    _buildLabelInput("Tgl Lahir", _buildTextField(controller: tglLahirCtl, hint: "Otomatis", readOnly: true)),
                ),

                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 15),

                _sectionTitle("Data Pemeriksaan"),
                const SizedBox(height: 15),

                _buildTwoColumnRow(
                    _buildLabelInput(
                    "Tanggal Posyandu",
                    _buildDatePickerField(tglPosyanduCtl),
                    ),
                    _buildLabelInput("Umur (Bulan)", _buildTextField(controller: umurCtl, hint: "Otomatis/Isi Manual", isNumber: true)),
                ),
                const SizedBox(height: 15),

                _buildTwoColumnRow(
                    _buildLabelInput("Berat Badan (kg)", _buildTextField(controller: bbCtl, hint: "0.0", isNumber: true)),
                    _buildLabelInput("Tinggi Badan (cm)", _buildTextField(controller: tbCtl, hint: "0.0", isNumber: true)),
                ),

                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 15),

                _sectionTitle("Status Kesehatan"),
                const SizedBox(height: 15),

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

                // --- VAKSIN DINAMIS ---
                const Text("Vaksin yang Diberikan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AdminColors.textDark)),
                const SizedBox(height: 10),
                Container(
                    width: double.infinity, 
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isLoadingVaksin
                      ? const Center(child: LinearProgressIndicator()) 
                      : _masterVaksinList.isEmpty
                        ? const Text("Belum ada data vaksin di Master Data.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                        : Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            children: _masterVaksinList.map((namaVaksin) {
                              bool isSelected = _selectedVaksin.contains(namaVaksin);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AdminColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedVaksin.add(namaVaksin);
                                        } else {
                                          _selectedVaksin.remove(namaVaksin);
                                        }
                                      });
                                    },
                                  ),
                                  Text(namaVaksin),
                                ],
                              );
                            }).toList(),
                          ),
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
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        ]
      )
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminColors.textDark, decoration: TextDecoration.underline));
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
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onTap: () async {
        DateTime? p = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
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

  Widget _buildTwoColumnRow(Widget left, Widget right) {
    return Row(children: [Expanded(child: left), const SizedBox(width: 15), Expanded(child: right)]);
  }
}