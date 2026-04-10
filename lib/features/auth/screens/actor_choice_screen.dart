import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class ActorChoiceScreen extends StatefulWidget {
  const ActorChoiceScreen({super.key});

  @override
  State<ActorChoiceScreen> createState() => _ActorChoiceScreenState();
}

class _ActorChoiceScreenState extends State<ActorChoiceScreen> {
  int _selectedActorIndex = -1;

  final List<Map<String, dynamic>> _actors = [
    {
      'title': 'Utilisatrice',
      'subtitle': 'Découvrez les plantes et créez vos remèdes',
      'icon': Icons.eco,
      'color': AppColors.primaryGreen,
      'role': 'utilisatrice',
    },
    {
      'title': 'Spécialiste',
      'subtitle': 'Partagez votre expertise et conseillez la communauté',
      'icon': Icons.medical_services,
      'color': AppColors.secondaryGreen,
      'role': 'specialiste',
    },
    {
      'title': 'Art-Thérapeute',
      'subtitle': 'Animez des ateliers et partagez votre art',
      'icon': Icons.palette,
      'color': AppColors.accentColor,
      'role': 'art-therapeute',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGreen,
              AppColors.secondaryGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Choisissez votre\nrôle',
                  style: AppTextStyles.headlineLarge?.copyWith(
                    color: Colors.white,
                  ) ?? const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sélectionnez le profil qui vous correspond',
                  style: AppTextStyles.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ) ?? const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: _actors.length,
                    itemBuilder: (context, index) {
                      return _ActorCard(
                        actor: _actors[index],
                        isSelected: _selectedActorIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedActorIndex = index;
                          });
                          Future.delayed(const Duration(milliseconds: 500), () {
                            final role = _actors[index]['role'];
                            context.push('/login/$role');
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActorCard extends StatelessWidget {
  final Map<String, dynamic> actor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActorCard({
    required this.actor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = (actor['color'] as Color?) ?? Colors.green;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? cardColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: cardColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                actor['icon'] as IconData,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actor['title'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actor['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}