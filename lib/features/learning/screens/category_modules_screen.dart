import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../models/learning_models.dart';
import '../providers/learning_provider.dart';

class CategoryModulesScreen extends StatelessWidget {
  final LearningCategory category;

  const CategoryModulesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Utiliser les mêmes couleurs douces que l'écran précédent
    final Color titlePurple = const Color.fromARGB(255, 118, 79, 126);
    final Color subtitleMauve = const Color.fromARGB(255, 166, 127, 182);
    final Color goldProgress = const Color.fromARGB(255, 238, 210, 158);

    // Filtrer les modules pour cette catégorie
    final categoryModules = LearningMockData.modules.where((m) => m.categoryId == category.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5), // Beige cream
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFE8EE), // Rond gris mauve très clair
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: titlePurple, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apprendre', style: AppTextStyles.title(22, titlePurple)),
            Text('Modules éducatifs', style: TextStyle(fontSize: 13, color: subtitleMauve)),
          ],
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: categoryModules.length,
        itemBuilder: (context, index) {
          final module = categoryModules[index];
          return _buildModuleListItem(context, module, titlePurple, subtitleMauve, goldProgress);
        },
      ),
    );
  }

  Widget _buildModuleListItem(BuildContext context, LearningModule module, Color titlePurple, Color subtitleMauve, Color goldProgress) {
    // Dynamic Progress Calculation
    final double dynamicProgress = context.watch<LearningProvider>().calculateModuleProgress(module.id, module.totalLessons);

    return GestureDetector(
      onTap: () {
        context.push('/module-details', extra: module);
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0EBE6), width: 1),
        boxShadow: [
          BoxShadow(
            color: titlePurple.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // L'image de gauche dans un rond
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF6F2F7), // Fond lavande très clair
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                module.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.account_balance, color: subtitleMauve, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Le contenu texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: AppTextStyles.body(16, titlePurple, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(module.description, style: TextStyle(fontSize: 12, color: subtitleMauve), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 14, color: subtitleMauve),
                    const SizedBox(width: 4),
                    Text('${module.totalLessons} leçons', style: TextStyle(fontSize: 12, color: subtitleMauve)),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: subtitleMauve),
                    const SizedBox(width: 4),
                    Text(module.duration, style: TextStyle(fontSize: 12, color: subtitleMauve)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: dynamicProgress == 0.0 ? 0.05 : dynamicProgress,
                  backgroundColor: const Color(0xFFF3EDE8),
                  valueColor: AlwaysStoppedAnimation<Color>(goldProgress),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // La petite flèche à droite
          Icon(Icons.chevron_right, color: subtitleMauve),
        ],
      ),
    ));
  }
}
