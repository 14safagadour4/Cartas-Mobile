import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HerbierSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const HerbierSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEE9), // Light grayish beige from image
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.body(14, AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, arabe ou latin...',
          hintStyle: AppTextStyles.body(13, AppColors.textMuted.withOpacity(0.6), weight: FontWeight.w500),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.textMuted.withOpacity(0.6), size: 20),
        ),
      ),
    );
  }
}
