// FILE: lib/user_features/screens/Grafik_page/grafik_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../../core/colors.dart'; 

class GrafikDetailScreen extends StatefulWidget {
  final String namaAnak;
  final String anakId; 

  const GrafikDetailScreen({
    super.key, 
    required this.namaAnak,
    required this.anakId,
  });

  @override
  State<GrafikDetailScreen> createState() => _GrafikDetailScreenState();
}

class _GrafikDetailScreenState extends State<GrafikDetailScreen> {
  String selectedType = "BB"; 

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Grafik: ${widget.namaAnak}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. FILTER BB/TB
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildFilterBtn("Berat Badan (BB)", "BB")),
                  const SizedBox(width: 5),
                  Expanded(child: _buildFilterBtn("Tinggi Badan (TB)", "TB")),
                ],
              ),
            ),
          ),

          // 2. GRAFIK SCROLLABLE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('data_kesehatan_anak') 
                  .where('child_id', isEqualTo: widget.anakId) 
                  .snapshots(),
              builder: (context, snapshot) {
                // A. LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // B. DATA KOSONG
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.show_chart, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Belum ada data pemeriksaan kesehatan", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // C. OLAH DATA
                List<FlSpot> spots = [];
                double maxY = 0;
                double maxX = 0; // Buat nentuin lebar scroll

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  
                  double x = _safeDouble(data['umur_bulan']); 
                  double y = (selectedType == "BB") 
                      ? _safeDouble(data['bb']) 
                      : _safeDouble(data['tb']);

                  if (y > 0) {
                    spots.add(FlSpot(x, y));
                    if (y > maxY) maxY = y;
                    if (x > maxX) maxX = x;
                  }
                }

                spots.sort((a, b) => a.x.compareTo(b.x));

                if (spots.isEmpty) {
                  return const Center(child: Text("Data tersedia tapi nilainya 0"));
                }

                // --- PERHITUNGAN LEBAR GRAFIK DINAMIS ---
                // Minimal lebar layar, tapi kalau datanya banyak (misal umur sampe 24 bulan),
                // kita lebarin biar bisa discroll.
                // Logika: Tiap 1 bulan umur = 50 pixel lebar.
                double chartWidth = (maxX * 50.0); 
                if (chartWidth < MediaQuery.of(context).size.width) {
                  chartWidth = MediaQuery.of(context).size.width; // Minimal selebar layar
                }

                return Column(
                  children: [
                    Text(
                      "Grafik berdasarkan Umur (Bulan)", 
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)
                    ),
                    const SizedBox(height: 10),
                    
                    // --- PEMBUNGKUS SCROLL HORIZONTAL ---
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Scroll ke Samping
                        child: Container(
                          width: chartWidth, // Lebar dinamis
                          padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
                          child: LineChart(
                            LineChartData(
                              minX: spots.first.x,
                              maxX: maxX + 1, // Tambah space dikit di ujung kanan
                              minY: 0,
                              maxY: maxY * 1.2, 
                              
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 5,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                                getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                              ),
                              
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1, 
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text("${value.toInt()} Bln", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: 5,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        "${value.toInt()} ${selectedType == 'BB' ? 'kg' : 'cm'}",
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true, // Garis melengkung halus
                                  color: selectedType == "BB" ? Colors.blueAccent : Colors.pinkAccent,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true), // Titik data
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: (selectedType == "BB" ? Colors.blueAccent : Colors.pinkAccent).withOpacity(0.15),
                                  ),
                                ),
                              ],
                              
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.blueGrey,
                                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                    return touchedBarSpots.map((barSpot) {
                                      return LineTooltipItem(
                                        'Umur ${barSpot.x.toInt()} Bln\n',
                                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                            text: '${barSpot.y} ${selectedType == 'BB' ? 'kg' : 'cm'}',
                                            style: const TextStyle(color: Colors.yellowAccent),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String label, String value) {
    bool isActive = selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => selectedType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}