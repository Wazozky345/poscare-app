// FILE: lib/admin_features/screens/Data_Ibu_Hamil/form_ibu_hamil_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poscare/admin_features/core/admin_colors.dart';
import 'package:intl/intl.dart';

class FormIbuHamilPage extends StatefulWidget {
  final String? docId; 
  final Map<String, dynamic>? existingData; 
  final String? userId; 

  const FormIbuHamilPage({super.key, this.docId, this.existingData, this.userId});

  @override
  State<FormIbuHamilPage> createState() => _FormIbuHamilPageState();
}

class _FormIbuHamilPageState extends State<FormIbuHamilPage> {
  // Controller Form
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _usiaController = TextEditingController(); // Usia dalam BULAN
  final _hplController = TextEditingController();
  final _tdController = TextEditingController();
  final _bbController = TextEditingController();
  final _riwayatController = TextEditingController();

  final _fundusController = TextEditingController();
  final _djjController = TextEditingController();
  final _lilaController = TextEditingController();

  String? _selectedParentUid; 
  List<Map<String, dynamic>> _userList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Isi form dengan data lama (Kalau Edit)
    if (widget.existingData != null) {
      _namaController.text = widget.existingData?['nama'] ?? '';
      _nikController.text = widget.existingData?['nik'] ?? '';
      _usiaController.text = widget.existingData?['usia_kehamilan']?.toString() ?? '';
      _hplController.text = widget.existingData?['hpl'] ?? '';
      _tdController.text = widget.existingData?['tekanan_darah'] ?? '';
      _bbController.text = widget.existingData?['berat_badan']?.toString() ?? '';
      _riwayatController.text = widget.existingData?['riwayat_kesehatan'] ?? '';
      
      _fundusController.text = widget.existingData?['tinggi_fundus']?.toString() ?? '';
      _djjController.text = widget.existingData?['detak_jantung_janin']?.toString() ?? '';
      _lilaController.text = widget.existingData?['lila']?.toString() ?? '';
    }

