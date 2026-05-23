import 'package:flutter/material.dart';

/// CARTAS — Feminine Botanical Palette
/// Soft Glow · Rose Pâle · Lavande · Sahara Gold
class AppColors {
  AppColors._();

  // ── Rose / Hibiscus ──────────────────────────────────
  static const Color roseDeep      = Color(0xFF5C1F3A);
  static const Color rose          = Color(0xFF7D3050);
  static const Color roseMid       = Color(0xFFA8547A);
  static const Color roseVif       = Color(0xFFE879A0);
  static const Color rosePale      = Color(0xFFF5E8EE);
  static const Color blossomBlush  = Color(0xFFFDDDE6);
  static const Color petalCream    = Color(0xFFFBF2F6);

  // ── Lavande / Art-Thérapeute ─────────────────────────
  static const Color lavandeDark   = Color(0xFF4A1280);
  static const Color lavandeDeep   = Color(0xFF7B35C0);
  static const Color lavande       = Color(0xFFBAA0E6);
  static const Color lavandeLight  = Color(0xFFD0A8F0);
  static const Color lavandeVif    = Color(0xFFA879E8);
  static const Color lavandeGlow   = Color(0xFF9050D8);

  // ── Sage / Spécialiste ───────────────────────────────
  static const Color sageDark      = Color.fromARGB(255, 140, 223, 150);
  static const Color sage          = Color(0xFF50A060);
  static const Color sageTendre    = Color(0xFF7BC47E);
  static const Color sagePale      = Color(0xFFEBF5D9);

  // ── Sahara Gold ──────────────────────────────────────
  static const Color goldDeep      = Color(0xFFA07840);
  static const Color gold          = Color(0xFFC9A96E);
  static const Color goldLight     = Color(0xFFE8C96A);
  static const Color goldPale      = Color(0xFFFBF3E3);
  static const Color goldSoft      = Color(0xFFE8D5A3);

  // ── Cream / Background ───────────────────────────────
  static const Color cream         = Color(0xFFFAF6F0);
  static const Color creamWarm     = Color(0xFFFAF0F4);

  // ── Dark / Night ─────────────────────────────────────
  static const Color darkNight     = Color(0xFF0A0510);
  static const Color darkDeep      = Color(0xFF100515);
  static const Color darkMid       = Color(0xFF1A0814);
  static const Color darkCard      = Color(0xFF280A22);

  // ── Text ─────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF2A1020);
  static const Color textMuted     = Color(0xFF9B7080);
  static const Color textDim       = Color(0xFFD4A8C0);

  // ── Glass ────────────────────────────────────────────
  static const Color glassWhite    = Color(0xD9FFFFF5);  // rgba(255,245,250,0.85)
  static const Color glassDark     = Color(0x14FFFFFF);  // rgba(255,255,255,0.08)

  // ── Gradients ────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0510), Color(0xFF22082A), Color(0xFF7D3058), Color(0xFFD4709A)],
    stops: [0.0, 0.25, 0.65, 1.0],
  );

  static const LinearGradient authTopGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0510), Color(0xFF22082A), Color(0xFF7D3058), Color(0xFFD4709A)],
    stops: [0.0, 0.30, 0.65, 1.0],
  );

  static const LinearGradient roseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8C2050), Color(0xFFC5507E), Color(0xFFE879A0)],
  );

  static const LinearGradient lavandeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A1280), Color(0xFF9050D8), Color(0xFFB880F0)],
  );

  static const LinearGradient sageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A6030), Color(0xFF50A060), Color(0xFF7BC47E)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C96A), Color(0xFFC9A96E), Color(0xFFA07840)],
  );

  // ── Shadows & Glows ──────────────────────────────────
  static List<BoxShadow> roseShadow = [
    BoxShadow(color: roseVif.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 8)),
    BoxShadow(color: roseVif.withOpacity(0.12), blurRadius: 60, spreadRadius: 0),
  ];

  static List<BoxShadow> lavandeShadow = [
    BoxShadow(color: lavandeGlow.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 8)),
    BoxShadow(color: lavandeGlow.withOpacity(0.12), blurRadius: 60, spreadRadius: 0),
  ];

  static List<BoxShadow> goldGlowShadow = [
    BoxShadow(color: gold.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 0)),
    BoxShadow(color: gold.withOpacity(0.2), blurRadius: 80, spreadRadius: 0),
  ];

  static List<BoxShadow> glassShadow = [
    BoxShadow(color: rose.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 0, offset: const Offset(0, 1)),
  ];

  static Color get primary => roseVif;
  static Color get secondary => lavande;
  static Color get primaryGreen => sage;
  static Color get secondaryGreen => sageTendre;
  static Color get accentColor => gold;
  static Color get partnerColor => lavandeDeep;

  static Color get ivoryWhite => cream;

  static Color get warmBeige => creamWarm;

  static Color get saharaGold => gold;

  static Color get saharaGoldLight => goldLight;

  static Color get sageGreen => sage;

  static Color get royalHibiscus => roseVif;

  static Color get deepBrown => textPrimary;
}
