import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class ArtTherapistHomeScreen extends StatelessWidget {
  const ArtTherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.lavande,
              child: Text('🎨', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 25),
            Text(
              'Espace Art-Thérapeute',
              style: AppTextStyles.title(22, Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Votre espace créatif est en cours de finalisation.',
              style: AppTextStyles.body(14, Colors.white60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
