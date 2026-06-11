import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/local_state_service.dart';

class PlantCard extends StatefulWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.plant.isFavorite;
    _checkLocalFavorite();
  }

  Future<void> _checkLocalFavorite() async {
    final isFav = await LocalStateService.isFavorite(widget.plant.name);
    if (mounted && isFav != _isFavorite) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    // Build a map compatible with favorites screen
    final plantMap = {
      'id': widget.plant.id,
      'name': widget.plant.name,
      'commonName': widget.plant.name,
      'scientificName': widget.plant.nameLatin,
      'imageUrl': widget.plant.imagePath,
      'category': {'name': widget.plant.category.label.replaceAll('\n', ' ')}
    };
    await LocalStateService.toggleFavorite(plantMap);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                    widget.plant.rating.toString(),
                    style: AppTextStyles.body(11, AppColors.textPrimary, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            // Favorite button top-right
            Positioned(
              right: 2,
              top: 2,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.roseMid : AppColors.textMuted.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: _toggleFavorite,
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
                        widget.plant.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Text(
                            widget.plant.category.icon,
                            style: const TextStyle(fontSize: 50)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    widget.plant.name,
                    style: AppTextStyles.title(16, AppColors.roseDeep),
                    textAlign: TextAlign.center,
                  ),
                  // Arabic Name
                  Text(
                    widget.plant.nameAr,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: AppColors.goldDeep,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Latin Name
                  Text(
                    widget.plant.nameLatin,
                    style: AppTextStyles.body(9, AppColors.textMuted, weight: FontWeight.w500).copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sagePale.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.plant.category.label.replaceAll('\n', ' '),
                      style: AppTextStyles.body(8, AppColors.sage, weight: FontWeight.w700),
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
