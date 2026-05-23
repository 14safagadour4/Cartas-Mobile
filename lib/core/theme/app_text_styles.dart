import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Styles pour les grands titres (Splash, Onboarding, Home Headings)
  static TextStyle title(double size, Color color, {FontWeight weight = FontWeight.w800, double height = 1.2}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );
  }

  // Styles pour les textes standards et descriptions
  static TextStyle body(double size, Color color, {FontWeight weight = FontWeight.w600, double height = 1.4, bool italic = false}) {
    return GoogleFonts.outfit(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }

  // Texte grisé/discret souvent utilisé
  static TextStyle get bodyMuted {
    return const TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 14,
      color: AppColors.textDim,
      fontWeight: FontWeight.normal,
    );
  }

  // Style spécifique pour les boutons
  static TextStyle get btnText {
    return const TextStyle(
      fontFamily: 'CabinetGrotesk',
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  static Null get headlineLarge => null;

  static Null get bodyMedium => null;

  static TextStyle? get tag => null;

  static TextStyle? get onboardingDesc => null;

  static TextStyle? get onboardingTitle => null;

  static TextStyle? get modalTitle => null;

  static TextStyle? get label => null;

  static TextStyle? get bodyText => null;

  static TextStyle? get headlineSmall => null;


  // lib/core/theme/app_text_styles.dart
  static TextStyle display(double size, Color color, {FontWeight weight = FontWeight.normal}) {
    return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
    );
  }
}