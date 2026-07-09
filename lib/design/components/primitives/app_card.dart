import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Card Variants
enum AppCardVariant {
  /// Flat card with subtle border, no shadow
  flat,

  /// Elevated card with shadow, no border (default)
  elevated,

  /// Outlined card with visible border, no shadow
  outlined,

  /// Filled card with solid background color
  filled,

  /// Card with gold border accent
  goldAccent,

  /// Subtle card with minimal styling (deprecated, use flat)
  @Deprecated('Use AppCardVariant.flat instead')
  subtle,

  /// Glass morphism effect
  glass,
}

/// Luxury Wallet Card Component
/// Pure presentational component with theme-aware styling
///
/// Usage:
/// ```dart
/// AppCard(
///   variant: AppCardVariant.flat,
///   onTap: () => print('Tapped'),
///   child: Text('Card content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.flat,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.isSelected = false,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? borderRadius;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final decoration = _buildDecoration(colors);

    return Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
          splashColor: _getSplashColor(colors),
          highlightColor: _getHighlightColor(colors),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(ThemeColors colors) {
    final radius = borderRadius ?? AppRadius.xl;

    switch (variant) {
      case AppCardVariant.flat:
        return BoxDecoration(
          color: backgroundColor ?? colors.container,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color:
                borderColor ?? (isSelected ? colors.gold : colors.borderSubtle),
            width: isSelected ? 2 : 1,
          ),
        );

      case AppCardVariant.elevated:
        return BoxDecoration(
          color: backgroundColor ?? colors.container,
          borderRadius: BorderRadius.circular(radius),
          border: colors.isDark ? null : Border.all(color: colors.borderSubtle),
          boxShadow: _getCardShadow(colors),
        );

      case AppCardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? colors.container,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? (isSelected ? colors.gold : colors.border),
            width: isSelected ? 2 : 1,
          ),
        );

      case AppCardVariant.filled:
        return BoxDecoration(
          color:
              backgroundColor ??
              (isSelected ? colors.goldSubtle : colors.elevated),
          borderRadius: BorderRadius.circular(radius),
          border: isSelected ? Border.all(color: colors.gold, width: 2) : null,
        );

      case AppCardVariant.goldAccent:
        return BoxDecoration(
          color:
              backgroundColor ??
              (colors.isDark
                  ? colors.container
                  : Color.alphaBlend(
                      colors.gold.withValues(alpha: 0.035),
                      colors.container,
                    )),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor ?? colors.borderGold, width: 1),
          boxShadow: _getCardShadow(colors),
        );

      // ignore: deprecated_member_use_from_same_package
      case AppCardVariant.subtle:
        return BoxDecoration(
          color: backgroundColor ?? colors.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? colors.borderSubtle,
            width: 1,
          ),
        );

      case AppCardVariant.glass:
        return BoxDecoration(
          color:
              backgroundColor ??
              colors.container.withValues(alpha: colors.isDark ? 0.85 : 0.9),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? colors.borderSubtle,
            width: 1,
          ),
          boxShadow: _getGlassShadow(colors),
        );
    }
  }

  /// Returns theme-appropriate shadow for card variant
  List<BoxShadow> _getCardShadow(ThemeColors colors) {
    if (colors.isDark) {
      // Stronger shadows for dark mode
      return AppShadows.card;
    } else {
      return AppShadows.lightCard;
    }
  }

  /// Returns theme-appropriate shadow for glass variant
  List<BoxShadow> _getGlassShadow(ThemeColors colors) {
    if (colors.isDark) {
      return AppShadows.md;
    } else {
      return [
        BoxShadow(
          color: const Color(0x245A431B),
          blurRadius: 16,
          offset: const Offset(0, 8),
          spreadRadius: -10,
        ),
      ];
    }
  }

  /// Returns theme-appropriate splash color
  Color _getSplashColor(ThemeColors colors) {
    if (isSelected) {
      return colors.gold.withValues(alpha: 0.1);
    }
    return (colors.isDark ? Colors.white : Colors.black).withValues(
      alpha: 0.05,
    );
  }

  /// Returns theme-appropriate highlight color
  Color _getHighlightColor(ThemeColors colors) {
    if (isSelected) {
      return colors.gold.withValues(alpha: 0.05);
    }
    return (colors.isDark ? Colors.white : Colors.black).withValues(
      alpha: 0.05,
    );
  }
}
