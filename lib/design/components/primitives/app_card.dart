import 'package:flutter/material.dart';
import '../../tokens/index.dart';

/// Card Variants
enum AppCardVariant {
  /// Standard elevated card
  elevated,

  /// Card with gold border accent
  goldAccent,

  /// Subtle card with minimal styling
  subtle,

  /// Glass morphism effect
  glass,
}

/// Luxury Wallet Card Component
/// Pure presentational component
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: _buildDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
          splashColor: AppColors.overlayLight,
          highlightColor: AppColors.overlayLight,
          child: Padding(
            padding: padding ??
                const EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final radius = borderRadius ?? AppRadius.xl;

    switch (variant) {
      case AppCardVariant.elevated:
        return BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1,
          ),
          boxShadow: AppShadows.card,
        );

      case AppCardVariant.goldAccent:
        return BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: AppColors.borderGold,
            width: 1,
          ),
          boxShadow: AppShadows.card,
        );

      case AppCardVariant.subtle:
        return BoxDecoration(
          color: AppColors.graphite,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1,
          ),
        );

      case AppCardVariant.glass:
        return BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1,
          ),
          boxShadow: AppShadows.md,
        );
    }
  }
}
