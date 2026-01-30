// FILE: lib/user_features/screens/Ibu_Hamil_page/ibu_hamil_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart'; 

class IbuHamilDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const IbuHamilDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // --- PARSING DATA (SUDAH DISESUAIKAN DENGAN NAMA FIELD ADMIN) ---
    String nama = _getString(data, ['nama', 'nama_ibu']);
    String nik = _getString(data, ['nik', 'nik_ibu']);
    
    String bb = _getString(data, ['berat_badan', 'bb', 'bb_ibu']);
    String tensi = _getString(data, ['tekanan_darah', 'tensi']);
    String usia = _getString(data, ['usia_kehamilan', 'usia_kandungan']);
    String riwayat = _getString(data, ['riwayat_kesehatan', 'keluhan', 'riwayat']);
    String hpl = _getString(data, ['hpl']);
    
    // --- UPDATE PENTING DISINI BANG ---
    // Pastikan key-nya sesuai sama yang di-upload Admin tadi
    String lila = _getString(data, ['lila']); 
    String tfu = _getString(data, ['tinggi_fundus', 'tfu']); // Tambahin 'tinggi_fundus'
    String djj = _getString(data, ['detak_jantung_janin', 'djj']); // Tambahin 'detak_jantung_janin'

    // --- PARSING TANGGAL ---
    String tglStr = '-';
    try {
      if (data['tgl_pemeriksaan'] != null && data['tgl_pemeriksaan'] is Timestamp) {
        tglStr = DateFormat('dd MMMM yyyy').format((data['tgl_pemeriksaan'] as Timestamp).toDate());
      } else if (data['last_update'] != null && data['last_update'] is Timestamp) {
        tglStr = DateFormat('dd MMMM yyyy').format((data['last_update'] as Timestamp).toDate());
      }
    } catch (e) {
      tglStr = "-";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Pemeriksaan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER TANGGAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("NIK: $nik", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  const Divider(),
                  const Text("Tanggal Pemeriksaan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(tglStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // DATA FISIK
            _buildDetailSection("Kondisi Fisik", Icons.accessibility_new, [
              _rowItem("Berat Badan", "$bb Kg"),
              _rowItem("Tekanan Darah", "$tensi mmHg"),
              _rowItem("LILA", "$lila cm"),
            ]),

            const SizedBox(height: 20),

            // DATA KANDUNGAN
            _buildDetailSection("Kondisi Kandungan", Icons.child_care, [
              _rowItem("Usia Kehamilan", "$usia Bulan"),
              _rowItem("HPL (Estimasi)", hpl),
              _rowItem("Tinggi Fundus", "$tfu cm"),
              _rowItem("Detak Jantung Janin", "$djj bpm"),
            ]),

            const SizedBox(height: 20),

            // CATATAN
            _buildDetailSection("Catatan Medis", Icons.medical_services, [
              _colItem("Riwayat Kesehatan / Keluhan", riwayat),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- HELPER FUNCTION UNTUK CEK BANYAK KEY ---
  String _getString(Map<String, dynamic> data, List<String> keys) {
    for (String key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        return data[key].toString();
      }
    }
    return '-';
  }

  // --- WIDGET UI ---
  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _colItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
} 