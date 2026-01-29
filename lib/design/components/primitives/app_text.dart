import 'package:flutter/material.dart';
import '../../tokens/index.dart';

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

/// Luxury Wallet Text Component
/// Wrapper for consistent typography with accessibility support
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
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
  final Color? color;
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
    final baseStyle = style ?? _getStyle();
    final textWidget = Text(
      text,
      style: baseStyle.copyWith(
        color: color,
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

  TextStyle _getStyle() {
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
