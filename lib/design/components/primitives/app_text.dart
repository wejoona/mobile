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
/// Wrapper for consistent typography
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
  });

  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getStyle().copyWith(
        color: color,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
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
