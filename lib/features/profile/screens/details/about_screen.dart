import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('À propos', style: AppTextStyles.title(20, AppColors.roseDeep)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.eco, size: 80, color: AppColors.rose),
            const SizedBox(height: 24),
            Text('CARTAS', style: AppTextStyles.title(24, AppColors.roseDeep, weight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Version 1.0.0', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 32),
            Text(
              'Cartas est votre compagnon de phytothérapie intelligent. Notre mission est de reconnecter l\'homme à la nature en facilitant l\'identification et l\'utilisation des plantes médicinales.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(14, AppColors.textMuted),
            ),
            const Spacer(),
            const Text('© 2026 Cartas Team', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
