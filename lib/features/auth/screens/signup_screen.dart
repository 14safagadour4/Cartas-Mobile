import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  int _currentStep = 0;
  PlatformFile? _pickedFile;

  final Set<String> _selectedSpecialities = {};

  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _orbController.dispose();
    super.dispose();
  }

  bool get _isSpecialist => widget.role == 'specialiste';
  bool get _isTherapist => widget.role == 'art-therapeute';
  bool get _needsMultiStep => _isSpecialist || _isTherapist;
  int get _totalSteps => _needsMultiStep ? 3 : 1;

  Color get _accent => switch (widget.role) {
        'specialiste' => AppColors.sageTendre,
        'art-therapeute' => AppColors.lavande,
        _ => AppColors.roseVif,
      };

  LinearGradient get _gradient => switch (widget.role) {
        'specialiste' => AppColors.sageGradient,
        'art-therapeute' => AppColors.lavandeGradient,
        _ => AppColors.roseGradient,
      };

  String get _roleEmoji => switch (widget.role) {
        'specialiste' => '🌿',
        'art-therapeute' => '🎨',
        _ => '🌸',
      };

  String get _roleLabel => switch (widget.role) {
        'specialiste' => 'Spécialiste Phytothérapie',
        'art-therapeute' => 'Art-Thérapeute',
        _ => 'Utilisatrice',
      };

  List<String> get _specialities => _isTherapist
      ? [
          '🎨 Dessin thérapeutique',
          '🎭 Médiation artistique',
          '📝 Écriture artistique thérapeutique'
        ]
      : [
          '🌿 Phytothérapie',
          '🌸 Aromathérapie',
          '🍃 Herboristerie',
          '💊 Naturopathie',
          '🌱 Phytologie',
          '🌺 Fleurs de Bach'
        ];

  void _nextStep() {
    if (_needsMultiStep && _currentStep == 2 && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner un fichier justificatif')),
      );
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;

        // 5MB limit check (5 * 1024 * 1024 bytes)
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Le fichier dépasse la limite de 5 Mo')),
            );
          }
          return;
        }

        setState(() => _pickedFile = file);
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  void _submit() async {
    setState(() => _isLoading = true);

    final roleMapping = {
      'specialiste': 'SPECIALIST',
      'art-therapeute': 'ART_THERAPIST',
    };

    final role = roleMapping[widget.role] ?? 'APP_USER';

    final userData = {
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
      'role': role,
      if (role == 'SPECIALIST') 'specialty': _selectedSpecialities.join(', '),
      if (role == 'ART_THERAPIST')
        'artDiscipline': _selectedSpecialities.join(', '),
      // You can add more fields if needed (phone, bio, etc.)
    };

    try {
      final result =
          await AuthService.registerMobile(userData, filePath: _pickedFile?.path);

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  result['message'] ?? 'Inscription réussie ! Connectez-vous.'),
              backgroundColor: AppColors.sageTendre,
            ),
          );
          // Redirect to Login as requested
          context.goNamed('login', pathParameters: {'role': widget.role});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erreur lors de l’inscription'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue : Veuillez vérifier votre connexion ou réessayer plus tard.'),
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
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  switch (widget.role) {
                    'specialiste' => const Color(0xFF0A1810),
                    'therapeute' => const Color(0xFF100828),
                    _ => const Color(0xFF22082A),
                  },
                  AppColors.darkNight,
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, _) {
              final opacity = 0.16 * _orbController.value;
              return Positioned(
                top: -40,
                right: MediaQuery.of(context).size.width * 0.2,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _accent.withValues(alpha: opacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withValues(alpha: 0.08),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 13, vertical: 5),
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _accent.withValues(alpha: 0.22)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_roleEmoji,
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 6),
                                Text(_roleLabel,
                                    style: AppTextStyles.body(
                                        10.5, _accent.withValues(alpha: 0.9),
                                        weight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Rejoindre\nCARTAS',
                            style: AppTextStyles.display(26, Colors.white,
                                weight: FontWeight
                                    .w700), // ✅ Mettre false au lieu de null
                          ),
                          if (_needsMultiStep) ...[
                            const SizedBox(height: 16),
                            _buildProgressSteps(),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: AppColors.petalCream.withValues(alpha: 0.92),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.68)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.38),
                            blurRadius: 70,
                            offset: const Offset(0, 30),
                          ),
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.06),
                            blurRadius: 60,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: _buildStepContent(),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 600.ms)
                        .slideY(begin: 0.08, end: 0),
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

  Widget _buildProgressSteps() {
    return Row(
      children: List.generate(_totalSteps, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i < _currentStep
                  ? AppColors.sageTendre
                  : i == _currentStep
                      ? AppColors.gold
                      : Colors.white.withValues(alpha: 0.12),
              boxShadow: i <= _currentStep
                  ? [
                      BoxShadow(
                        color: (i < _currentStep
                                ? AppColors.sageTendre
                                : AppColors.gold)
                            .withValues(alpha: 0.7),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    return switch (_currentStep) {
      1 => _buildSpecialityStep(),
      2 => _buildDocumentStep(),
      _ => _buildPersonalStep(),
    };
  }

  Widget _buildPersonalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_needsMultiStep)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child:
                Text('INFORMATIONS PERSONNELLES', style: AppTextStyles.label),
          ),
        Row(
          children: [
            Expanded(child: _buildField('PRÉNOM', 'prénom', _firstNameCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildField('NOM', 'nom', _lastNameCtrl)),
          ],
        ),
        const SizedBox(height: 14),
        _buildField('EMAIL', 'votre@email.tn', _emailCtrl,
            icon: '📧', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _buildPasswordFieldWidget(),
        const SizedBox(height: 20),
        if (!_needsMultiStep) ...[
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sage.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('📱', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bienvenue , aprés inscrit tu peuts accéder à tous les modules.',
                    style: AppTextStyles.bodyMuted
                        .copyWith(fontSize: 11.5, height: 1.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildCTAButton(_needsMultiStep
            ? 'Continuer → Étape 2/$_totalSteps'
            : 'Créer mon compte →'),
        if (!_needsMultiStep) ...[
          const SizedBox(height: 18),
          _buildDivider(),
          const SizedBox(height: 14),
          _buildGoogleBtn(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Déjà un compte ? ', style: AppTextStyles.bodyMuted),
              GestureDetector(
                onTap: () => context
                    .goNamed('login', pathParameters: {'role': widget.role}),
                child: Text('Connexion →',
                    style: AppTextStyles.body(12, AppColors.rose,
                        weight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSpecialityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SPÉCIALITÉ PRINCIPALE', style: AppTextStyles.label),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _specialities.map((s) {
            final selected = _selectedSpecialities.contains(s);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _selectedSpecialities.remove(s);
                } else {
                  _selectedSpecialities.add(s);
                }
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      selected ? _accent.withValues(alpha: 0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: selected
                        ? _accent.withValues(alpha: 0.35)
                        : AppColors.rose.withValues(alpha: 0.12),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: _accent.withValues(alpha: 0.2),
                              blurRadius: 16),
                        ]
                      : null,
                ),
                child: Text(
                  s,
                  style: AppTextStyles.body(
                    11,
                    selected ? _accent : AppColors.textMuted,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildCTAButton('Continuer → Étape 3/$_totalSteps'),
      ],
    );
  }

  Widget _buildDocumentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PIÈCES JUSTIFICATIVES', style: AppTextStyles.label),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _accent.withValues(alpha: 0.25),
              width: 1.5,
            ),
            color: _accent.withValues(alpha: 0.04),
          ),
          child: Column(
            children: [
              Text(_pickedFile != null ? '✅' : (_isTherapist ? '📄' : '📄'),
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                _pickedFile != null
                    ? _pickedFile!.name
                    : (_isTherapist
                        ? 'CV professionnel'
                        : 'Diplôme + Certificats'),
                textAlign: TextAlign.center,
                style: AppTextStyles.body(13, AppColors.textPrimary,
                    weight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _pickedFile != null
                    ? '${(_pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} Mo'
                    : (_isTherapist
                        ? 'Format PDF · max 5MB'
                        : 'PDF ou JPG · max 5MB'),
                style: AppTextStyles.bodyMuted.copyWith(fontSize: 11.5),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _pickedFile != null
                            ? 'Changer de fichier'
                            : 'Choisir un fichier',
                        style: AppTextStyles.body(12, _accent,
                            weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              if (_pickedFile != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _pickedFile = null),
                  child: Text('Supprimer',
                      style: TextStyle(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          fontSize: 11)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCTAButton('Finaliser l\'inscription ✓'),
      ],
    );
  }

  Widget _buildField(String label, String hint, TextEditingController ctrl,
      {String? icon, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.rose.withValues(alpha: 0.1), width: 1.5),
          ),
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(icon, style: const TextStyle(fontSize: 15)),
                ),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: keyboardType,
                  style: AppTextStyles.bodyText?.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMuted.copyWith(fontSize: 12),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: icon != null ? 8 : 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFieldWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MOT DE PASSE', style: AppTextStyles.label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.rose.withValues(alpha: 0.1), width: 1.5),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text('🔒', style: TextStyle(fontSize: 15)),
              ),
              Expanded(
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePass,
                  style: AppTextStyles.bodyText?.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: AppTextStyles.bodyMuted.copyWith(fontSize: 12),
                    border: InputBorder.none,
                    filled: false,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    _obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 17,
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

  Widget _buildCTAButton(String text) {
    return GestureDetector(
      onTap: _isLoading ? null : _nextStep,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: _accent.withValues(alpha: 0.42),
                blurRadius: 26,
                offset: const Offset(0, 8)),
            BoxShadow(color: _accent.withValues(alpha: 0.12), blurRadius: 60),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(text, style: AppTextStyles.btnText.copyWith(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: AppColors.rose.withValues(alpha: 0.1), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou continuer avec',
              style: AppTextStyles.body(10, AppColors.textDim,
                  weight: FontWeight.w500)),
        ),
        Expanded(
            child: Divider(
                color: AppColors.rose.withValues(alpha: 0.1), thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleBtn() {
    return GestureDetector(
      onTap: _submit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.rose.withValues(alpha: 0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: AppColors.rose.withValues(alpha: 0.05), blurRadius: 8)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFF4285F4)),
              child: const Center(
                  child: Text('G',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 10),
            Text('Continuer avec Google',
                style: AppTextStyles.body(13, AppColors.textPrimary,
                    weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
