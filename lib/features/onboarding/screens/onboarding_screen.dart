import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/localization/language_provider.dart';
import 'package:cartas/features/auth/widgets/language_selector.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isArabic = lang.locale.languageCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.petalCream, // Fond crème chaud
        ),
        child: Stack(
          children: [
            // Caleidoscope de lumières douces en arrière-plan
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: _currentPage == 0 ? -100 : _currentPage == 1 ? -50 : -150,
              left: _currentPage == 0 ? -100 : _currentPage == 1 ? MediaQuery.of(context).size.width * 0.5 : -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getColor(_currentPage).withOpacity(0.15),
                      AppColors.petalCream.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Floating decorations
            ..._buildDecorations(),

            SafeArea(
              child: Column(
                children: [
                  // Language selector and skip button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LanguageSelector(languageProvider: lang),
                        GestureDetector(
                          onTap: () => context.go('/actor-choice'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.rose.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.rose.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              lang.getText('skip'),
                              style: AppTextStyles.body(13, AppColors.textMuted, weight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return _buildPage(
                          index: index,
                          title: _getTitle(index, lang),
                          description: _getDescription(index, lang),
                          imagePath: _getImagePath(index),
                        );
                      },
                    ),
                  ),

                  // Indicators and button
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                                (index) => _buildIndicator(index, lang),
                          ),
                        ),
                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: () {
                            if (_currentPage == 2) {
                              context.go('/actor-choice');
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getColor(_currentPage),
                                  _getSecondaryColor(_currentPage),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: _getColor(_currentPage).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _currentPage == 2 ? lang.getText('start') : lang.getText('next'),
                                style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildPage({
    required int index,
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240, // Plus grand pour une image
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getColor(index).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    // On met un placeholder le temps que les images soient ajoutées
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _getColor(index).withOpacity(0.2),
                        child: Center(
                          child: Text(
                            'IMAGE\n$imagePath',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _getColor(index), fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.display(28, AppColors.deepBrown, weight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(15, AppColors.textPrimary.withOpacity(0.7), weight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, LanguageProvider lang) {
    final isArabic = lang.locale.languageCode == 'ar';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 6),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? _getColor(index)
            : AppColors.rose.withOpacity(0.15),
      ),
    );
  }

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return AppColors.roseVif; // Dominante rose pour la première étape
      case 1:
        return AppColors.lavande; // Dominante lavande pour le labo/communauté
      case 2:
        return AppColors.sage;    // Dominante vert sauge pour terminer
      default:
        return AppColors.roseVif;
    }
  }

  Color _getSecondaryColor(int index) {
    switch (index) {
      case 0:
        return AppColors.roseMid;
      case 1:
        return AppColors.lavandeVif;
      case 2:
        return AppColors.sageTendre;
      default:
        return AppColors.roseMid;
    }
  }

  String _getImagePath(int index) {
    switch (index) {
      case 0:
        return 'assets/images/boutique/atelier_apothicaire.jpg'; // Ex: image de la famille en réalité augmentée
      case 1:
        return 'assets/images/CartagoBox famille exp.jpg'; // Ex: image des femmes en cercle / sororité
      case 2:
        return 'assets/images/community plantes.jpg'; // Ex: image de la grand-mère et la fille
      default:
        return 'assets/images/plantiiis desginee.jpg';
    }
  }

  String _getTitle(int index, LanguageProvider lang) {
    switch (index) {
      case 0:
        return lang.getText('onboarding_title_1');
      case 1:
        return lang.getText('onboarding_title_2');
      case 2:
        return lang.getText('onboarding_title_3');
      default:
        return '';
    }
  }

  String _getDescription(int index, LanguageProvider lang) {
    switch (index) {
      case 0:
        return lang.getText('onboarding_desc_1');
      case 1:
        return lang.getText('onboarding_desc_2');
      case 2:
        return lang.getText('onboarding_desc_3');
      default:
        return '';
    }
  }

  List<Widget> _buildDecorations() {
    return [
      Positioned(
        top: 80,
        left: -10,
        child: Text('✨', style: TextStyle(fontSize: 40, color: AppColors.roseVif.withOpacity(0.3))),
      ),
      Positioned(
        top: 150,
        right: -20,
        child: Text('🌸', style: TextStyle(fontSize: 70, color: AppColors.rose.withOpacity(0.15))),
      ),
      Positioned(
        bottom: 200,
        left: 20,
        child: Text('🌿', style: TextStyle(fontSize: 50, color: AppColors.sage.withOpacity(0.2))),
      ),
      Positioned(
        bottom: 120,
        right: 40,
        child: Text('🌺', style: TextStyle(fontSize: 45, color: AppColors.roseMid.withOpacity(0.2))),
      ),
    ];
  }
}