import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HerbierSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String? initialValue;

  const HerbierSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<HerbierSearchBar> createState() => _HerbierSearchBarState();
}

class _HerbierSearchBarState extends State<HerbierSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEE9), // Light grayish beige from image
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
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
