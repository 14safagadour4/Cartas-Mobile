import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/trousse_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TrousseScreen extends StatelessWidget {
  const TrousseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trousseProvider = context.watch<TrousseProvider>();
    final trousse = trousseProvider.trousse;

    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.roseDeep),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ma Trousse Naturelle', style: AppTextStyles.title(22, AppColors.roseDeep)),
                      Text('Votre pharmacie personnalisée CARTAS', style: AppTextStyles.body(11, AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                   _buildTrousseCategory(context, '🌿 Pour le stress', 'Stress', trousse['Stress'] ?? []),
                   _buildTrousseCategory(context, '🍃 Pour la digestion', 'Digestion', trousse['Digestion'] ?? []),
                   _buildTrousseCategory(context, '😴 Pour le sommeil', 'Sommeil', trousse['Sommeil'] ?? []),
                   _buildTrousseCategory(context, '🩸 Pour les règles', 'Règles', trousse['Règles'] ?? []),
                   
                   const SizedBox(height: 40),
                   
                   // Shop CTA
                   if (trousseProvider.totalItems > 0)
                     GestureDetector(
                       onTap: () {
                         // Action vers boutique
                       },
                       child: Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           gradient: AppColors.roseGradient,
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: AppColors.roseShadow,
                         ),
                         child: const Column(
                           children: [
                             Text('📦 Commander ma trousse personnalisée', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                             SizedBox(height: 8),
                             Text('Recevez votre coffret sur mesure à domicile', 
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                           ],
                         ),
                       ),
                     ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrousseCategory(BuildContext context, String title, String categoryKey, List plants) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.rosePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w700)),
              if (plants.isEmpty)
                Text('Vide', style: AppTextStyles.body(10, AppColors.textMuted))
              else
                IconButton(
                  onPressed: () {}, // Optionnel: vider catégorie
                  icon: const Icon(Icons.more_horiz, size: 18, color: AppColors.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (plants.isEmpty)
            Text('Ajoutez des plantes depuis l\'Herbier Digital pour remplir cette section.', 
              style: AppTextStyles.body(11, AppColors.textDim))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plants.map((p) {
                return Chip(
                  avatar: Text(p.category.icon),
                  label: Text(p.name, style: AppTextStyles.body(12, AppColors.textPrimary)),
                  backgroundColor: AppColors.petalCream,
                  side: BorderSide.none,
                  onDeleted: () {
                    context.read<TrousseProvider>().removeFromTrousse(categoryKey, p.id);
                  },
                  deleteIconColor: AppColors.roseMid,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
