import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/colors.dart'; 
import 'grafik_detail_screen.dart'; 

class UserGrafikPage extends StatefulWidget {
  const UserGrafikPage({super.key});

  @override
  State<UserGrafikPage> createState() => _UserGrafikPageState();
}

class _UserGrafikPageState extends State<UserGrafikPage> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Anda belum login")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pilih Anak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Membaca dari collection 'data_anak' di root
        stream: FirebaseFirestore.instance
            .collection('data_anak') 
            .where('parent_uid', isEqualTo: uid) // Filter user login
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("Belum ada data anak", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          var dataAnak = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: dataAnak.length,
            itemBuilder: (context, index) {
              var anak = dataAnak[index].data() as Map<String, dynamic>;
              String anakId = dataAnak[index].id; 

              // --- PERBAIKAN DI SINI (SESUAI DATABASE) ---
              String namaAnak = anak['nama'] ?? 'Tanpa Nama'; // Pakai field 'nama'
              String jenisKelamin = anak['jk'] ?? 'Laki-laki'; // Pakai field 'jk'

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    child: Icon(
                      // Logika icon berdasarkan jenis kelamin
                      (jenisKelamin == 'Laki-laki' || jenisKelamin == 'Laki-Laki') 
                          ? Icons.face 
                          : Icons.face_3, 
                      color: AppColors.primaryColor
                    ),
                  ),
                  title: Text(
                    namaAnak,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text("Lihat Grafik Pertumbuhan", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GrafikDetailScreen(
                          namaAnak: namaAnak,
                          anakId: anakId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}