import 'package:flutter/material.dart';

/// Typography System
/// Display: Playfair Display (brand/editorial moments only)
/// Body: DM Sans (product UI, money, controls)
/// Mono: JetBrains Mono (numbers, codes)
///
/// Fonts are bundled in pubspec.yaml so production rendering never depends on
/// runtime network font fetching.
class AppTypography {
  AppTypography._();

  static const String displayFamily = 'PlayfairDisplay';
  static const String bodyFamily = 'DMSans';
  static const String monoFamily = 'JetBrainsMono';

  static const List<String> _displayFallback = <String>[
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Georgia',
    'Times New Roman',
    '.SF Pro Display',
  ];

  static const List<String> _bodyFallback = <String>[
    'Apple Color Emoji',
    'Noto Color Emoji',
    '.SF Pro Text',
    'Arial',
    'sans-serif',
  ];

  static const List<String> _monoFallback = <String>[
    'Apple Color Emoji',
    'Noto Color Emoji',
    'Menlo',
    'Monaco',
    'monospace',
  ];

  static const List<FontFeature> _tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: _displayFallback,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: _displayFallback,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.15,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFamily,
    fontFamilyFallback: _displayFallback,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.45,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.45,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.35,
  );

  // Mono styles
  static const TextStyle monoLarge = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: _monoFallback,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.3,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: _monoFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: _monoFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.35,
    fontFeatures: _tabularFigures,
  );

  // Special styles
  static const TextStyle moneyDisplay = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.05,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle moneyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.12,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle moneyMedium = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle moneySmall = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle balanceDisplay = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.2,
    fontFeatures: _tabularFigures,
  );

  static const TextStyle percentageChange = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  static const TextStyle cardLabel = TextStyle(
    fontFamily: bodyFamily,
    fontFamilyFallback: _bodyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Caption (alias for labelSmall for backwards compatibility).
  static const TextStyle caption = labelSmall;
}
