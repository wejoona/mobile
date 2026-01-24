import 'package:flutter/material.dart';

/// Luxury Wallet Color System
/// Based on psychology: Dark = Premium, Gold = Achievement, Low Saturation = Sophistication
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK FOUNDATIONS (70% of UI)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color obsidian = Color(0xFF0A0A0C);      // Main canvas - deep void
  static const Color graphite = Color(0xFF111115);      // Elevated surfaces
  static const Color slate = Color(0xFF1A1A1F);         // Cards, containers
  static const Color elevated = Color(0xFF222228);      // Hover states, inputs
  static const Color glass = Color(0xD91A1A1F);         // Glassmorphism (85% opacity)

  // Background aliases
  static const Color backgroundPrimary = obsidian;
  static const Color backgroundSecondary = graphite;
  static const Color backgroundTertiary = slate;
  static const Color backgroundElevated = elevated;

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT HIERARCHY (20% of UI)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFFF5F5F0);   // High emphasis - ivory
  static const Color textSecondary = Color(0xFF9A9A9E); // Medium emphasis - labels
  static const Color textTertiary = Color(0xFF6B6B70);  // Low emphasis - hints
  static const Color textDisabled = Color(0xFF4A4A4E);  // Disabled states
  static const Color textInverse = Color(0xFF0A0A0C);   // On gold/light backgrounds

  // ═══════════════════════════════════════════════════════════════════════════
  // GOLD ACCENT SYSTEM (5% of UI - High Impact)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color gold50 = Color(0xFFFDF8E7);
  static const Color gold100 = Color(0xFFF9EDCC);
  static const Color gold200 = Color(0xFFF0D999);
  static const Color gold300 = Color(0xFFE5C266);
  static const Color gold400 = Color(0xFFD9AE40);
  static const Color gold500 = Color(0xFFC9A962);       // PRIMARY - CTAs, rewards
  static const Color gold600 = Color(0xFFB89852);       // Pressed state
  static const Color gold700 = Color(0xFF9A7A3D);       // Borders
  static const Color gold800 = Color(0xFF7A5E2F);       // Dark accent
  static const Color gold900 = Color(0xFF5C4522);       // Subtle gold

  // Gradient colors
  static const List<Color> goldGradient = [
    Color(0xFFC9A962),
    Color(0xFFE5C266),
    Color(0xFFC9A962),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Success - Emerald (wealth, growth)
  static const Color successBase = Color(0xFF2D6A4F);
  static const Color successLight = Color(0xFF3D8B6E);
  static const Color successDark = Color(0xFF1E4D38);
  static const Color successText = Color(0xFF7DD3A8);

  // Warning - Amber
  static const Color warningBase = Color(0xFFC9943A);
  static const Color warningLight = Color(0xFFDAA84E);
  static const Color warningDark = Color(0xFFA67828);
  static const Color warningText = Color(0xFFF0C674);

  // Error - Crimson velvet
  static const Color errorBase = Color(0xFF8B2942);
  static const Color errorLight = Color(0xFFA63D4E);
  static const Color errorDark = Color(0xFF6D1F33);
  static const Color errorText = Color(0xFFE57B8D);

  // Info - Steel blue
  static const Color infoBase = Color(0xFF4A6FA5);
  static const Color infoLight = Color(0xFF5B82B8);
  static const Color infoDark = Color(0xFF3A5A89);
  static const Color infoText = Color(0xFF8BB4E0);

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDERS & DIVIDERS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color borderSubtle = Color(0x0FFFFFFF);    // 6% white
  static const Color borderDefault = Color(0x1AFFFFFF);   // 10% white
  static const Color borderStrong = Color(0x26FFFFFF);    // 15% white
  static const Color borderGold = Color(0x4DC9A962);      // 30% gold
  static const Color borderGoldStrong = Color(0x80C9A962); // 50% gold

  // ═══════════════════════════════════════════════════════════════════════════
  // OVERLAYS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color overlayLight = Color(0x0DFFFFFF);    // 5% white
  static const Color overlayMedium = Color(0x1AFFFFFF);   // 10% white
  static const Color overlayDark = Color(0x80000000);     // 50% black
  static const Color overlayScrim = Color(0xCC000000);    // 80% black
}
