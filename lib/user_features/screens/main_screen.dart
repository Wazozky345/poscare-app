// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:poscare/user_features/screens/Grafik_page/grafik_screen.dart';
import 'package:poscare/user_features/screens/Imunisasi_page/imunisasi_screen.dart';
import '../core/colors.dart';

// --- IMPORT HALAMAN ---
import 'Home_page/home_screen.dart';
import 'Edukasi_page/edukasi_screen.dart';
import 'Profil_page/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default mulai dari Home

  // LIST HALAMAN (Pastikan urutannya bener sesuai BottomNavBar)
  final List<Widget> _pages = [
    const HomeScreen(),
    const EdukasiScreen(),
    const UserGrafikPage(), // <--- PANGGIL GRAFIK PERTUMBUHAN
    const UserImunisasiPage(), // <--- PANGGIL RIWAYAT IMUNISASI
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Body ganti-ganti sesuai menu
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Tipe Fixed biar label muncul semua
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor, // Warna Pink Poscare
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Grafik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Imunisasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}