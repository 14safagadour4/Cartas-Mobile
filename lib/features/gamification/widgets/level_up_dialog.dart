import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class LevelUpDialog extends StatelessWidget {
  const LevelUpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.2),
              blurRadius: 50,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.stars, color: AppColors.gold, size: 100),
                Text(
                  '13',
                  style: AppTextStyles.title(24, Colors.white, weight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'NIVEAU SUPÉRIEUR !',
              style: AppTextStyles.title(22, AppColors.roseDeep, weight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.petalCream.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.gold.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'HISTOIRE DE LA SOURCE',
                    style: AppTextStyles.body(10, AppColors.goldDeep, weight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vous avez atteint les Débuts de l\'Oasis. Les anciens racontent que la source de Cartas ne tarit jamais pour ceux qui respectent la flore.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(13, AppColors.textMuted, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRewardItem(Icons.bolt, 'Bonus XP x2', '30 min'),
                _buildRewardItem(Icons.map, 'Nouvelle Zone', 'Oasis'),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'COLLECTER',
                style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String label, String sub) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.gold, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.body(11, AppColors.roseDeep, weight: FontWeight.w800)),
        Text(sub, style: AppTextStyles.body(10, AppColors.textMuted)),
      ],
    );
  }
}