    _fetchUsers();
  }

  // --- LOGIC FETCH USER PINTAR ---
  Future<void> _fetchUsers() async {
    try {
      var usersSnapshot = await FirebaseFirestore.instance.collection('users').orderBy('nama').get();
      var existingDataSnapshot = await FirebaseFirestore.instance.collection('ibu_hamil').get();
      
      // Kumpulin ID user yang udah punya data (kecuali data yang lagi diedit sekarang)
      Set<String> usedUserIds = existingDataSnapshot.docs
          .map((doc) => doc.data()['parent_uid'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      List<Map<String, dynamic>> availableUsers = [];
      
      for (var doc in usersSnapshot.docs) {
        var userData = doc.data();
        String uid = doc.id;

        String? currentEditingId = widget.existingData?['parent_uid'];
        
        // Tampilkan user jika: Belum punya data ATAU ini adalah user yang sedang diedit
        if (!usedUserIds.contains(uid) || uid == currentEditingId) {
           availableUsers.add({
            'uid': uid,
            'label': "${userData['nama'] ?? 'Tanpa Nama'} (${userData['email'] ?? '-'})"
          });
        }
      }

      setState(() {
        _userList = availableUsers;
        
        String? oldParentId = widget.existingData?['parent_uid'];
        bool parentExists = _userList.any((u) => u['uid'] == oldParentId);

        if (parentExists) {
          _selectedParentUid = oldParentId; 
        } else {
          _selectedParentUid = null; 
        }
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch users: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIC HELPER BUAT DAPET NAMA USER SAAT EDIT ---
  String _getUserLabelForEdit() {
    if (_selectedParentUid == null) return "User Tidak Ditemukan";
    var user = _userList.firstWhere(
      (u) => u['uid'] == _selectedParentUid, 
      orElse: () => {'label': 'Memuat Data User...'}
    );
    return user['label'];
  }

  // --- LOGIC OTOMATIS HITUNG HPL ---
  void _calculateAutoHPL(String val) {
    // 1. Kalau input dihapus/kosong -> HPL juga kosong (RESET)
    if (val.isEmpty) {
      setState(() {
        _hplController.clear(); 
      });
      return;
    }

    int? usiaBulan = int.tryParse(val);
    
    if (usiaBulan != null && usiaBulan <= 9) {
      int sisaBulan = 9 - usiaBulan;
      DateTime now = DateTime.now();
      DateTime estimatedDate = DateTime(now.year, now.month + sisaBulan, now.day);

      // Format dd-MM-yyyy
      setState(() {
        _hplController.text = DateFormat('dd-MM-yyyy').format(estimatedDate); 
      });
    } else {
      setState(() {
        _hplController.clear();
      });
    }
  }

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
        // Format Manual Picker: dd-MM-yyyy
        _hplController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _saveData() async {
    if (_selectedParentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wajib memilih Akun User Pemilik Data!"), backgroundColor: Colors.red)
      );
      return;
    }

    final String id = widget.docId ?? FirebaseFirestore.instance.collection('ibu_hamil').doc().id;
    
    await FirebaseFirestore.instance.collection('ibu_hamil').doc(id).set({
      'parent_uid': _selectedParentUid, 
      'nama': _namaController.text,
      'nik': _nikController.text,
      'usia_kehamilan': _usiaController.text, 
      'hpl': _hplController.text, 
      'tekanan_darah': _tdController.text,
      'berat_badan': _bbController.text,
      'riwayat_kesehatan': _riwayatController.text,
      
      'tinggi_fundus': _fundusController.text, 
      'detak_jantung_janin': _djjController.text,
      'lila': _lilaController.text,

      'tgl_pemeriksaan': FieldValue.serverTimestamp(), 
      'last_update': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.docId == null ? "Data Berhasil Disimpan" : "Data Berhasil Diperbarui"))
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.docId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Data Ibu Hamil" : "Tambah Data Ibu Hamil", style: const TextStyle(color: Colors.white)),
        backgroundColor: AdminColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- PILIH AKUN USER (LOGIC EDIT) ---
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminColors.primary.withOpacity(0.3)), 
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hubungkan ke Akun User (Wajib):", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
                      const SizedBox(height: 10),
                      
                      // JIKA EDIT MODE -> TAMPILKAN TEXT FIELD MATI (READ ONLY)
                      if (isEditMode)
                        TextField(
                          enabled: false, 
                          controller: TextEditingController(text: _getUserLabelForEdit()), 
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey), 
                            suffixIcon: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text("(Tidak bisa diubah)", style: TextStyle(fontSize: 10, color: Colors.red)),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        )
                      // JIKA TAMBAH MODE -> TAMPILKAN DROPDOWN
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedParentUid,
                              isExpanded: true,
                              hint: const Text("Pilih Akun User..."),
                              items: _userList.map((user) {
                                return DropdownMenuItem<String>(
                                  value: user['uid'],
                                  child: Text(user['label'], style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedParentUid = val;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              ),
                            ),
                            if (_userList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("*Semua akun user sudah memiliki data Ibu Hamil.", style: TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),
                const Center(child: Text("Data Identitas Ibu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                const SizedBox(height: 15),
                
                _buildInputLabel("Nama Ibu"), 
                _buildTextField(_namaController, "Nama Lengkap"),
                
                _buildInputLabel("NIK Ibu"), 
                _buildTextField(_nikController, "16 Digit NIK", keyboardType: TextInputType.number),

                const SizedBox(height: 25),
                const Center(child: Text("Data Kesehatan Dasar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                const SizedBox(height: 15),
                
                // --- BAGIAN HITUNG OTOMATIS (REVISI HINT TEXT & FORMAT HPL) ---
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          _buildInputLabel("Usia Hamil (Bulan)"), 
                          _buildTextField(
                            _usiaController, 
                            "Masukkan Usia Kandungan", // Revisi Text
                            keyboardType: TextInputType.number,
                            // TRIGGER AUTOMATION DISINI
                            onChanged: (val) => _calculateAutoHPL(val), 
                          )
                        ]
                      )
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          _buildInputLabel("HPL (Otomatis)"), 
                          _buildTextField(
                            _hplController, 
                            "- Menunggu Input -", // Revisi Text kalau kosong
                            readOnly: true, 
                            onTap: () => _selectDate(context), 
                            suffixIcon: Icons.calendar_today
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
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("Berat Badan"), _buildTextField(_bbController, "kg", keyboardType: TextInputType.number)])),
                  ],
                ),

                const SizedBox(height: 25),
                const Center(child: Text("Detail Kandungan (Lengkap)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("Tinggi Fundus"), _buildTextField(_fundusController, "cm", keyboardType: TextInputType.number)])),
                    const SizedBox(width: 15),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel("LILA (Lingkar Lengan)"), _buildTextField(_lilaController, "cm", keyboardType: TextInputType.number)])),
                  ],
                ),

                _buildInputLabel("Detak Jantung Janin (DJJ)"),
                _buildTextField(_djjController, "bpm (denyut per menit)", keyboardType: TextInputType.number),
                
                const SizedBox(height: 25),
                const Center(child: Text("Catatan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                
                _buildInputLabel("Riwayat Kesehatan / Keluhan"),
                _buildTextField(_riwayatController, "Catatan...", maxLines: 3),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : _saveData,
                  child: Text(widget.docId == null ? "SIMPAN DATA" : "UPDATE DATA", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 10),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary, fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType, IconData? suffixIcon, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      onChanged: onChanged, 
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20, color: AdminColors.primary) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
    );
  }
}