import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class HealthProfileFormScreen extends StatefulWidget {
  const HealthProfileFormScreen({super.key});

  @override
  State<HealthProfileFormScreen> createState() => _HealthProfileFormScreenState();
}

class _HealthProfileFormScreenState extends State<HealthProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PhytoLabProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Progress Bar ──
            _buildProgressBar(1),
            const SizedBox(height: 20),

            // ── Pedagogical Note ──
            _buildInfoCard(
              icon: Icons.info_outline_rounded,
              text: "Ces informations nous permettent de vous donner la recette "
                    "avec la synergie parfaite des plantes adaptée à votre profil de santé.",
            ),
            const SizedBox(height: 24),

            // ── Age Section ──
            _buildSectionCard(
              icon: Icons.favorite_outline,
              title: "Informations personnelles",
              children: [
                _buildLabel("Âge"),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.sage.withOpacity(0.2)),
                  ),
                  child: Text(
                    "${provider.age} ans",
                    style: AppTextStyles.body(16, AppColors.textPrimary, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.sage,
                    inactiveTrackColor: AppColors.sage.withOpacity(0.15),
                    thumbColor: AppColors.sage,
                    overlayColor: AppColors.sage.withOpacity(0.12),
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: provider.age.toDouble(),
                    min: 18,
                    max: 90,
                    divisions: 72,
                    label: provider.age.toString(),
                    onChanged: (val) => provider.updateAge(val.toInt()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Health Conditions Section ──
            _buildSectionCard(
              icon: Icons.science_outlined,
              title: "État de santé",
              children: [
                _buildCheckRow("Enceinte / allaitante", provider.isPregnant, (v) => provider.togglePregnancy(v)),
                _buildCheckRow("Diabète", provider.hasDiabetes, (v) => provider.toggleDiabetes(v)),
                _buildCheckRow("Hypertension", provider.hasHypertension, (v) => provider.toggleHypertension(v)),
                _buildCheckRow("Sous anticoagulants", provider.usesAnticoagulants, (v) => provider.toggleAnticoagulants(v)),
              ],
            ),
            const SizedBox(height: 16),

            // ── Medications Section ──
            _buildSectionCard(
              icon: Icons.medication_outlined,
              title: "Médicaments en cours",
              subtitle: "(nombre de médicaments par jour)",
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterButton(Icons.remove, () {
                      if (provider.medicationsCount > 0) {
                        provider.updateMedicationsCount(provider.medicationsCount - 1);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "${provider.medicationsCount}",
                        style: AppTextStyles.title(28, AppColors.textPrimary),
                      ),
                    ),
                    _buildCounterButton(Icons.add, () {
                      provider.updateMedicationsCount(provider.medicationsCount + 1);
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Goal Section ──
            _buildSectionCard(
              icon: Icons.auto_awesome_outlined,
              title: "Objectif de votre remède",
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildGoalChip("Sommeil", "Sleep", Icons.bedtime_outlined, provider),
                    _buildGoalChip("Énergie", "Energy", Icons.bolt_outlined, provider),
                    _buildGoalChip("Anti-stress", "Stress", Icons.spa_outlined, provider),
                    _buildGoalChip("Digestion", "Digestion", Icons.restaurant_outlined, provider),
                    _buildGoalChip("Immunité", "Immunity", Icons.shield_outlined, provider),
                    _buildGoalChip("Douleur", "Pain", Icons.healing_outlined, provider),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ── Continue Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.push('/plant-selector'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Continuer", style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
          Text("Étape 1/3 · Votre profil", style: AppTextStyles.body(12, AppColors.sage)),
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

  // ── Progress Bar ──
  Widget _buildProgressBar(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;
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

  // ── Info Card ──
  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sage.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sage.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.sage, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.body(13, AppColors.textPrimary, weight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── Section Card ──
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.roseMid, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body(15, AppColors.textPrimary, weight: FontWeight.w700)),
                    if (subtitle != null)
                      Text(subtitle, style: AppTextStyles.body(11, AppColors.textMuted, weight: FontWeight.w400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ── Label ──
  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.body(13, AppColors.textMuted, weight: FontWeight.w500));
  }

  // ── Check Row ──
  Widget _buildCheckRow(String title, bool value, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(title, style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w500)),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.sage : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: value ? AppColors.sage : Colors.grey.shade300, width: 2),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Counter Button ──
  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.sage.withOpacity(0.3)),
          ),
          child: Icon(icon, color: AppColors.sage, size: 22),
        ),
      ),
    );
  }

  // ── Goal Chip ──
  Widget _buildGoalChip(String label, String value, IconData icon, PhytoLabProvider provider) {
    final bool isSelected = provider.currentGoal == value;
    return GestureDetector(
      onTap: () => provider.updateGoal(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sage.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.sage : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.sage : Colors.grey.shade500, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.body(
                11,
                isSelected ? AppColors.sage : Colors.grey.shade600,
                weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
