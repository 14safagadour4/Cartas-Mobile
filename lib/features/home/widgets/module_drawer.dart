import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ModuleDrawer extends StatelessWidget {
  const ModuleDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.petalCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 20, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.rosePale.withOpacity(0.5),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/images/femmyy.png',
                      width: 45, height: 45, fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CARTAS',
                          style: AppTextStyles.title(18, AppColors.roseDeep)),
                      Text('Modules & Services',
                          style: AppTextStyles.body(11, AppColors.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      color: AppColors.textPrimary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.local_florist_outlined,
                  title: 'Herbier Digital',
                  subtitle: 'Plantes médicinales',
                  color: AppColors.sage,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/herbier');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.spa_outlined,
                  title: 'Ma Trousse ',
                  subtitle: 'Ma pharmacie perso',
                  color: AppColors.rose,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/trousse');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.science_outlined,
                  title: 'Phyto Lab',
                  subtitle: 'Laboratoire virtuel',
                  color: AppColors.lavande,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/lab');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat IA Tawhida+',
                  subtitle: 'Assistante intelligente',
                  color: AppColors.roseVif,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/chat');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.groups_outlined,
                  title: 'Forum',
                  subtitle: 'Communauté bien-être',
                  color: AppColors.gold,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/forum');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.auto_stories_outlined,
                  title: 'Apprendre',
                  subtitle: 'Modules éducatifs',
                  color: AppColors.sageTendre,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/learning');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.sports_esports_outlined,
                  title: 'Tri9 el Kenz',
                  subtitle: 'Jeu éducatif',
                  color: AppColors.goldDeep,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/treasure');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.medical_services_outlined,
                  title: 'Consultation',
                  subtitle: 'Spécialistes santé',
                  color: AppColors.roseMid,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/consultation');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: 'Boutique',
                  subtitle: 'Produits naturels',
                  color: AppColors.gold,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/shop');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Espace Rachma',
                  subtitle: 'Art-thérapie & Coloriage',
                  color: AppColors.lavandeVif,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/arttherapy');
                  },
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '🌿 CARTAS — Bien-être naturel',
              style: AppTextStyles.body(10, AppColors.textDim,
                  weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: AppTextStyles.body(13, AppColors.textPrimary,
                weight: FontWeight.w600)),
        subtitle:
            Text(subtitle, style: AppTextStyles.body(10, AppColors.textMuted)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        hoverColor: color.withOpacity(0.05),
      ),
    );
  }
}
