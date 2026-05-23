import 'package:flutter/material.dart';
import 'package:cartas/core/localization/language_provider.dart';
import 'package:cartas/core/theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  final LanguageProvider languageProvider;

  const LanguageSelector({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.rose.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.rose.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton('FR', 'fr'),
          const SizedBox(width: 4),
          _buildLanguageButton('EN', 'en'),
          const SizedBox(width: 4),
          _buildLanguageButton('AR', 'ar'),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String label, String code) {
    final isSelected = languageProvider.locale.languageCode == code;
    return GestureDetector(
      onTap: () => languageProvider.setLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rose.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.roseVif : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}