import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class QuizDialog extends StatefulWidget {
  final Function(bool) onResult;

  const QuizDialog({super.key, required this.onResult});

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {
  int? _selectedOption;
  bool _showResult = false;
  bool _isCorrect = false;

  final Map<String, dynamic> _quizData = {
    'question': 'Quel est le nom tunisien (derja) de la plante Arbutus unedo ?',
    'options': ['Lendj', 'Randa', 'Dghas', 'Sedra'],
    'correctIndex': 0,
    'explanation': 'L\'Arbutus unedo est communément appelé Lendj en Tunisie. Ses fruits sont comestibles et très appréciés.',
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.roseDeep.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'QUIZ BOTANIQUE',
                style: AppTextStyles.body(12, AppColors.goldDeep, weight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 24),

            if (!_showResult) ...[
              Text(
                _quizData['question'],
                textAlign: TextAlign.center,
                style: AppTextStyles.title(20, AppColors.roseDeep, weight: FontWeight.w800),
              ),
              const SizedBox(height: 30),
              ...List.generate(
                _quizData['options'].length,
                (index) => _buildOption(index),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _selectedOption == null ? null : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  'VÉRIFIER',
                  style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w900),
                ),
              ),
            ] else ...[
              // Result View
              Icon(
                _isCorrect ? Icons.check_circle : Icons.error,
                color: _isCorrect ? AppColors.sage : AppColors.roseMid,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                _isCorrect ? 'Excellent !' : 'Oups !',
                style: AppTextStyles.title(24, _isCorrect ? AppColors.sage : AppColors.roseDeep, weight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                _isCorrect 
                  ? 'Forêt de Cartas débloquée – Région suivante ! (+100 XP)' 
                  : 'On réessaie (ou consomme une gemme / un ticket).',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(14, AppColors.textMuted),
              ),
              if (_isCorrect) ...[
                const SizedBox(height: 20),
                Text(
                  _quizData['explanation'],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(12, AppColors.textMuted, weight: FontWeight.w400),
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_isCorrect) {
                    Navigator.pop(context);
                    widget.onResult(true);
                  } else {
                    setState(() {
                      _showResult = false;
                      _selectedOption = null;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCorrect ? AppColors.sage : AppColors.roseDeep,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  _isCorrect ? 'CONTINUER' : 'RÉESSAYER',
                  style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w900),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index) {
    bool isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected 
                ? const Center(child: CircleAvatar(radius: 6, backgroundColor: AppColors.gold))
                : null,
            ),
            const SizedBox(width: 16),
            Text(
              _quizData['options'][index],
              style: AppTextStyles.body(16, isSelected ? AppColors.roseDeep : AppColors.textPrimary, weight: isSelected ? FontWeight.w800 : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer() {
    setState(() {
      _isCorrect = _selectedOption == _quizData['correctIndex'];
      _showResult = true;
    });
  }
}
