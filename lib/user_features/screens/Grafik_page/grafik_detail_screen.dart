// lib/screens/grafik_detail_screen.dart
import 'package:flutter/material.dart';
import '../../core/colors.dart';

class GrafikDetailScreen extends StatelessWidget {
  final String namaAnak;

  const GrafikDetailScreen({super.key, required this.namaAnak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor, // Header Pink
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          namaAnak,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Header Card
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Grafik Pertumbuhan dan Perkembangan Anak",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Grafik Berat Badan (Biru)
            _buildChartSection(
              title: "Grafik Perkembangan Berat Badan Anak",
              yLabel: "Berat Badan (kg)",
              barColor: Colors.blue,
              value: 2.0, // Contoh data: 2 kg
              maxValue: 3.0,
              month: "Jun",
            ),

            const SizedBox(height: 20),

            // 3. Grafik Tinggi Badan (Hijau)
            _buildChartSection(
              title: "Grafik Perkembangan Tinggi Badan Anak",
              yLabel: "Tinggi Badan (cm)",
              barColor: Colors.green,
              value: 75.0, // Contoh data: 75 cm
              maxValue: 100.0,
              month: "Jun",
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bikin Grafik Batang Manual (Tanpa Library)
  Widget _buildChartSection({
    required String title,
    required String yLabel,
    required Color barColor,
    required double value,
    required double maxValue,
    required String month,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink.shade50, // Background chart agak pink dikit
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(yLabel, style: TextStyle(color: barColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // Area Grafik
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Sumbu Y (Angka)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${maxValue.toInt()}", style: const TextStyle(fontSize: 10)),
                        Text("${(maxValue/2).toInt()}", style: const TextStyle(fontSize: 10)),
                        const Text("0", style: TextStyle(fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Garis Vertikal
                    Container(width: 1, color: Colors.grey.shade300),
                    
                    // Batang Grafik
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Garis Horizontal background
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Divider(color: Colors.grey.shade200),
                              Divider(color: Colors.grey.shade200),
                              Divider(color: Colors.grey.shade200),
                            ],
                          ),
                          // Batangnya
                          FractionallySizedBox(
                            heightFactor: value / maxValue, // Hitung tinggi berdasarkan data
                            widthFactor: 0.5, // Lebar batang
                            child: Container(
                              color: barColor,
                              child: Tooltip(
                                message: "$value",
                                child: const SizedBox(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Sumbu X (Bulan)
              Center(child: Text(month, style: const TextStyle(fontSize: 12))),
            ],
          ),
        ),
      ],
    );
  }
}