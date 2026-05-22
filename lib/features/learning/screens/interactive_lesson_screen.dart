import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../models/learning_models.dart';
import '../providers/learning_provider.dart';

class InteractiveLessonScreen extends StatefulWidget {
  final Lesson lesson;

  const InteractiveLessonScreen({super.key, required this.lesson});

  @override
  State<InteractiveLessonScreen> createState() => _InteractiveLessonScreenState();
}

class _InteractiveLessonScreenState extends State<InteractiveLessonScreen> {
  final Color titlePurple = const Color.fromARGB(255, 118, 79, 126);
  final Color subtitleMauve = const Color.fromARGB(255, 166, 127, 182);

  void _finishLesson() {
    // Récupérer le module depuis le provider (données réelles)
    final module = context.read<LearningProvider>().modules.firstWhere(
      (m) => m.id == widget.lesson.moduleId,
      orElse: () => context.read<LearningProvider>().modules.first, // Fallback
    );
    
    // Marquer la leçon comme complétée
    final bool justFinishedModule = context.read<LearningProvider>().completeLesson(widget.lesson.moduleId, module.totalLessons);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  justFinishedModule ? Icons.auto_awesome_rounded : Icons.emoji_events, 
                  color: Colors.amber, 
                  size: 64
                ),
                const SizedBox(height: 16),
                Text(
                  justFinishedModule ? 'Module Complété !' : 'Bravo !', 
                  style: AppTextStyles.title(22, titlePurple)
                ),
                const SizedBox(height: 12),
                Text(
                  justFinishedModule 
                    ? 'Incroyable ! Vous avez terminé tout le module. Vous avez débloqué 50 points de réduction valables sur tous les produits cosmétiques Cartago ! 🛍️✨'
                    : 'Leçon terminée ! Plus que quelques efforts pour finir le module et gagner vos points de réduction sur nos produits naturels Cartago. 🌸', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: subtitleMauve, fontSize: 15, height: 1.4)
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // fermer dialog
                    context.pop(); // revenir à la liste
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: titlePurple,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    justFinishedModule ? 'Récupérer ma récompense' : 'Continuer l\'aventure', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFFEFE8EE), shape: BoxShape.circle),
            child: IconButton(icon: Icon(Icons.close, color: titlePurple, size: 20), onPressed: () => context.pop()),
          ),
        ),
        title: Text(widget.lesson.title, style: AppTextStyles.title(18, titlePurple)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...widget.lesson.blocks.map((block) => _buildBlock(block)),
            const SizedBox(height: 40),
            if (widget.lesson.attachedQuiz != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2E2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: AppColors.sageTendre, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quiz Disponible', style: AppTextStyles.title(16, titlePurple)),
                          Text('Validez vos acquis', style: TextStyle(color: subtitleMauve, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Lancer le Quiz
                        context.push('/quiz', extra: widget.lesson.attachedQuiz);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sageTendre,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Jouer', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _finishLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: titlePurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Terminer la leçon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(LessonBlock block) {
    if (block.type == 'text') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Text(
          block.content,
          style: TextStyle(fontSize: 15, color: titlePurple.withOpacity(0.8), height: 1.6),
        ),
      );
    } else if (block.type == 'image') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            block.content,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: subtitleMauve.withOpacity(0.2),
              child: Center(child: Icon(Icons.image, color: subtitleMauve, size: 40)),
            ),
          ),
        ),
      );
    } else if (block.type == 'tip') {
      return Container(
        margin: const EdgeInsets.only(bottom: 24.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE8E9), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                block.content,
                style: TextStyle(fontSize: 14, color: titlePurple, fontWeight: FontWeight.w600, height: 1.5),
              ),
            ),
          ],
        ),
      );
    } else if (block.type == 'interactive') {
      return GestureDetector(
        onTap: () {
          // Flip logic could be added here later
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Animation intéractive à venir !')));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F2E2), Color(0xFFDFE2F2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: titlePurple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              const Icon(Icons.touch_app, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(block.content, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titlePurple)),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
