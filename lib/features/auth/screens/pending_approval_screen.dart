import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String role;
  
  const PendingApprovalScreen({
    super.key, 
    required this.role,
  });

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  StreamSubscription<RemoteMessage>? _messagingSubscription;

  @override
  void initState() {
    super.initState();
    _setupFcmListener();
  }

  void _setupFcmListener() {
    _messagingSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message reçu dans PendingApprovalScreen: ${message.data}');
      if (message.data['type'] == 'specialist_validated') {
        _handleApproval();
      }
    });
  }

  void _handleApproval() {
    // Une petite animation de transition avant de rediriger
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Votre compte a été validé ! Redirection...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        String roleParam = widget.role.toLowerCase() == 'specialist' ? 'specialiste' : 'art-therapeute';
        context.goNamed('login', pathParameters: {'role': roleParam});
      }
    });
  }

  @override
  void dispose() {
    _messagingSubscription?.cancel();
    super.dispose();
  }

  String get _roleLabel => widget.role == 'SPECIALIST' ? 'Spécialiste' : 'Art-Thérapeute';
  String get _roleEmoji => widget.role == 'SPECIALIST' ? '🌿' : '🎨';
  
  Color get _accent => widget.role == 'SPECIALIST' ? AppColors.sageTendre : AppColors.lavande;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  widget.role == 'SPECIALIST' 
                    ? const Color(0xFF0A1810) 
                    : const Color(0xFF100828),
                  AppColors.darkNight,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon / Lottie Placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent.withValues(alpha: 0.1),
                      border: Border.all(color: _accent.withValues(alpha: 0.2), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _roleEmoji,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack).shimmer(delay: 1.seconds),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Dossier en cours d\'examen',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display(24, Colors.white, weight: FontWeight.w700),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Merci de votre confiance. Votre inscription en tant que $_roleLabel est bien enregistrée.\n\n'
                    'Notre équipe SuperAdmin examine actuellement vos pièces justificatives. '
                    'Vous recevrez un email dès que votre compte sera activé.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(14, Colors.white.withValues(alpha: 0.7)).copyWith(height: 1.6),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 48),
                  
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'STATUT : EN ATTENTE',
                          style: AppTextStyles.body(11, AppColors.gold, weight: FontWeight.w800).copyWith(letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                  
                  const SizedBox(height: 60),
                  
                  // Back button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Retour à l\'accueil',
                        style: AppTextStyles.body(14, Colors.white, weight: FontWeight.w600),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1.seconds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
