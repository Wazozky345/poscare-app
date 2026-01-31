import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Tambahkan ini
import 'package:poscare/user_features/screens/Grafik_page/grafik_screen.dart';
import 'package:poscare/user_features/screens/Ibu_Hamil_page/user_ibu_hamil_page.dart';
import 'package:poscare/user_features/screens/Vaksin/list_vaksin_user_page.dart'; 
import 'package:poscare/user_features/screens/Edukasi_page/edukasi_screen.dart';
import '../../core/colors.dart';

// Ubah ke StatefulWidget agar bisa menjalankan initToken()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    // Jalankan pengambilan token saat home terbuka
    _setupPushNotifications();
  }

  // ==========================================
  // LOGIKA NOTIFIKASI (SIMPAN TOKEN KE FIRESTORE)
  // ==========================================
  Future<void> _setupPushNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Minta Izin Notifikasi
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Ambil Token Perangkat (FCM Token)
      String? token = await messaging.getToken();

      if (token != null) {
        // 3. Simpan token ke dokumen user di Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastUpdateToken': FieldValue.serverTimestamp(),
        });
        print("FCM Token Berhasil Disimpan: $token");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_poscare.png', 
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.local_hospital, color: AppColors.primaryColor, size: 30);
              },
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Poscare", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Layanan Posyandu Digital", style: TextStyle(color: Colors.grey, fontSize: 10)), 
              ],
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(uid),
            const SizedBox(height: 25),
            const Text("Layanan Poscare", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildMenuItem(context, "Ibu Hamil", Icons.pregnant_woman, Colors.pink, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserIbuHamilPage()));
                }),
                _buildMenuItem(context, "Anak", Icons.show_chart, Colors.blue, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserGrafikPage()));
                }),
                _buildMenuItem(context, "Vaksin", Icons.vaccines, Colors.orange, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ListVaksinUserPage()));
                }),
                _buildMenuItem(context, "Artikel", Icons.newspaper, Colors.green, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EdukasiScreen()));
                }),
              ],
            ),
            
            const SizedBox(height: 25),
            const Text("Jadwal Posyandu Terdekat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            _buildUpcomingScheduleCard(), 
            
            const SizedBox(height: 25),
            const Text("Data Anak Saya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            _buildDataAnakList(context, uid), 
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG (Tetap sama namun dipindahkan ke dalam State) ---
  
  Widget _buildUpcomingScheduleCard() {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jadwal_posyandu')
          .where('tanggal_date', isGreaterThanOrEqualTo: todayStart)
          .orderBy('tanggal_date') 
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.event_busy, color: Colors.orange),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tidak Ada Jadwal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Belum ada jadwal posyandu terdekat.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          );
        }

        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        String tanggal = data['tanggal_str'] ?? '-';
        String jam = "${data['jam_mulai']} - ${data['jam_selesai']} WIB";

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFF0F3), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calendar_month, color: Color(0xFFFF4081)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tanggal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(jam, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- Tambahkan Fungsi detailRow & detailPopup di sini agar bisa diakses ---
  void _showChildDetailUser(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: (data['jk'] == 'Laki-laki') ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
              child: Icon(
                (data['jk'] == 'Laki-laki') ? Icons.face : Icons.face_3,
                size: 35,
                color: (data['jk'] == 'Laki-laki') ? Colors.blue : Colors.pink,
              ),
            ),
            const SizedBox(height: 10),
            Text(data['nama'] ?? "Anak", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow("NIK", data['nik']),
            _detailRow("Jenis Kelamin", data['jk']),
            _detailRow("TB / BB", "${data['tb']}cm / ${data['bb']}kg"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDataAnakList(BuildContext context, String? uid) {
    if (uid == null) return const Text("Silahkan login ulang.");
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data_anak')
          .where('parent_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return InkWell( 
              onTap: () => _showChildDetailUser(context, data),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    CircleAvatar(child: const Icon(Icons.face)),
                    const SizedBox(width: 15),
                    Text(data['nama'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeCard(String? uid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryColor, Color(0xFFE91E63)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 14)),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              String nama = "User";
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>?; 
                nama = data?['nama'] ?? "User";
              }
              return Text(nama, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
            },
          ),
          const SizedBox(height: 10),
          const Text("Semoga kesehatan Anda selalu terjaga hari ini.", style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}