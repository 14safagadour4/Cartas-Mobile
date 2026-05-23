import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../models/learning_models.dart';
import '../providers/learning_provider.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Color titlePurple = const Color.fromARGB(255, 118, 79, 126);
  final Color subtitleMauve = const Color.fromARGB(255, 166, 127, 182);

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerChecked = false;

  void _checkAnswer() {
    if (_selectedAnswerIndex == null) return;

    final currentQuestion = widget.quiz.questions[_currentIndex];
    if (_selectedAnswerIndex == currentQuestion.correctAnswerIndex) {
      _score++;
    }

    setState(() {
      _isAnswerChecked = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswerChecked = false;
      });
    } else {
      // Quiz Finished !
      context.read<LearningProvider>().completeQuiz(widget.quiz.id);
      _showResultDialog();
    }
  }

  void _showResultDialog() {
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
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Quiz Terminé !', style: AppTextStyles.title(22, titlePurple)),
                const SizedBox(height: 8),
                Text('Votre score: $_score / ${widget.quiz.questions.length}', style: TextStyle(color: titlePurple, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: titlePurple,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Retour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(body: Center(child: Text("Aucune question.")));
    }

    final question = widget.quiz.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: widget.quiz.baseColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: titlePurple),
          onPressed: () => context.pop(),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(titlePurple),
            minHeight: 8,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text('Question ${_currentIndex + 1} / ${widget.quiz.questions.length}', style: TextStyle(fontSize: 14, color: subtitleMauve, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              question.questionText,
              style: AppTextStyles.title(22, titlePurple).copyWith(height: 1.4),
            ),
            const SizedBox(height: 40),
            ...List.generate(question.options.length, (index) {
              final isSelected = _selectedAnswerIndex == index;
              final isCorrect = index == question.correctAnswerIndex;

              Color bgColor = Colors.white;
              Color borderColor = Colors.transparent;

              if (_isAnswerChecked) {
                if (isSelected) {
                  bgColor = isCorrect ? const Color(0xFFE8F2E2) : const Color(0xFFFDE8E9);
                  borderColor = isCorrect ? AppColors.sageTendre : Colors.redAccent;
                } else if (isCorrect) {
                  bgColor = const Color(0xFFE8F2E2).withOpacity(0.5);
                  borderColor = AppColors.sageTendre.withOpacity(0.5);
                }
              } else if (isSelected) {
                bgColor = titlePurple.withOpacity(0.1);
                borderColor = titlePurple;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GestureDetector(
                  onTap: _isAnswerChecked ? null : () {
                    setState(() {
                      _selectedAnswerIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(question.options[index], style: TextStyle(fontSize: 16, color: titlePurple, fontWeight: FontWeight.w500))),
                        if (_isAnswerChecked && isCorrect) const Icon(Icons.check_circle, color: AppColors.sageTendre),
                        if (_isAnswerChecked && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.redAccent),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            if (_isAnswerChecked)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.sageTendre),
                    const SizedBox(width: 12),
                    Expanded(child: Text(question.explanation, style: TextStyle(color: titlePurple, height: 1.4))),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: _selectedAnswerIndex == null
                  ? null
                  : (_isAnswerChecked ? _nextQuestion : _checkAnswer),
              style: ElevatedButton.styleFrom(
                backgroundColor: titlePurple,
                disabledBackgroundColor: titlePurple.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                _isAnswerChecked ? 'Continuer' : 'Vérifier',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
