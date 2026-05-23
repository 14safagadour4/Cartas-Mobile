import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/plant.dart';
import '../providers/trousse_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PlantDetailScreen extends StatelessWidget {
  final Plant plant;
  const PlantDetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: CustomScrollView(
        slivers: [
          // Header with image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.rosePale,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.roseDeep),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'plant-${plant.id}',
                child: Container(
                  padding: const EdgeInsets.all(40),
                  child: Image.asset(
                    plant.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(plant.category.icon, style: const TextStyle(fontSize: 100)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plant.name, style: AppTextStyles.title(32, AppColors.roseDeep)),
                            Text(plant.nameLatin, 
                              style: AppTextStyles.body(14, AppColors.textMuted).copyWith(fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      Text(plant.nameAr, 
                        style: const TextStyle(fontSize: 28, color: AppColors.goldDeep, fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on_outlined, 'Région', plant.region),
                  const SizedBox(height: 24),

                  // Description
                  _buildSectionTitle('Description'),
                  Text(plant.description, style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w400)),

                  const SizedBox(height: 24),
                  // Histoire
                  _buildSectionTitle('Histoire & Tradition'),
                  Text(plant.history, style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w400)),

                  const SizedBox(height: 24),
                  // Bienfaits
                  _buildSectionTitle('Bienfaits & Propriétés'),
                  ...plant.benefits.map((b) => _buildBulletPoint(b)),

                  const SizedBox(height: 24),
                  // Utilisation
                  _buildSectionTitle('Conseil d\'utilisation'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.sagePale.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(plant.usage, style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w500)),
                  ),

                  const SizedBox(height: 24),
                  // Précautions
                  _buildSectionTitle('Précautions', color: Colors.orange.shade800),
                  Text(plant.precautions, style: AppTextStyles.body(13, Colors.orange.shade900, weight: FontWeight.w400)),

                  const SizedBox(height: 40),
                  
                  // CTA Boutique
                  _buildShopButton(context),
                  
                  const SizedBox(height: 16),
                  
                  // Add to Trousse Button
                  _buildTrousseButton(context),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = AppColors.roseDeep}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: AppTextStyles.title(20, color, weight: FontWeight.w700)),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.body(13, AppColors.textPrimary, weight: FontWeight.w400))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.goldDeep),
        const SizedBox(width: 8),
        Text('$label : ', style: AppTextStyles.body(12, AppColors.textMuted)),
        Text(value, style: AppTextStyles.body(12, AppColors.textPrimary, weight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildShopButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Logique pour ouvrir le lien boutique
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.goldGlowShadow,
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Voir dans la boutique →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrousseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTrousseDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.rose.withOpacity(0.3)),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medical_services_outlined, color: AppColors.rose, size: 20),
              SizedBox(width: 12),
              Text('Ajouter à ma trousse CARTAS', style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrousseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mes programmes bien-être', style: AppTextStyles.title(20, AppColors.roseDeep)),
              const SizedBox(height: 8),
              Text('Dans quelle catégorie ajouter cette plante ?', 
                textAlign: TextAlign.center,
                style: AppTextStyles.body(13, AppColors.textMuted)),
              const SizedBox(height: 24),
              _buildTrousseOption(context, '🌿 Pour le stress', 'Stress'),
              _buildTrousseOption(context, '🍃 Pour la digestion', 'Digestion'),
              _buildTrousseOption(context, '😴 Pour le sommeil', 'Sommeil'),
              _buildTrousseOption(context, '🩸 Pour les règles', 'Règles'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrousseOption(BuildContext context, String label, String category) {
    final provider = context.read<TrousseProvider>();
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.add_circle_outline, color: AppColors.gold),
      onTap: () {
        provider.addToTrousse(category, plant);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.name} ajouté à votre trousse ($label) !'),
            backgroundColor: AppColors.sage,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
