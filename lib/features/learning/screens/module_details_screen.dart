import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../models/learning_models.dart';

class ModuleDetailsScreen extends StatelessWidget {
  final LearningModule module;

  const ModuleDetailsScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final titlePurple = const Color.fromARGB(255, 118, 79, 126);
    final subtitleMauve = const Color.fromARGB(255, 166, 127, 182);
    final goldProgress = const Color.fromARGB(255, 238, 210, 158);

    // Use real lessons from the module object
    final moduleLessons = module.lessons;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5), // Beige cream
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: titlePurple,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    module.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      Container(color: titlePurple.withOpacity(0.8), child: const Icon(Icons.image, size: 80, color: Colors.white30)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          titlePurple.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('MODULE', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          module.title,
                          style: AppTextStyles.title(24, Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('À propos de ce module', style: AppTextStyles.title(20, titlePurple)),
                  const SizedBox(height: 12),
                  Text(
                    module.description,
                    style: TextStyle(fontSize: 14, color: subtitleMauve, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book, color: subtitleMauve, size: 20),
                          const SizedBox(width: 8),
                          Text('${module.totalLessons} leçons', style: AppTextStyles.body(14, titlePurple, weight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: subtitleMauve, size: 20),
                          const SizedBox(width: 8),
                          Text(module.duration, style: AppTextStyles.body(14, titlePurple, weight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFFEF3F5), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE8E9), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: Colors.pinkAccent, size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Récompense de Module', style: AppTextStyles.title(16, titlePurple)),
                              const SizedBox(height: 4),
                              Text(
                                'Complétez ce module pour gagner 50 pts de réduction sur la boutique Cartago !',
                                style: TextStyle(fontSize: 12, color: subtitleMauve, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progression globale', style: TextStyle(fontSize: 14, color: subtitleMauve, fontWeight: FontWeight.bold)),
                      Text('${(module.progress * 100).toInt()}%', style: TextStyle(fontSize: 14, color: titlePurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: module.progress == 0.0 ? 0.05 : module.progress,
                    backgroundColor: const Color(0xFFF3EDE8),
                    valueColor: AlwaysStoppedAnimation<Color>(goldProgress),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 40),
                  Text('Liste des Leçons', style: AppTextStyles.title(20, titlePurple)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lesson = moduleLessons[index];
                  return _buildLessonCard(context, lesson, index + 1, titlePurple, subtitleMauve);
                },
                childCount: moduleLessons.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, Lesson lesson, int number, Color titlePurple, Color subtitleMauve) {
    return GestureDetector(
      onTap: () {
        context.push('/lesson', extra: lesson);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF6F2F7), shape: BoxShape.circle),
              child: Center(child: Text('$number', style: AppTextStyles.title(18, titlePurple))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: AppTextStyles.body(15, titlePurple, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.play_circle_outline, size: 14, color: subtitleMauve),
                      const SizedBox(width: 4),
                      Text(lesson.duration, style: TextStyle(fontSize: 12, color: subtitleMauve)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow, color: titlePurple),
          ],
        ),
      ),
    );
  }
}
