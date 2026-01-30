// FILE: lib/user_features/screens/Vaksin/list_vaksin_user_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/colors.dart'; // Pastikan path colors bener (sesuain sama file lu)

class ListVaksinUserPage extends StatefulWidget {
  const ListVaksinUserPage({super.key});

  @override
  State<ListVaksinUserPage> createState() => _ListVaksinUserPageState();
}

class _ListVaksinUserPageState extends State<ListVaksinUserPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background agak abu dikit biar modern
      appBar: AppBar(
        title: const Text(
          "Daftar Vaksin Tersedia",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor, // Pakai warna Pink User
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // HEADER SEARCH
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Cari informasi vaksin...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),

          // LIST VAKSIN
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Baca dari collection yang sama dengan Admin
              stream: FirebaseFirestore.instance.collection('jenis_vaksin').orderBy('nama_vaksin').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var docs = snapshot.data?.docs ?? [];

                // Filter Search
                if (_searchCtrl.text.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return data['nama_vaksin'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase());
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.vaccines_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Belum ada data vaksin", style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50, // Aksen Orange/Kuning biar beda dikit
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.vaccines, color: Colors.orange.shade700, size: 28),
                        ),
                        title: Text(
                          data['nama_vaksin'] ?? "Tanpa Nama",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            data['deskripsi'] ?? "Tersedia di Posyandu.",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Bisa ditambah trailing arrow kalau mau ada detail page lagi
                        // trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}