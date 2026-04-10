import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Stack(
          children: [
            // Rating badge top-left
            Positioned(
              left: 12,
              top: 12,
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.gold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    plant.rating.toString(),
                    style: AppTextStyles.body(11, AppColors.textPrimary,
                        weight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            // Favorite button top-right
            Positioned(
              right: 12,
              top: 12,
              child: Icon(
                plant.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: plant.isFavorite
                    ? AppColors.roseMid
                    : AppColors.textMuted.withOpacity(0.5),
                size: 20,
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Plant Image placeholder / illustration
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        plant.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Text(
                            plant.category.icon,
                            style: const TextStyle(fontSize: 50)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    plant.name,
                    style: AppTextStyles.title(16, AppColors.roseDeep),
                    textAlign: TextAlign.center,
                  ),
                  // Arabic Name
                  Text(
                    plant.nameAr,
                    style: const TextStyle(
                      fontFamily:
                          'Amiri', // Assuming an Arabic font or fallback
                      fontSize: 14,
                      color: AppColors.goldDeep,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Latin Name
                  Text(
                    plant.nameLatin,
                    style: AppTextStyles.body(9, AppColors.textMuted,
                            weight: FontWeight.w500)
                        .copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Category Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sagePale.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plant.category.label.replaceAll('\n', ' '),
                      style: AppTextStyles.body(8, AppColors.sage,
                          weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
