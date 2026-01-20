import 'package:flutter/material.dart';

// --- IMPORT WARNA ADMIN ---
import 'package:poscare/admin_features/core/admin_colors.dart'; 

// --- IMPORT DASHBOARD ---
import 'package:poscare/admin_features/Dashboard/dashboard_page.dart'; 

// --- IMPORT REGISTRASI ---
import 'registration_page.dart'; 

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleAdminLogin() {
    // Validasi sederhana
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Email dan Password harus diisi!")),
       );
       return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardAdminPage(namaUser: "Admin")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.white, 
      appBar: AppBar(
        backgroundColor: AdminColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            
            const SizedBox(height: 100), 

            // ICON ADMIN
            const Icon(Icons.admin_panel_settings, size: 80, color: AdminColors.primary),
            const SizedBox(height: 20),

            // JUDUL
            const Text(
              'LOGIN ADMIN',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AdminColors.primary,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk untuk mengelola sistem Poscare.',
              style: TextStyle(fontSize: 14, color: AdminColors.textGrey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // INPUT EMAIL
            const Text("Email Admin", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              cursorColor: AdminColors.primary,
              decoration: InputDecoration(
                hintText: 'admin@poscare.com',
                prefixIcon: const Icon(Icons.email_outlined, color: AdminColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // INPUT PASSWORD
            const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              cursorColor: AdminColors.primary,
              decoration: InputDecoration(
                hintText: '********',
                prefixIcon: const Icon(Icons.lock_outline, color: AdminColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AdminColors.primary, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: AdminColors.primary,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL LOGIN
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _handleAdminLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "MASUK",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminColors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // LINK KE REGISTRASI
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Belum punya akun admin? ",
                  style: TextStyle(color: AdminColors.textGrey),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationPage()),
                    );
                  },
                  child: const Text(
                    "Registrasi",
                    style: TextStyle(
                      color: AdminColors.primary, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}