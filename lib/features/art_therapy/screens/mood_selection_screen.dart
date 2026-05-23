import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class MoodSelectionScreen extends StatefulWidget {
  final String title;
  final String imagePath;

  const MoodSelectionScreen({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String? _selectedMood;

  final List<Map<String, String>> _moods = [
    {'icon': '😔', 'label': 'Stressée'},
    {'icon': '🤯', 'label': 'Surchargée'},
    {'icon': '😟', 'label': 'Anxieuse'},
    {'icon': '😐', 'label': 'Neutre'},
    {'icon': '😊', 'label': 'Calme'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Avant de commencer...',
                style: AppTextStyles.body(16, AppColors.textMuted, weight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                'Comment vous sentez-vous tawa ?',
                textAlign: TextAlign.center,
                style: AppTextStyles.title(24, AppColors.roseDeep, weight: FontWeight.w800),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: _moods.map((mood) {
                  final isSelected = _selectedMood == mood['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood['label']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.roseMid : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(mood['icon']!, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            mood['label']!,
                            style: AppTextStyles.body(
                              12,
                              isSelected ? Colors.white : AppColors.textDim,
                              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedMood == null
                      ? null
                      : () {
                          context.push(
                            '/arttherapy/coloring/interactive',
                            extra: {
                              'title': widget.title,
                              'imagePath': widget.imagePath,
                              'mood': _selectedMood,
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roseDeep,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Commencer ma séance',
                    style: AppTextStyles.body(14, Colors.white, weight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Peut-être plus tard', style: AppTextStyles.body(13, AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
