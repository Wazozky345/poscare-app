import 'package:flutter/material.dart';

// --- 1. IMPORT FILE WARNA UTAMA ---
// Pastikan path ini sesuai dengan struktur folder lu
import 'package:poscare/admin_features/core/admin_colors.dart';

// ==========================================
// 2. KONFIGURASI WARNA (TERINTEGRASI)
// ==========================================

// Sekarang variabel lama ini ngambil nilai dari AdminColors.
// Jadi kalau AdminColors diubah, ini otomatis berubah. Gak perlu kerja 2x.
const Color mainBlue = AdminColors.primary;       // Navy (0xFF0C134F)
const Color cardGrey = AdminColors.background;    // Abu Putih (0xFFF5F7FA)

// Warna variasi tambahan (Tetap didefinisikan disini biar spesifik)
const Color inputCyan = Color(0xFF205295);        // Royal Blue (Tombol Sekunder)
const Color logoPink = Color(0xFFFF2E63);         // Pink (Aksen)
const Color chartTeal = Color(0xFF009688);        // Teal
const Color chartYellow = Color(0xFFFFC107);      // Kuning

// ==========================================
// 3. DATA DUMMY (DATABASE SEMENTARA)
// ==========================================

// --- DATA USER (LOGIN) ---
List<Map<String, dynamic>> databaseUser = [
  {
    'username': 'admin',
    'password': '123',
    'role': 'Admin',
    'nama': 'Ari Firmansyah',
    'jk': 'Laki-laki',
  },
];

// --- DATA ANAK (MASTER DATA) ---
List<Map<String, dynamic>> globalDataAnak = [
  {
    'nik': '3511000000000001',
    'nama': 'Mevy Kumalasari',
    'tempat_lahir': 'Bondowoso',
    'tgl_lahir': '20-05-2020',
    'anak_ke': '1',
    'gol_darah': 'O',
    'jk': 'Perempuan',
    'no_kk': '3511000000000001',
    'ibu': 'Mevy Wardhana',
    'nama_ayah': 'Agus Wardhana',
    'alamat': 'Koncer Kidul, Bondowoso',
  },
  {
    'nik': '3512040304200001',
    'nama': 'Muhammad Busyro',
    'tempat_lahir': 'Bondowoso',
    'tgl_lahir': '12-11-2023',
    'anak_ke': '1',
    'gol_darah': 'A',
    'jk': 'Laki-laki',
    'no_kk': '3512040304200099',
    'ibu': 'Jumiyatun Hasanah',
    'nama_ayah': 'Budi Santoso',
    'alamat': 'Tegalampel, Bondowoso',
  },
  {
    'nik': '3512040606200001',
    'nama': 'Mohammad Zadid Taqwa',
    'tempat_lahir': 'Bondowoso',
    'tgl_lahir': '01-08-2023',
    'anak_ke': '2',
    'gol_darah': 'AB',
    'jk': 'Laki-laki',
    'no_kk': '3512040606200088',
    'ibu': 'Rusmawati',
    'nama_ayah': 'Hadi Prayitno',
    'alamat': 'Curahdami, Bondowoso',
  },
  {
    'nik': '3512040912200001',
    'nama': 'Moch. Dirgantara Putra',
    'tempat_lahir': 'Bondowoso',
    'tgl_lahir': '20-02-2023',
    'anak_ke': '1',
    'gol_darah': 'O',
    'jk': 'Laki-laki',
    'no_kk': '3512040912200077',
    'ibu': 'Nur Aisyah',
    'nama_ayah': 'Slamet Riyadi',
    'alamat': 'Tamansari, Bondowoso',
  },
  {
    'nik': '3512041409200002',
    'nama': 'Kenzi Adhinata Pratama',
    'tempat_lahir': 'Bondowoso',
    'tgl_lahir': '15-01-2024',
    'anak_ke': '2',
    'gol_darah': 'B',
    'jk': 'Laki-laki',
    'no_kk': '3512041409200066',
    'ibu': 'Fitri Maulida',
    'nama_ayah': 'Joko Widodo',
    'alamat': 'Maesan, Bondowoso',
  },
];

