import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/localization/language_provider.dart';
import 'package:cartas/core/theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  final bool isCompact;

  const LanguageSelector({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactLangButton(context, 'fr', 'FR', langProvider),
          _buildCompactLangButton(context, 'en', 'EN', langProvider),
          _buildCompactLangButton(context, 'ar', 'AR', langProvider),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLangButton(context, 'fr', 'Français', '🇫🇷', langProvider),
          const SizedBox(width: 8),
          _buildLangButton(context, 'en', 'English', '🇬🇧', langProvider),
          const SizedBox(width: 8),
          _buildLangButton(context, 'ar', 'العربية', '🇹🇳', langProvider),
        ],
      ),
    );
  }

  Widget _buildCompactLangButton(BuildContext context, String code, String label, LanguageProvider provider) {
    final isSelected = provider.locale.languageCode == code;
    return GestureDetector(
      onTap: () => provider.setLanguage(code),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rose.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.rose : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.rose : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String code, String label, String flag, LanguageProvider provider) {
    final isSelected = provider.locale.languageCode == code;
    return InkWell(
      onTap: () => provider.setLanguage(code),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.rose.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.rose : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.rose : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
