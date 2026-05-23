import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class CategoryTipsScreen extends StatelessWidget {
  final String category;
  final IconData icon;

  const CategoryTipsScreen({
    super.key,
    required this.category,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tips = _getTipsForCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Text('Conseils essentiels', style: AppTextStyles.title(20, AppColors.roseDeep)),
                  const SizedBox(height: 16),
                  ...tips.map((tip) => _buildTipCard(tip)).toList(),
                  const SizedBox(height: 32),
                  _buildExpertSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.roseDeep),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Guide : $category', style: AppTextStyles.title(18, AppColors.roseDeep)),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.roseDeep, AppColors.roseDeep.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.roseDeep.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'Tout ce qu\'il faut savoir sur $category',
            textAlign: TextAlign.center,
            style: AppTextStyles.title(20, Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, String> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.petalCream.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip['title']!, style: AppTextStyles.title(16, AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(tip['content']!, style: AppTextStyles.body(13, AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.1))),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/images/forom cumm/omrane.jpg')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Besoin d\'aide ?', style: AppTextStyles.title(15, AppColors.textPrimary)),
                Text('Posez vos questions à nos experts jardiniers.', style: AppTextStyles.body(12, AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.green),
        ],
      ),
    );
  }

  List<Map<String, String>> _getTipsForCategory(String category) {
    switch (category) {
      case 'Entretien':
        return [
          {'title': 'Arrosage intelligent', 'content': 'Arrosez tôt le matin pour limiter l\'évaporation et prévenir les maladies fongiques.'},
          {'title': 'Taille régulière', 'content': 'Supprimez les fleurs fanées pour encourager de nouvelles floraisons.'},
          {'title': 'Désherbage naturel', 'content': 'Utilisez du paillage pour limiter la pousse des mauvaises herbes.'},
        ];
      case 'Sol & Engrais':
        return [
          {'title': 'Compost maison', 'content': 'Recyclez vos déchets verts pour créer un engrais riche et gratuit.'},
          {'title': 'Test de pH', 'content': 'Vérifiez l\'acidité de votre sol avant de planter pour choisir les bonnes espèces.'},
          {'title': 'Rotation des cultures', 'content': 'Changez l\'emplacement de vos légumes chaque année pour ne pas épuiser le sol.'},
        ];
      default:
        return [
          {'title': 'Conseil du jour', 'content': 'Observez vos plantes quotidiennement pour détecter les premiers signes de stress.'},
          {'title': 'Biodiversité', 'content': 'Installez un hôtel à insectes pour favoriser les pollinisateurs.'},
        ];
    }
  }
}
