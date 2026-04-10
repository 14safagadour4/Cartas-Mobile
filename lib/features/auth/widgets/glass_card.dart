import 'dart:ui';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable glassmorphism card — Feminine Botanical style
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? leftAccentColor;
  final Color? leftAccentGlow;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool dark;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.leftAccentColor,
    this.leftAccentGlow,
    this.padding = const EdgeInsets.all(15),
    this.borderRadius = 20,
    this.backgroundColor,
    this.dark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (dark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.white.withOpacity(0.82)),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: dark
                  ? Colors.white.withOpacity(0.09)
                  : Colors.white.withOpacity(0.82),
              width: 1,
            ),
            boxShadow: dark
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ]
                : AppColors.glassShadow,
          ),
          child: Stack(
            children: [
              // Content
              child,

              // Left accent glow bar
              if (leftAccentColor != null)
                Positioned(
                  left: -15,
                  top: -15,
                  bottom: -15,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(4),
                      ),
                      color: leftAccentColor,
                      boxShadow: [
                        BoxShadow(
                          color: (leftAccentGlow ?? leftAccentColor!).withOpacity(0.7),
                          blurRadius: 14,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: (leftAccentGlow ?? leftAccentColor!).withOpacity(0.4),
                          blurRadius: 28,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// Dark glass card (for dark backgrounds)
class DarkGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glowColor;

  const DarkGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 20,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!.withOpacity(0.06),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              BoxShadow(
                color: Colors.white.withOpacity(0.06),
                blurRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}