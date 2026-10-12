import 'package:flutter/material.dart';

/// Refined, warm, tasteful pet-care visual palette.
/// Free of overwhelming blue, neon gradients, or artificial UI tropes.
class AppColors {
  AppColors._();

  // --- Backgrounds & Surfaces (Warm Ivory & Off-White) ---
  static const Color background = Color(0xFFFAF8F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F0E8);
  static const Color surfaceContainerLow = Color(0xFFF7F4ED);
  static const Color surfaceContainer = Color(0xFFEFEBE2);
  static const Color inputBackground = Color(0xFFF7F5EE);

  // --- Primary Accent: Soft Sage Green & Deep Forest ---
  static const Color primary = Color(0xFF2D5F4A);
  static const Color primaryLight = Color(0xFF457962);
  static const Color primaryDark = Color(0xFF1B3F30);
  static const Color primaryContainer = Color(0xFFE3EDE7);
  static const Color onPrimaryContainer = Color(0xFF1B4031);
  static const Color primarySurface = Color(0xFFF1F6F3);

  // --- Secondary Accents: Warm Coral & Soft Peach ---
  static const Color accentCoral = Color(0xFFDE6B48);
  static const Color accentPeach = Color(0xFFFBECE8);
  static const Color onAccentPeach = Color(0xFF9A3412);
  static const Color badgeAmber = Color(0xFFD97706);
  static const Color badgeAmberContainer = Color(0xFFFEF3C7);

  // --- Supporting Accents: Warm Beige & Subtle Lavender ---
  static const Color warmBeige = Color(0xFFF5F1E9);
  static const Color warmBeigeDark = Color(0xFFE8E2D5);
  static const Color softLavender = Color(0xFFF2EEF7);
  static const Color lavenderBorder = Color(0xFFE2DCE9);

  // --- Typography (Dark Charcoal & Warm Grey) ---
  static const Color mainText = Color(0xFF222629);
  static const Color secondaryText = Color(0xFF6B7278);
  static const Color mutedText = Color(0xFF9AA1A6);

  // --- Borders & Outlines ---
  static const Color border = Color(0xFFE6E2D8);
  static const Color borderLight = Color(0xFFF0ECE4);
  static const Color inputBorder = Color(0xFFDBD6CA);
  static const Color outlineVariant = Color(0xFFE4DFD5);

  // --- System Feedback ---
  static const Color errorRed = Color(0xFFC0392B);
  static const Color errorContainer = Color(0xFFFDE8E8);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);

  // --- Backward-compatible aliases mapped to the new warm palette ---
  static const Color sageGreen = primary;
  static const Color softSage = primaryContainer;
  static const Color warmCoral = accentCoral;
  static const Color parchment = warmBeige;
  static const Color primaryPurple = primary;
  static const Color skyBlue = primaryContainer;
  static const Color lightSky = primarySurface;
  static const Color skyContainer = primaryContainer;
  static const Color skyFixedDim = primaryLight;
  static const Color lavenderFixed = softLavender;
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color glassShadow = Color(0x0A2D5F4A);
}
