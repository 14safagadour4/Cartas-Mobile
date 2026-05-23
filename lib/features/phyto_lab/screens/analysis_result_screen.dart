import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisResultScreen extends StatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PhytoLabProvider>(context, listen: false).runAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PhytoLabProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDE4E4),
      appBar: AppBar(
        title: const Text('Résultat de l\'Analyse', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: provider.isLoading
          ? _buildLoadingState()
          : provider.analysisResult == null
              ? _buildErrorState()
              : _buildResults(provider),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFF85A1)),
          const SizedBox(height: 20),
          const Text(
            "Virtual Phyto Lab analyse votre mélange...",
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xFF6D4C41)),
          ),
          const SizedBox(height: 10),
          const Text("Calcul des synergies et vérification du profil santé", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(child: Text("Oups ! Une erreur est survenue lors de l'analyse."));
  }

  Widget _buildResults(PhytoLabProvider provider) {
    final result = provider.analysisResult!;
    final double score = (result['overall_score'] ?? 0.0).toDouble();
    final Map<String, dynamic> effects = result['effects'] ?? {};
    final recipe = result['recipe'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Global Score Card (Centered)
          Center(child: _buildScoreCard(score)),
          const SizedBox(height: 25),

          // Effects Chart
          const Text("Effets Attendus", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
          const SizedBox(height: 15),
          _buildEffectsChart(effects),
          const SizedBox(height: 30),

          // Personalized Recipe Card
          _buildRecipeCard(recipe),
          const SizedBox(height: 30),

          // SHAP/AI Explanations (Summary)
          const Text("L'avis de l'IA (Virtual Phyto Lab)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
          const SizedBox(height: 15),
          _buildAiExplanations(result['plantAnalyses'] ?? []),
          
          const SizedBox(height: 40),

          // Action Buttons
          ElevatedButton.icon(
            onPressed: provider.isLoading 
              ? null 
              : () async {
                  // Navigate to specialist selection screen
                  context.push('/select-specialist');
                },
            icon: provider.isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send_rounded),
            label: Text(
              provider.isLoading ? "Envoi en cours..." : "Envoyer pour Validation Spécialiste",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF85A1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              side: const BorderSide(color: Color(0xFFFF85A1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Modifier le mélange", style: TextStyle(color: Color(0xFFFF85A1))),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildScoreCard(double score) {
    Color scoreColor = score > 70 ? Colors.green : (score > 40 ? Colors.orange : Colors.red);
    String message = score > 70 ? "Excellente Synergie !" : (score > 40 ? "Combinaison Moyenne" : "Attention : Risque d'interaction");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  color: scoreColor,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
              Text("${score.toInt()}%", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: scoreColor)),
            ],
          ),
          const SizedBox(height: 15),
          Text(message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scoreColor)),
        ],
      ),
    );
  }

  Widget _buildEffectsChart(Map<String, dynamic> effects) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: const Color(0xFFFF85A1).withOpacity(0.4),
              borderColor: const Color(0xFFFF85A1),
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: (effects['energy_effect'] ?? 0.0).toDouble()),
                RadarEntry(value: (effects['sleep_effect'] ?? 0.0).toDouble()),
                RadarEntry(value: (effects['digestion_effect'] ?? 0.0).toDouble()),
                RadarEntry(value: (effects['immunity_effect'] ?? 0.0).toDouble()),
                RadarEntry(value: (effects['pain_effect'] ?? 0.0).toDouble()),
                RadarEntry(value: (effects['stress_effect'] ?? 0.0).toDouble()),
              ],
            ),
          ],
          radarShape: RadarShape.circle,
          getTitle: (index, angle) {
            switch (index) {
              case 0: return const RadarChartTitle(text: 'Énergie');
              case 1: return const RadarChartTitle(text: 'Sommeil');
              case 2: return const RadarChartTitle(text: 'Digestion');
              case 3: return const RadarChartTitle(text: 'Immunité');
              case 4: return const RadarChartTitle(text: 'Douleur');
              case 5: return const RadarChartTitle(text: 'Stress');
              default: return const RadarChartTitle(text: '');
            }
          },
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons. coffee_maker_outlined, color: Colors.white),
              SizedBox(width: 10),
              Text("Ma Recette Personnalisée", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white30, height: 30),
          Text(recipe['title'] ?? "Infusion Synergie", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildRecipeSection("🌿 Ingrédients", recipe['ingredients'] ?? ""),
          _buildRecipeSection("🥣 Préparation", recipe['preparation'] ?? ""),
          _buildRecipeSection("⏰ Dosage", recipe['dosage'] ?? ""),
        ],
      ),
    );
  }

  Widget _buildRecipeSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFFFB7C5), fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(content, style: const TextStyle(color: Colors.white, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildAiExplanations(List<dynamic> analyses) {
    return Column(
      children: analyses.map((a) {
        final List<dynamic> advantages = a['advantages'] as List? ?? [];
        final List<dynamic> inconvenients = a['inconvenients'] as List? ?? [];
        final List<dynamic> warnings = a['warnings'] as List? ?? [];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8)
              )
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              ),
              title: Text(
                a['plantName'] ?? "Plante",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color(0xFF2D3436)),
              ),
              subtitle: Text(
                "Impact synergie: ${(a['contribution'] ?? 0.0).toStringAsFixed(1)}%",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      
                      // SECTION AVANTAGES (PROS)
                      _buildTransparentSection(
                        title: "Avantages (Pros)",
                        items: advantages,
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF4CAF50),
                        bgColor: const Color(0xFFE8F5E9),
                      ),
                      
                      const SizedBox(height: 20),
            
                      // SECTION INCONVÉNIENTS (CONS)
                      _buildTransparentSection(
                        title: "Inconvénients (Cons)",
                        items: inconvenients,
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFE67E22),
                        bgColor: const Color(0xFFFFF3E0),
                      ),
                      
                      if (warnings.isNotEmpty && warnings.first != "Usage sécurisé") ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Note technique : ${warnings.first}",
                                  style: const TextStyle(fontSize: 12, color: Colors.blue, fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransparentSection({
    required String title,
    required List<dynamic> items,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  item.toString(),
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 14, height: 1.3),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
