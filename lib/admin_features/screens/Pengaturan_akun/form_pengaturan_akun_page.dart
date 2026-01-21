import 'package:flutter/material.dart';
// Import Warna Admin
import '../../core/admin_colors.dart';
// Import Data Dummy
import 'package:poscare/admin_features/screens/config.dart';

class FormPengaturanAkunPage extends StatefulWidget {
  final Map<String, dynamic>? dataEdit;
  final int? indexEdit;

  const FormPengaturanAkunPage({super.key, this.dataEdit, this.indexEdit});

  @override
  State<FormPengaturanAkunPage> createState() => _FormPengaturanAkunPageState();
}

class _FormPengaturanAkunPageState extends State<FormPengaturanAkunPage> {
  late TextEditingController namaCtl;
  late TextEditingController emailCtl;
  late TextEditingController passwordCtl;
  String? selectedJK;
  bool _isPasswordVisible = false; // Tambahan buat hide/show password

  @override
  void initState() {
    super.initState();
    namaCtl = TextEditingController(text: widget.dataEdit?['nama']);
    emailCtl = TextEditingController(text: widget.dataEdit?['email']);
    passwordCtl = TextEditingController(text: widget.dataEdit?['password']);
    selectedJK = widget.dataEdit?['jk']; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.white,
      appBar: AppBar(
        title: Text(
          widget.dataEdit == null ? "Tambah Admin Baru" : "Edit Data Admin",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AdminColors.primary, // Navy
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER KECIL ---
            const Text(
              "Informasi Akun",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: AdminColors.primary
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Lengkapi data di bawah ini untuk admin.",
              style: TextStyle(color: AdminColors.textGrey),
            ),
            const SizedBox(height: 25),

            // 1. INPUT NAMA
            _buildCustomInput(
              label: "Nama Lengkap",
              controller: namaCtl,
              icon: Icons.person_outline,
              hint: "Masukkan nama lengkap",
            ),
            const SizedBox(height: 20),

            // 2. INPUT EMAIL
            _buildCustomInput(
              label: "Email",
              controller: emailCtl,
              icon: Icons.email_outlined,
              hint: "E-mail Anda",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // 3. INPUT PASSWORD
            _buildCustomInput(
              label: "Password",
              controller: passwordCtl,
              icon: Icons.lock_outline,
              hint: "Password Anda",
              isPassword: true,
            ),
            const SizedBox(height: 20),

            // 4. DROPDOWN JENIS KELAMIN
            const Text(
              "Jenis Kelamin",
              style: TextStyle(
                color: AdminColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedJK,
                  icon: const Icon(Icons.arrow_drop_down, color: AdminColors.primary),
                  hint: const Text("Pilih Jenis Kelamin"),
                  items: ["Laki-laki", "Perempuan"].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Icon(
                            e == "Laki-laki" ? Icons.face : Icons.face_3,
                            color: e == "Laki-laki" ? Colors.blue : Colors.pink,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(e),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedJK = v),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- TOMBOL AKSI ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleSave,
                child: const Text(
                  "SIMPAN DATA",
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA SIMPAN (TETAP SAMA) ---
  void _handleSave() {
    if (namaCtl.text.isEmpty || emailCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi Nama dan Email!"), 
          backgroundColor: Colors.red
        )
      );
      return;
    }

    final newData = {
      'nama': namaCtl.text,
      'email': emailCtl.text,
      'password': passwordCtl.text,
      'jk': selectedJK ?? "Laki-laki", // Default Laki-laki biar gak error
    };

    if (widget.dataEdit == null) {
      globalDataAkun.add(newData);
    } else {
      if (widget.indexEdit != null) {
        globalDataAkun[widget.indexEdit!] = newData;
      }
    }
    // Kirim sinyal 'true' biar halaman depan nge-refresh
    Navigator.pop(context, true); 
  }

  // --- WIDGET INPUT CUSTOM BIAR RAPI ---
  Widget _buildCustomInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AdminColors.textDark, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? !_isPasswordVisible : false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AdminColors.primary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}