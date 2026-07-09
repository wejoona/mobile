import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// A card with gradient background, used for balance display, promotions.
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  static List<Color> defaultGradient(ThemeColors themeColors) {
    if (themeColors.isDark) {
      return [
        Color.alphaBlend(
          themeColors.gold.withValues(alpha: 0.08),
          themeColors.container,
        ),
        Color.alphaBlend(
          themeColors.gold.withValues(alpha: 0.14),
          themeColors.elevated,
        ),
        Color.alphaBlend(
          themeColors.gold.withValues(alpha: 0.06),
          themeColors.surface,
        ),
      ];
    }

    return [
      themeColors.container,
      Color.alphaBlend(
        themeColors.gold.withValues(alpha: 0.10),
        themeColors.goldSubtle,
      ),
      Color.alphaBlend(
        themeColors.gold.withValues(alpha: 0.05),
        themeColors.elevated,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;
    final gradientColors = colors ?? defaultGradient(themeColors);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: begin,
            end: end,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: themeColors.borderGold.withValues(
              alpha: themeColors.isDark ? 0.28 : 0.36,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: themeColors.gold.withValues(
                alpha: themeColors.isDark ? 0.18 : 0.10,
              ),
              blurRadius: themeColors.isDark ? 12 : 8,
              offset: Offset(0, themeColors.isDark ? 4 : 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}