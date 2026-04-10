import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.elasticOut)));
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AppColors.ivoryWhite, AppColors.warmBeige, const Color(0xFFF0E8D8)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [AppColors.saharaGold, AppColors.saharaGoldLight]),
                      boxShadow: [BoxShadow(color: AppColors.saharaGold.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                    ),
                    child: const Icon(Icons.eco, size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text('CARTAS', style: Theme.of(context).textTheme.displayLarge?.copyWith(letterSpacing: 4)),
                  const SizedBox(height: 8),
                  Text('Phytothérapie Tunisienne', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.sageGreen, letterSpacing: 1)),
                  const SizedBox(height: 40),
                  SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: AppColors.saharaGold, strokeWidth: 2)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
