import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';

/// Legacy convenience names for use with AppText's `style` parameter.
///
/// Prefer AppTextVariant or AppTypography in new code. These aliases stay
/// token-backed so older screens do not drift into a separate type scale.
class AppTextStyle {
  AppTextStyle._();

  static const TextStyle headingLarge = AppTypography.headlineSmall;

  static const TextStyle headingMedium = AppTypography.titleLarge;

  static const TextStyle headingSmall = AppTypography.titleSmall;

  static const TextStyle bodyLarge = AppTypography.bodyLarge;

  static const TextStyle bodyMedium = AppTypography.bodyMedium;

  static const TextStyle bodySmall = AppTypography.bodySmall;

  static const TextStyle labelLarge = AppTypography.labelLarge;

  static const TextStyle labelMedium = AppTypography.labelMedium;

  static const TextStyle labelSmall = AppTypography.labelSmall;
}
