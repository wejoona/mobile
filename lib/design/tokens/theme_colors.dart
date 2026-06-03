import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';

/// Theme-aware colors extension on BuildContext.
///
/// Use this instead of hardcoded AppColors for theme switching:
///
/// ```dart
/// // Before (hardcoded dark):
/// backgroundColor: AppColors.obsidian,
///
/// // After (theme-aware):
/// backgroundColor: context.colors.canvas,
/// ```
extension ThemeColorsExtension on BuildContext {
  ThemeColors get colors => ThemeColors.of(this);
}

/// Theme-aware color palette.
///
/// Automatically returns light or dark colors based on current theme.
class ThemeColors {
  final bool isDark;

  const ThemeColors._({required this.isDark});

  factory ThemeColors.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ThemeColors._(isDark: brightness == Brightness.dark);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BACKGROUNDS
  // ════════════════════════════════════════════════════════════════════════════

  /// Main screen background (obsidian dark / porcelain light)
  Color get canvas => isDark ? AppColors.obsidian : AppColorsLight.canvas;

  /// Card/container background (slate dark / ivory light)
  Color get container => isDark ? AppColors.slate : AppColorsLight.container;

  /// Elevated surface (charcoal dark / champagne light)
  Color get elevated => isDark ? AppColors.elevated : AppColorsLight.elevated;

  /// Secondary surface (graphite dark / light surface)
  Color get surface => isDark ? AppColors.graphite : AppColorsLight.surface;

  // ════════════════════════════════════════════════════════════════════════════
  // TEXT
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary text color
  Color get textPrimary =>
      isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;

  /// Secondary text color
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

  /// Tertiary/hint text color
  Color get textTertiary =>
      isDark ? AppColors.textTertiary : AppColorsLight.textTertiary;

  /// Disabled text color
  Color get textDisabled =>
      isDark ? AppColors.textDisabled : AppColorsLight.textDisabled;

  /// Inverse text used by legacy brand surfaces. Kept dark for gold contrast.
  Color get textInverse => AppColors.textInverse;

  /// Text color for gold/champagne fills.
  Color get onGold =>
      isDark ? AppColors.textInverse : AppColorsLight.textInverse;

  /// Text color for deep ink/obsidian fills.
  Color get onDark =>
      isDark ? AppColors.textPrimary : AppColorsLight.textInverse;

  // ════════════════════════════════════════════════════════════════════════════
  // BRAND
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary gold
  Color get gold => isDark ? AppColors.gold500 : AppColorsLight.gold500;
  Color get primary => gold;

  /// Gold for text/icons on strong backgrounds
  Color get goldLight => isDark ? AppColors.gold400 : AppColorsLight.gold400;

  /// Gold for backgrounds
  Color get goldSubtle => isDark ? AppColors.gold900 : AppColorsLight.gold100;

  /// Gold gradient for decorative elements
  List<Color> get goldGradient => isDark
      ? AppColors.goldGradient
      : [AppColorsLight.gold500, AppColorsLight.gold500];

  // ════════════════════════════════════════════════════════════════════════════
  // SEMANTIC
  // ════════════════════════════════════════════════════════════════════════════

  /// Success color
  Color get success =>
      isDark ? AppColors.successBase : AppColorsLight.successBase;

  /// Success background
  Color get successBg =>
      isDark ? AppColors.successLight : AppColorsLight.successLight;

  /// Success text
  Color get successText =>
      isDark ? AppColors.successText : AppColorsLight.successText;

  /// Error color
  Color get error => isDark ? AppColors.errorBase : AppColorsLight.errorBase;

  /// Error background
  Color get errorBg =>
      isDark ? AppColors.errorLight : AppColorsLight.errorLight;

  /// Error text
  Color get errorText =>
      isDark ? AppColors.errorText : AppColorsLight.errorText;

  /// Warning color
  Color get warning =>
      isDark ? AppColors.warningBase : AppColorsLight.warningBase;

  /// Warning base (alias for warning)
  Color get warningBase =>
      isDark ? AppColors.warningBase : AppColorsLight.warningBase;

  /// Warning background
  Color get warningBg =>
      isDark ? AppColors.warningLight : AppColorsLight.warningLight;

  /// Warning text
  Color get warningText =>
      isDark ? AppColors.warningText : AppColorsLight.warningText;

  /// Info color
  Color get info => isDark ? AppColors.infoBase : AppColorsLight.infoBase;

  /// Info background
  Color get infoBg => isDark ? AppColors.infoLight : AppColorsLight.infoLight;

  /// Info text
  Color get infoText => isDark ? AppColors.infoText : AppColorsLight.infoText;

  // ════════════════════════════════════════════════════════════════════════════
  // BORDERS
  // ════════════════════════════════════════════════════════════════════════════

  /// Default border
  Color get border =>
      isDark ? AppColors.borderDefault : AppColorsLight.borderDefault;

  /// Subtle border
  Color get borderSubtle =>
      isDark ? AppColors.borderSubtle : AppColorsLight.borderSubtle;

  /// Strong border (focused)
  Color get borderStrong =>
      isDark ? AppColors.borderStrong : AppColorsLight.borderStrong;

  /// Gold border
  Color get borderGold =>
      isDark ? AppColors.borderGold : AppColorsLight.borderGold;

  // ════════════════════════════════════════════════════════════════════════════
  // ICONS
  // ════════════════════════════════════════════════════════════════════════════

  /// Primary icon color
  Color get icon => isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;

  /// Secondary icon color
  Color get iconSecondary =>
      isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;

  /// Disabled icon color
  Color get iconDisabled =>
      isDark ? AppColors.textDisabled : AppColorsLight.textDisabled;

  // ════════════════════════════════════════════════════════════════════════════
  // OVERLAYS
  // ════════════════════════════════════════════════════════════════════════════

  /// Scrim overlay (for modals, dialogs)
  Color get scrim => isDark ? Colors.black54 : Colors.black38;
}
