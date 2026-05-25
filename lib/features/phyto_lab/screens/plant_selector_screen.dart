import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/herbier/providers/plant_provider.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class PlantSelectorScreen extends StatefulWidget {
  const PlantSelectorScreen({super.key});

  @override
  State<PlantSelectorScreen> createState() => _PlantSelectorScreenState();
}

class _PlantSelectorScreenState extends State<PlantSelectorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plantProvider = Provider.of<PlantProvider>(context, listen: false);
      if (plantProvider.plants.isEmpty) {
        plantProvider.fetchPlants();
      }
      Provider.of<PhytoLabProvider>(context, listen: false).warmupIA();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantProvider>(context);
    final labProvider = Provider.of<PhytoLabProvider>(context);
    final selectedCount = labProvider.selectedPlants.length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // ── Progress Bar + Info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressBar(2),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.eco_outlined,
                  text: "Sélectionnez entre 2 et 4 plantes de l'herbier. Notre IA analysera "
                        "leur synergie et créera votre recette personnalisée.",
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Selected Plants Section ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    const Icon(Icons.science_outlined, size: 16, color: AppColors.lavandeDeep),
                    const SizedBox(width: 8),
                    Text(
                      "Votre mélange ($selectedCount/4) — min. 2",
                      style: AppTextStyles.body(13, AppColors.textPrimary, weight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Selected Plants Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...labProvider.selectedPlants.map((plant) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.sage.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        plant.imagePath,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: AppColors.sage),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: GestureDetector(
                                      onTap: () => labProvider.togglePlantSelection(plant),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 10, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  plant.name,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body(11, AppColors.textPrimary, weight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Add Button (if < 4)
                      if (selectedCount < 4)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300, width: 1.5), // Replace dashed with solid for simplicity
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  "Ajouter",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body(11, Colors.grey, weight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // ── Title "Plantes disponibles" ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Plantes disponibles", style: AppTextStyles.title(18, AppColors.textPrimary)),
            ),
          ),
          const SizedBox(height: 12),

          // ── Plant Grid ──
          Expanded(
            child: plantProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.sage))
                : plantProvider.plants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco_outlined, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text("Aucune plante trouvée",
                                style: AppTextStyles.body(16, AppColors.textMuted)),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => plantProvider.fetchPlants(),
                              child: Text("Réessayer",
                                  style: AppTextStyles.body(14, AppColors.sage, weight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: plantProvider.plants.length,
                        itemBuilder: (context, index) {
                          final plant = plantProvider.plants[index];
                          final bool isSelected = labProvider.selectedPlants.contains(plant);

                          return GestureDetector(
                            onTap: () => labProvider.togglePlantSelection(plant),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.sage.withOpacity(0.15) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? AppColors.sage : Colors.grey.shade200,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: [
                                  if (!isSelected)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Image.asset(
                                        plant.imagePath,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 40, color: AppColors.sage),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          plant.name,
                                          style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          plant.nameLatin,
                                          style: AppTextStyles.body(11, isSelected ? AppColors.sage : AppColors.textMuted, weight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // ── Bottom Analyze Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: selectedCount >= 2 ? () => context.push('/analysis-result') : null,
                icon: Icon(
                  selectedCount >= 2 ? Icons.auto_awesome : Icons.touch_app_outlined,
                  size: 20,
                ),
                label: Text(
                  selectedCount < 2
                      ? "Sélectionnez au moins 2 plantes"
                      : "Analyser le mélange ✨",
                  style: AppTextStyles.body(15, Colors.white, weight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ],
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
          Text("Étape 2/3 · Choix des plantes", style: AppTextStyles.body(12, AppColors.sage)),
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
}
