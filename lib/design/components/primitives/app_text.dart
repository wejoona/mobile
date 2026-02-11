import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Text Style Variants
enum AppTextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  // Special variants
  balance,
  percentage,
  cardLabel,
  monoLarge,
  monoMedium,
  monoSmall,
}

/// Semantic text colors that adapt to theme
enum AppTextColor {
  /// Primary text color (high emphasis)
  primary,

  /// Secondary text color (medium emphasis)
  secondary,

  /// Tertiary text color (low emphasis)
  tertiary,

  /// Disabled text color
  disabled,

  /// Inverse text color (for colored backgrounds)
  inverse,

  /// Error text color
  error,

  /// Success text color
  success,

  /// Warning text color
  warning,

  /// Info text color
  info,

  /// Link/primary accent color
  link,
}

/// Luxury Wallet Text Component
/// Wrapper for consistent typography with accessibility support
///
/// Automatically adapts text colors to light/dark theme.
/// Use [semanticColor] for theme-aware colors or [color] for custom colors.
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.semanticColor,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
    this.style,
    this.semanticLabel,
    this.excludeSemantics = false,
  });

  final String text;
  final AppTextVariant variant;

  /// Custom color override (takes precedence over semanticColor)
  final Color? color;

  /// Semantic color that adapts to theme (light/dark)
  final AppTextColor? semanticColor;

  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final TextStyle? style;

  /// Optional semantic label for screen readers (defaults to text)
  final String? semanticLabel;

  /// Whether to exclude this text from semantics tree
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = ThemeColors.of(context);

    // Determine final color
    final Color? finalColor = color ?? _getSemanticColor(context, themeColors, colorScheme);

    final baseStyle = style ?? _getStyle(context);
    final textWidget = Text(
      text,
      style: baseStyle.copyWith(
        color: finalColor,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    // If excludeSemantics is true, wrap with ExcludeSemantics
    if (excludeSemantics) {
      return ExcludeSemantics(child: textWidget);
    }

    // If semanticLabel is provided, wrap with Semantics
    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: textWidget,
      );
    }

    return textWidget;
  }

  /// Get color based on semantic color type and theme
  Color? _getSemanticColor(BuildContext context, ThemeColors themeColors, ColorScheme colorScheme) {
    if (semanticColor == null) {
      // Return default color for variant
      return _getDefaultColorForVariant(themeColors);
    }

    switch (semanticColor!) {
      case AppTextColor.primary:
        return themeColors.textPrimary;

      case AppTextColor.secondary:
        return themeColors.textSecondary;

      case AppTextColor.tertiary:
        return themeColors.textTertiary;

      case AppTextColor.disabled:
        return themeColors.textDisabled;

      case AppTextColor.inverse:
        return themeColors.textInverse;

      case AppTextColor.error:
        return themeColors.errorText;

      case AppTextColor.success:
        return themeColors.successText;

      case AppTextColor.warning:
        return themeColors.warningText;

      case AppTextColor.info:
        return themeColors.infoText;

      case AppTextColor.link:
        return themeColors.gold;
    }
  }

  /// Get default color for text variant based on theme
  Color _getDefaultColorForVariant(ThemeColors themeColors) {
    switch (variant) {
      // Display, headlines, titles use primary text
      case AppTextVariant.displayLarge:
      case AppTextVariant.displayMedium:
      case AppTextVariant.displaySmall:
      case AppTextVariant.headlineLarge:
      case AppTextVariant.headlineMedium:
      case AppTextVariant.headlineSmall:
      case AppTextVariant.titleLarge:
      case AppTextVariant.titleMedium:
      case AppTextVariant.titleSmall:
      case AppTextVariant.bodyLarge:
      case AppTextVariant.labelLarge:
      case AppTextVariant.monoLarge:
      case AppTextVariant.monoMedium:
      case AppTextVariant.balance:
        return themeColors.textPrimary;

      // Body medium, labels use secondary text
      case AppTextVariant.bodyMedium:
      case AppTextVariant.labelMedium:
      case AppTextVariant.cardLabel:
      case AppTextVariant.monoSmall:
        return themeColors.textSecondary;

      // Small text uses tertiary
      case AppTextVariant.bodySmall:
      case AppTextVariant.labelSmall:
        return themeColors.textTertiary;

      // Percentage uses success color
      case AppTextVariant.percentage:
        return themeColors.successText;
    }
  }

  /// Get text style for variant
  TextStyle _getStyle(BuildContext context) {
    switch (variant) {
      case AppTextVariant.displayLarge:
        return AppTypography.displayLarge;
      case AppTextVariant.displayMedium:
        return AppTypography.displayMedium;
      case AppTextVariant.displaySmall:
        return AppTypography.displaySmall;
      case AppTextVariant.headlineLarge:
        return AppTypography.headlineLarge;
      case AppTextVariant.headlineMedium:
        return AppTypography.headlineMedium;
      case AppTextVariant.headlineSmall:
        return AppTypography.headlineSmall;
      case AppTextVariant.titleLarge:
        return AppTypography.titleLarge;
      case AppTextVariant.titleMedium:
        return AppTypography.titleMedium;
      case AppTextVariant.titleSmall:
        return AppTypography.titleSmall;
      case AppTextVariant.bodyLarge:
        return AppTypography.bodyLarge;
      case AppTextVariant.bodyMedium:
        return AppTypography.bodyMedium;
      case AppTextVariant.bodySmall:
        return AppTypography.bodySmall;
      case AppTextVariant.labelLarge:
        return AppTypography.labelLarge;
      case AppTextVariant.labelMedium:
        return AppTypography.labelMedium;
      case AppTextVariant.labelSmall:
        return AppTypography.labelSmall;
      case AppTextVariant.balance:
        return AppTypography.balanceDisplay;
      case AppTextVariant.percentage:
        return AppTypography.percentageChange;
      case AppTextVariant.cardLabel:
        return AppTypography.cardLabel;
      case AppTextVariant.monoLarge:
        return AppTypography.monoLarge;
      case AppTextVariant.monoMedium:
        return AppTypography.monoMedium;
      case AppTextVariant.monoSmall:
        return AppTypography.monoSmall;
    }
  }
}
