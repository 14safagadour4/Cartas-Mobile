import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass   = true;
  bool _isLoading     = false;

  late AnimationController _orbController;

  // Role config
  late _RoleConfig _config;

  @override
  void initState() {
    super.initState();
    _config = _getRoleConfig(widget.role);
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _orbController.dispose();
    super.dispose();
  }

  _RoleConfig _getRoleConfig(String role) {
    switch (role) {
      case 'specialiste':
        return _RoleConfig(
          emoji: '🌿',
          label: 'Spécialiste Phytothérapie',
          accentColor: AppColors.sageTendre,
          gradient: AppColors.sageGradient,
          bgColors: [
            const Color(0xFF0A0510),
            const Color(0xFF0A1810),
            const Color(0xFF1B4332),
            const Color(0xFF52B788),
          ],
        );
      case 'art-therapeute':
        return _RoleConfig(
          emoji: '🎨',
          label: 'Art-Thérapeute',
          accentColor: AppColors.lavande,
          gradient: AppColors.lavandeGradient,
          bgColors: [
            const Color(0xFF0A0510),
            const Color(0xFF100828),
            const Color(0xFF3A1260),
            const Color(0xFF8040C0),
          ],

        );
      default: // utilisatrice
        return _RoleConfig(
          emoji: '🌸',
          label: 'Utilisatrice',
          accentColor: AppColors.roseVif,
          gradient: AppColors.roseGradient,
          bgColors: [
            const Color(0xFF0A0510),
            const Color(0xFF22082A),
            const Color(0xFF7D3058),
            const Color(0xFFD4709A),
          ],
        );
    }
  }

  void _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await AuthService.login(email, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        context.goNamed('home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Email ou mot de passe incorrect'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Dark gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.5),
                radius: 1.5,
                colors: [
                  _config.bgColors[1],
                  _config.bgColors[0],
                ],
              ),
            ),
          ),

          // Ambient orbs
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, _) {
              final t = _orbController.value;
              return Stack(
                children: [
                  // Top pink orb
                  Positioned(
                    top: -60,
                    left: MediaQuery.of(context).size.width * 0.15,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _config.accentColor.withOpacity(0.18 - t * 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.7],
                        ),
                      ),
                    ),
                  ),
                  // Gold orb bottom
                  Positioned(
                    bottom: 80,
                    right: -20,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.08 * t),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Flora decorations
          Positioned(
            top: -10,
            left: -12,
            child: Opacity(
              opacity: 0.04,
              child: const Text('🌿', style: TextStyle(fontSize: 100)),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -8,
            child: Opacity(
              opacity: 0.04,
              child: const Text('🌺', style: TextStyle(fontSize: 80)),
            ),

          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.08),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 15),
                            ),
                          ),

                          // Role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _config.accentColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _config.accentColor.withOpacity(0.22),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _config.accentColor.withOpacity(0.08),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_config.emoji,
                                    style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  _config.label,
                                  style: AppTextStyles.body(
                                    10.5,
                                    _config.accentColor.withOpacity(0.9),
                                    weight: FontWeight.w600,
                                  ).copyWith(letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms),

                          const SizedBox(height: 13),

                          // Title
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.modalTitle,
                              children: [
                                const TextSpan(text: 'Bon retour\nparmi '),
                                TextSpan(
                                  text: 'nous',
                                  style: AppTextStyles.modalTitle?.copyWith(
                                    fontFamily: 'CormorantGaramond',
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 100.ms, duration: 500.ms)
                              .slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),

                    // Glass form card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: const Color(0xEBFAF6F0), // cream 92% opacity
                        border: Border.all(
                          color: Colors.white.withOpacity(0.72),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 80,
                            offset: const Offset(0, 32),
                          ),
                          BoxShadow(
                            color: _config.accentColor.withOpacity(0.07),
                            blurRadius: 80,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.35),
                            blurRadius: 0,
                            offset: const Offset(0, 0),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Tabs
                                _buildTabs(),
                                const SizedBox(height: 22),

                                // Email field
                                _buildField(
                                  label: 'ADRESSE EMAIL',
                                  icon: '📧',
                                  controller: _emailCtrl,
                                  hint: 'votre@email.tn',
                                  keyboardType: TextInputType.emailAddress,
                                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                                const SizedBox(height: 16),

                                // Password field
                                _buildPasswordField()
                                    .animate().fadeIn(delay: 280.ms, duration: 500.ms),

                                const SizedBox(height: 8),

                                // Forgot
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: AppTextStyles.body(
                                      11.5, AppColors.roseVif,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // CTA
                                _buildCTAButton()
                                    .animate().fadeIn(delay: 350.ms, duration: 500.ms),

                                const SizedBox(height: 20),

                                // Divider
                                _buildDivider(),

                                const SizedBox(height: 16),

                                // Google
                                _buildGoogleButton()
                                    .animate().fadeIn(delay: 450.ms, duration: 500.ms),

                                const SizedBox(height: 16),

                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Pas encore de compte ? ",
                                        style: AppTextStyles.bodyMuted),
                                    GestureDetector(
                                      onTap: () => context.goNamed(
                                        'signup',
                                        pathParameters: {'role': widget.role},
                                      ),
                                      child: Text(
                                        'S\'inscrire →',
                                        style: AppTextStyles.body(
                                          12, AppColors.rose,
                                          weight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 600.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.rose.withOpacity(0.07),
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose.withOpacity(0.12),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Connexion',
                  style: AppTextStyles.body(
                    12, AppColors.rose,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.goNamed(
                'signup',
                pathParameters: {'role': widget.role},
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Inscription',
                    style: AppTextStyles.body(
                      12, AppColors.textMuted,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String icon,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.rose.withOpacity(0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.rose.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Text(icon, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTextStyles.bodyText,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMuted.copyWith(fontSize: 12),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MOT DE PASSE', style: AppTextStyles.label),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.rose.withOpacity(0.1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.rose.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text('🔒', style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePass,
                  style: AppTextStyles.bodyText,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: AppTextStyles.bodyMuted.copyWith(fontSize: 12),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _login,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _config.gradient,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: _config.accentColor.withOpacity(0.45),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _config.accentColor.withOpacity(0.12),
              blurRadius: 60,
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : Text('Se connecter →', style: AppTextStyles.btnText),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.rose.withOpacity(0.1), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou continuer avec',
              style: AppTextStyles.body(10, AppColors.textDim, weight: FontWeight.w500)
                  .copyWith(letterSpacing: 0.5)),
        ),
        Expanded(child: Divider(color: AppColors.rose.withOpacity(0.1), thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _login,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.rose.withOpacity(0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.rose.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google logo SVG as text (use proper SVG in production)
            Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4285F4)),
              child: const Center(
                child: Text('G', style: TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Continuer avec Google',
              style: AppTextStyles.body(13, AppColors.textPrimary, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleConfig {
  final String emoji;
  final String label;
  final Color accentColor;
  final LinearGradient gradient;
  final List<Color> bgColors;

  const _RoleConfig({
    required this.emoji,
    required this.label,
    required this.accentColor,
    required this.gradient,
    required this.bgColors,
  });
}