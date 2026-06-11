import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/localization/language_provider.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final String currentLangCode = languageProvider.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(languageProvider.getText('nav_profile'), style: AppTextStyles.title(20, AppColors.roseDeep)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLanguageItem('Français', '🇫🇷', 'fr', currentLangCode, languageProvider),
            const SizedBox(height: 16),
            _buildLanguageItem('العربية', '🇹🇳', 'ar', currentLangCode, languageProvider),
            const SizedBox(height: 16),
            _buildLanguageItem('English', '🇬🇧', 'en', currentLangCode, languageProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String language, String flag, String code, String currentCode, LanguageProvider provider) {
    bool isSelected = currentCode == code;
    return GestureDetector(
      onTap: () => provider.setLanguage(code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.rose, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(language, style: AppTextStyles.body(16, AppColors.roseDeep, weight: isSelected ? FontWeight.w800 : FontWeight.w600)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.rose),
          ],
        ),
      ),
    );
  }
}
