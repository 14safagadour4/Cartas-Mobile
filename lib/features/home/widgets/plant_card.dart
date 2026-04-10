import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PlantCard extends StatelessWidget {
  final String name;
  final String arabicName;
  final String tag;
  final String imagePath;
  final Color tagColor;

  const PlantCard({
    super.key,
    required this.name,
    required this.arabicName,
    required this.tag,
    required this.imagePath,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 230,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Image.asset(imagePath, height: 80, fit: BoxFit.contain),
          ),
          const SizedBox(height: 12),
          Text(name, style: AppTextStyles.title(15, AppColors.textPrimary)),
          Text(arabicName, style: AppTextStyles.body(11, AppColors.textMuted, weight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: AppTextStyles.body(9, tagColor, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
