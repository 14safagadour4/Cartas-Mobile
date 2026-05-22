import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class AILearningDashboardScreen extends StatefulWidget {
  const AILearningDashboardScreen({super.key});

  @override
  State<AILearningDashboardScreen> createState() => _AILearningDashboardScreenState();
}

class _AILearningDashboardScreenState extends State<AILearningDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PhytoLabProvider>(context, listen: false).fetchAIStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final phytoProvider = Provider.of<PhytoLabProvider>(context);
    final stats = phytoProvider.aiStats;
    final List<dynamic> history = stats['history'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text('Intelligence Monitor', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.sage)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.sage),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Performance du Modèle ML", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 8),
            const Text("Suivi en temps réel de l'apprentissage par feedback expert.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // Main Accuracy Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.sage, Color(0xFF66BB6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: AppColors.sage.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Text("Précision Actuelle", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("${(stats['accuracy'] as double).toStringAsFixed(1)}%", 
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text("Optimisé par Human-in-the-loop", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ).animate().scale(delay: 200.ms),

            const SizedBox(height: 30),

            // Courbe d'Amélioration
            const Text("Courbe d'Apprentissage", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 20),
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
              child: history.isEmpty 
                ? const Center(child: Text("Pas assez de données pour le graphique"))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: history.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), (e.value['accuracy'] as num).toDouble());
                          }).toList(),
                          isCurved: true,
                          color: AppColors.sage,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: AppColors.sage.withOpacity(0.1)),
                        ),
                      ],
                    ),
                  ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 30),

            // Secondary Stats
            Row(
              children: [
                Expanded(child: _buildStatCard("Corrections", "${stats['totalValidated']}", Icons.psychology_outlined, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard("Erreur IA", "${(stats['averageError'] as double).toStringAsFixed(1)}%", Icons.error_outline, Colors.orange)),
              ],
            ),

            const SizedBox(height: 30),

            // Explanation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[200]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.sage),
                      SizedBox(width: 10),
                      Text("Comment ça marche ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep(1, "Chaque validation d'expert crée un nouveau point de donnée."),
                  _buildStep(2, "Le modèle Random Forest compare son score avec celui du spécialiste."),
                  _buildStep(3, "L'apprentissage incrémental ajuste les coefficients pour réduire l'erreur."),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStep(int num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 10, backgroundColor: AppColors.sagePale, child: Text("$num", style: const TextStyle(fontSize: 10, color: AppColors.sage, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }
}
