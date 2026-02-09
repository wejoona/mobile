import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography System
/// Display: Playfair Display (headlines, amounts)
/// Body: DM Sans (everything else)
/// Mono: JetBrains Mono (numbers, codes)
///
/// NOTE: Colors are NOT hardcoded here. They are inherited from Theme.of(context)
/// or can be overridden in AppText component.
///
/// In test mode (when GoogleFonts.config.allowRuntimeFetching is false),
/// system fonts are used instead to avoid network dependencies.
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════════════════════════════
  // TEST MODE DETECTION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if we're in test mode (runtime font fetching disabled)
  static bool get _isTestMode => !GoogleFonts.config.allowRuntimeFetching;

  // ═══════════════════════════════════════════════════════════════════════════
  // SYSTEM FONT FALLBACKS (for tests)
  // ═══════════════════════════════════════════════════════════════════════════

  static const String _systemDisplayFont = '.SF Pro Display';
  static const String _systemBodyFont = '.SF Pro Text';
  static const String _systemMonoFont = 'Menlo';

  // ═══════════════════════════════════════════════════════════════════════════
  // FONT FAMILIES
  // ═══════════════════════════════════════════════════════════════════════════

  static String get displayFamily => _isTestMode
      ? _systemDisplayFont
      : GoogleFonts.playfairDisplay().fontFamily!;
  static String get bodyFamily =>
      _isTestMode ? _systemBodyFont : GoogleFonts.dmSans().fontFamily!;
  static String get monoFamily =>
      _isTestMode ? _systemMonoFont : GoogleFonts.jetBrainsMono().fontFamily!;

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPLAY STYLES (Large headlines, balance amounts)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get displayLarge => _isTestMode
      ? const TextStyle(
          fontFamily: _systemDisplayFont,
          fontSize: 72,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
          height: 1.1,
        )
      : GoogleFonts.playfairDisplay(
          fontSize: 72,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
          height: 1.1,
        );

  static TextStyle get displayMedium => _isTestMode
      ? const TextStyle(
          fontFamily: _systemDisplayFont,
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.15,
        )
      : GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.15,
        );

  static TextStyle get displaySmall => _isTestMode
      ? const TextStyle(
          fontFamily: _systemDisplayFont,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
          height: 1.2,
        )
      : GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
          height: 1.2,
        );

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADLINE STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get headlineLarge => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.25,
        )
      : GoogleFonts.dmSans(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.25,
        );

  static TextStyle get headlineMedium => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.3,
        )
      : GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.3,
        );

  static TextStyle get headlineSmall => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.35,
        )
      : GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.35,
        );

  // ═══════════════════════════════════════════════════════════════════════════
  // TITLE STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get titleLarge => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.4,
        )
      : GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.4,
        );

  static TextStyle get titleMedium => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.45,
        )
      : GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.45,
        );

  static TextStyle get titleSmall => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.5,
        )
      : GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.5,
        );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get bodyLarge => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        )
      : GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        );

  static TextStyle get bodyMedium => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.45,
        )
      : GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.45,
        );

  static TextStyle get bodySmall => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.4,
        )
      : GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.4,
        );

  // ═══════════════════════════════════════════════════════════════════════════
  // LABEL STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get labelLarge => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.45,
        )
      : GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.45,
        );

  static TextStyle get labelMedium => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        )
      : GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        );

  static TextStyle get labelSmall => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.35,
        )
      : GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.35,
        );

  // ═══════════════════════════════════════════════════════════════════════════
  // MONO STYLES (Numbers, codes, amounts)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle get monoLarge => _isTestMode
      ? const TextStyle(
          fontFamily: _systemMonoFont,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          height: 1.3,
        )
      : GoogleFonts.jetBrainsMono(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          height: 1.3,
        );

  static TextStyle get monoMedium => _isTestMode
      ? const TextStyle(
          fontFamily: _systemMonoFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.4,
        )
      : GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.4,
        );

  static TextStyle get monoSmall => _isTestMode
      ? const TextStyle(
          fontFamily: _systemMonoFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.35,
        )
      : GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.35,
        );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Balance display - large number
  static TextStyle get balanceDisplay => _isTestMode
      ? const TextStyle(
          fontFamily: _systemDisplayFont,
          fontSize: 42,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          height: 1.2,
        )
      : GoogleFonts.playfairDisplay(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          height: 1.2,
        );

  /// Percentage change
  static TextStyle get percentageChange => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
        )
      : GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
        );

  /// Button text
  static TextStyle get button => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.2,
        )
      : GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.2,
        );

  /// Card label
  static TextStyle get cardLabel => _isTestMode
      ? const TextStyle(
          fontFamily: _systemBodyFont,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        )
      : GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        );

  /// Caption (alias for labelSmall for backwards compatibility)
  static TextStyle get caption => labelSmall;
}
