import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/auth_service.dart';

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
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (context.mounted) context.go('/onboarding');
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lavande,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
