import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';
import '../widgets/plant_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/herbier_search_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class HerbierScreen extends StatefulWidget {
  const HerbierScreen({super.key});

  @override
  State<HerbierScreen> createState() => _HerbierScreenState();
}

class _HerbierScreenState extends State<HerbierScreen> {
  PlantCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final plantProvider = context.watch<PlantProvider>();
    final plantsData = plantProvider.plants;
    final isLoading = plantProvider.isLoading;

    // Filtrage des plantes
    final filteredPlants = plantsData.where((plant) {
      final matchesCategory = _selectedCategory == null || plant.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          plant.name.toLowerCase().contains(query) ||
          plant.nameAr.contains(_searchQuery) ||
          plant.nameLatin.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Back + Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.rosePale.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.roseDeep),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Herbier Digital', style: AppTextStyles.title(24, AppColors.roseDeep)),
                      Text('30 plantes du patrimoine tunisien', 
                        style: AppTextStyles.body(11, AppColors.textMuted, weight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: HerbierSearchBar(
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            // Category Chips
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  CategoryChip(
                    label: 'Toutes', 
                    icon: '🌿', 
                    isSelected: _selectedCategory == null, 
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...PlantCategory.values.map((cat) {
                    return CategoryChip(
                      category: cat,
                      label: cat.label.replaceAll('\n', ' '),
                      icon: cat.icon,
                      isSelected: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    );
                  }),
                ],
              ),
            ),

            // Items Count
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
              child: Text(
                '${filteredPlants.length} plantes trouvées',
                style: AppTextStyles.body(12, AppColors.roseMid.withOpacity(0.8), weight: FontWeight.w700),
              ),
            ),

            // Grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.roseDeep))
                  : plantProvider.error.isNotEmpty
                      ? Center(child: Text(plantProvider.error, style: AppTextStyles.body(14, Colors.red)))
                      : filteredPlants.isEmpty
                          ? Center(child: Text("Aucune plante trouvée.", style: AppTextStyles.body(14, AppColors.textMuted)))
                          : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: filteredPlants.length,
                          itemBuilder: (context, index) {
                            final plant = filteredPlants[index];
                            return PlantCard(
                              plant: plant,
                              onTap: () => context.pushNamed('plant-detail', extra: plant),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}