// --- DATA ORANG TUA (MASTER DATA) ---
List<Map<String, dynamic>> globalDataOrangTua = [
  {
    'no_kk': '3172010502090982',
    'nik_ibu': '3511001298643251',
    'nama_ibu': 'Amanda Azahra Kirana',
    'tempat_lahir_ibu': 'Bondowoso',
    'tgl_lahir_ibu': '15-04-1999',
    'gol_darah_ibu': 'AB',
    'nik_ayah': '3511004216657001',
    'nama_ayah': 'Bimantara Dwi Aditya',
    'alamat': 'Jalan Sukowono, Desa Sumbersari',
    'telepon': '082365958119',
  },
  {
    'no_kk': '3216061907160050',
    'nik_ibu': '3511001298643000',
    'nama_ibu': 'Razia Ulfa',
    'tempat_lahir_ibu': 'Jember',
    'tgl_lahir_ibu': '20-05-2000',
    'gol_darah_ibu': 'O',
    'nik_ayah': '3511004216657002',
    'nama_ayah': 'Farisy Rafsanjani',
    'alamat': 'Jalan Mawar No 12',
    'telepon': '081973245963',
  },
];

// --- DATA IMUNISASI ---
List<Map<String, dynamic>> globalDataImunisasi = [
  {'nama_vaksin': 'Hepatitis B'},
  {'nama_vaksin': 'BCG'},
  {'nama_vaksin': 'Polio Tetes 1'},
  {'nama_vaksin': 'DPT-HB-Hib 1'},
  {'nama_vaksin': 'Polio Tetes 2'},
  {'nama_vaksin': 'Campak Rubella'},
];

// --- DATA JADWAL POSYANDU ---
List<Map<String, dynamic>> globalDataJadwal = [
  {'tanggal': '04-06-2024', 'jam_buka': '09:00', 'jam_tutup': '12:00'},
  {'tanggal': '09-07-2024', 'jam_buka': '08:00', 'jam_tutup': '11:00'},
  {'tanggal': '15-08-2024', 'jam_buka': '08:30', 'jam_tutup': '11:30'},
];

// --- DATA EDUKASI ---
List<Map<String, dynamic>> globalDataEdukasi = [
  {
    'judul': 'Ketahui 6 Ciri-ciri Anak Sehat',
    'isi': 'Ciri-ciri anak yang mempunyai pertumbuhan baik adalah aktif bergerak, ceria, mata berbinar, nafsu makan baik, dan bibir tampak segar.',
    'foto': '',
  },
  {
    'judul': 'Pentingnya Makanan Gizi Seimbang',
    'isi': 'Memastikan si kecil mendapatkan asupan makanan 4 sehat 5 sempurna setiap hari sangat penting untuk mencegah stunting.',
    'foto': '',
  },
  {
    'judul': 'Pola Makan Sehat Sejak Dini',
    'isi': 'Biasakan anak makan sayur dan buah sejak masa MPASI agar terbiasa hingga dewasa.',
    'foto': '',
  },
];

// --- DATA POSYANDU (PEMERIKSAAN) ---
List<Map<String, dynamic>> globalDataPosyandu = [
  {
    'nama_anak': 'Mevy Kumalasari',
    'tb': '72',
    'bb': '8.5',
    'umur': '9',
    'tgl_posyandu': '12-06-2024',
    'vaksin': ['Hepatitis B', 'BCG'],
    'kondisi': 'Sehat',
  },
  {
    'nama_anak': 'Jihan Kayla',
    'tb': '100',
    'bb': '30',
    'umur': '47',
    'tgl_posyandu': '12-06-2024',
    'vaksin': ['Campak'],
    'kondisi': 'Sehat',
  },
];

// --- DATA PENGATURAN AKUN (ADMIN) ---
List<Map<String, dynamic>> globalDataAkun = [
  {
    'nama': 'Yanuar Ardhika',
    'email': 'ardhikayanuar58@gmail.com',
    'password': '123',
    'jk': 'Laki-laki',
  },
  {
    'nama': 'Rafika Dwi Shefira',
    'email': 'rafika8711@gmail.com',
    'password': '123',
    'jk': 'Perempuan',
  },
  {
    'nama': 'Insan Hidayah',
    'email': 'insan@gmail.com',
    'password': '123',
    'jk': 'Perempuan',
  },
  {
    'nama': 'Herawati Landara',
    'email': 'herawati@gmail.com',
    'password': '123',
    'jk': 'Perempuan',
  },
];