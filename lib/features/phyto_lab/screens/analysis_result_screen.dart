import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cartas/core/services/local_state_service.dart';

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
      backgroundColor: AppColors.cream,
      appBar: _buildAppBar(context),
      body: provider.isLoading
          ? _buildLoadingState()
          : provider.analysisResult == null
              ? _buildErrorState()
              : _buildResults(provider),
    );
  }

  // ── AppBar ──
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text("Virtual Phyto Lab", style: AppTextStyles.title(18, AppColors.textPrimary)),
          Text("Étape 3/3 · Analyse & recette", style: AppTextStyles.body(12, AppColors.sage)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.roseMid),
          tooltip: "Mes Remèdes",
          onPressed: () => context.push('/my-remedies'),
        ),
      ],
    );
  }

  // ── Loading ──
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress bar at top
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildProgressBar(3),
          ),
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.sage.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.sage, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Analyse en cours...",
            style: AppTextStyles.title(20, AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            "Calcul des synergies et vérification\ndu profil santé",
            textAlign: TextAlign.center,
            style: AppTextStyles.body(14, AppColors.textMuted, weight: FontWeight.w500),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // ── Error ──
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.roseMid),
          const SizedBox(height: 16),
          Text("Une erreur est survenue", style: AppTextStyles.body(16, AppColors.textPrimary, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text("Veuillez réessayer", style: AppTextStyles.body(14, AppColors.textMuted)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sage, foregroundColor: Colors.white),
            child: const Text("Retour"),
          ),
        ],
      ),
    );
  }

  // ── Results ──
  Widget _buildResults(PhytoLabProvider provider) {
    final result = provider.analysisResult!;
    final double score = (result['overall_score'] ?? 0.0).toDouble();
    final Map<String, dynamic> effects = result['effects'] ?? {};
    final recipe = result['recipe'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progress Bar ──
          _buildProgressBar(3),
          const SizedBox(height: 20),

          // ── Score Card ──
          _buildScoreCard(score),
          const SizedBox(height: 24),

          // ── Effects Bars (Replaces Radar Chart) ──
          _buildSectionTitle("Effets attendus de votre mélange"),
          const SizedBox(height: 12),
          _buildEffectsBars(effects),
          const SizedBox(height: 24),

          // ── Detailed Plant Analysis (Merges Participation & AI Explanations) ──
          _buildSectionTitle("Analyse détaillée par plante"),
          const SizedBox(height: 12),
          _buildDetailedPlantAnalysis(result['plantAnalyses'] ?? []),
          const SizedBox(height: 24),

          // ── Security Alerts ──
          _buildSecurityAlerts(result['plantAnalyses'] ?? []),

          // ── Recipe Card ──
          _buildRecipeCard(recipe),
          const SizedBox(height: 30),

          // ── Action Buttons ──
          _buildActionButtons(provider, recipe),
        ],
      ),
    );
  }

  // ── Progress Bar ──
  Widget _buildProgressBar(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.sage : AppColors.sage.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // ── Section Title ──
  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.body(17, AppColors.textPrimary, weight: FontWeight.w700));
  }

  // ── Score Card ──
  Widget _buildScoreCard(double score) {
    Color scoreColor = score > 70 ? AppColors.sage : (score > 40 ? Colors.orange : AppColors.roseMid);
    String message = score > 70 ? "Excellente synergie !" : (score > 40 ? "À ajuster" : "Attention : risque");
    IconData badgeIcon = score > 70 ? Icons.check_circle : (score > 40 ? Icons.warning_amber_rounded : Icons.error_outline);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text("Score de synergie", style: AppTextStyles.body(13, AppColors.textMuted, weight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text("${score.toInt()}%", style: AppTextStyles.title(48, scoreColor)),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: scoreColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, size: 16, color: scoreColor),
                const SizedBox(width: 6),
                Text(message, style: AppTextStyles.body(13, scoreColor, weight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Detailed Plant Analysis (Merges Participation & AI Explanations) ──
  Widget _buildDetailedPlantAnalysis(List<dynamic> analyses) {
    return Column(
      children: analyses.map((a) {
        final contribution = (a['contribution'] ?? 0.0).toDouble();
        final List<dynamic> advantages = a['advantages'] as List? ?? [];
        final List<dynamic> inconvenients = a['inconvenients'] as List? ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.sage.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lavande.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco, size: 16, color: AppColors.lavandeDeep),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(a['plantName'] ?? "Plante", style: AppTextStyles.body(16, AppColors.textPrimary, weight: FontWeight.w700)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sage.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("${contribution.toInt()}% synergie", style: AppTextStyles.body(12, AppColors.sage, weight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (advantages.isNotEmpty)
                _buildTaggedSection("Avantages", advantages, Icons.check_circle_outline, AppColors.sage, AppColors.sage.withOpacity(0.08)),
              if (inconvenients.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildTaggedSection("Inconvénients / Attention", inconvenients, Icons.warning_amber_rounded, Colors.orange, Colors.orange.withOpacity(0.08)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Security Alerts ──
  Widget _buildSecurityAlerts(List<dynamic> analyses) {
    final alerts = <String>[];
    for (var a in analyses) {
      final warnings = (a['warnings'] as List?) ?? [];
      for (var w in warnings) {
        if (w.toString() != "Usage sécurisé") {
          alerts.add("${a['plantName']} — $w");
        }
      }
    }
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text("Alertes de sécurité (${alerts.length})",
                      style: AppTextStyles.body(14, Colors.orange.shade800, weight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• $alert", style: AppTextStyles.body(12, Colors.orange.shade900, weight: FontWeight.w500)),
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ── Effects Bars (Replaces Radar Chart) ──
  Widget _buildEffectsBars(Map<String, dynamic> effects) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          _buildEffectBar("Sommeil", (effects['sleep_effect'] ?? 0.0).toDouble(), AppColors.lavandeVif),
          const SizedBox(height: 16),
          _buildEffectBar("Énergie", (effects['energy_effect'] ?? 0.0).toDouble(), Colors.orange.shade400),
          const SizedBox(height: 16),
          _buildEffectBar("Digestion", (effects['digestion_effect'] ?? 0.0).toDouble(), AppColors.sage),
          const SizedBox(height: 16),
          _buildEffectBar("Immunité", (effects['immunity_effect'] ?? 0.0).toDouble(), Colors.blue.shade400),
          const SizedBox(height: 16),
          _buildEffectBar("Anti-stress", (effects['stress_effect'] ?? 0.0).toDouble(), AppColors.roseMid),
          const SizedBox(height: 16),
          _buildEffectBar("Douleur", (effects['pain_effect'] ?? 0.0).toDouble(), Colors.red.shade400),
        ],
      ),
    );
  }

  Widget _buildEffectBar(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w600)),
            Text("${value.toInt()}%", style: AppTextStyles.body(14, color, weight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ── Recipe Card ──
  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sage.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lavande.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_florist_outlined, color: AppColors.lavandeDeep, size: 20),
              ),
              const SizedBox(width: 12),
              Text("RECETTE PERSONNALISÉE", style: AppTextStyles.body(12, AppColors.lavandeDeep, weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recipe['title'] ?? "Infusion Synergie",
            style: AppTextStyles.title(20, AppColors.textPrimary),
          ),
          const Divider(height: 28),
          _buildRecipeSection("INGRÉDIENTS", recipe['ingredients'] ?? ""),
          _buildRecipeSection("PRÉPARATION", recipe['preparation'] ?? ""),
          _buildRecipeSection("POSOLOGIE", recipe['dosage'] ?? ""),
        ],
      ),
    );
  }

  Widget _buildRecipeSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body(11, AppColors.roseMid, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(content, style: AppTextStyles.body(13, AppColors.textPrimary, weight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTaggedSection(String title, List<dynamic> items, IconData icon, Color color, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(title, style: AppTextStyles.body(13, color, weight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Expanded(child: Text(item.toString(), style: AppTextStyles.body(12, color.withOpacity(0.85), weight: FontWeight.w500))),
            ],
          ),
        )),
      ],
    );
  }

  // ── Action Buttons ──
  Widget _buildActionButtons(PhytoLabProvider provider, Map<String, dynamic> recipe) {
    return Column(
      children: [
        // Primary: Send to Specialist
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () => context.push('/select-specialist'),
            icon: provider.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(
              provider.isLoading ? "Envoi en cours..." : "Envoyer au Spécialiste",
              style: AppTextStyles.body(15, Colors.white, weight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sage,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Save Remedy
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () async {
                    bool success = await provider.saveAnalysisAsRemedy(null);
                    // Save to local storage
                    final recipeToSave = Map<String, dynamic>.from(recipe);
                    recipeToSave['createdAt'] = DateTime.now().toIso8601String();
                    await LocalStateService.saveRecipe(recipeToSave);

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Remède sauvegardé avec succès ! ✅",
                              style: AppTextStyles.body(14, Colors.white, weight: FontWeight.w600)),
                          backgroundColor: AppColors.sage,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.bookmark_outline_rounded, size: 20),
            label: Text("Sauvegarder mon remède",
                style: AppTextStyles.body(14, AppColors.sage, weight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.sage,
              side: BorderSide(color: AppColors.sage.withOpacity(0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tertiary: Modify Mix
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text("Modifier le mélange", style: AppTextStyles.body(14, AppColors.textMuted, weight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 8),

        // Link: My Remedies
        TextButton(
          onPressed: () => context.push('/my-remedies'),
          child: Text("📋  Voir mes remèdes créés", style: AppTextStyles.body(13, AppColors.roseMid, weight: FontWeight.w600)),
        ),
      ],
    );
  }
}
