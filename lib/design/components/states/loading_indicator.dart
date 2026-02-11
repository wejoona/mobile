import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Themed circular progress indicator
/// Automatically adapts to light/dark theme
///
/// Usage:
/// ```dart
/// LoadingIndicator()
/// LoadingIndicator.small()
/// LoadingIndicator(color: AppColors.gold500)
/// ```
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.strokeWidth,
    this.semanticLabel,
  });

  const LoadingIndicator.small({
    super.key,
    this.color,
    this.strokeWidth,
    this.semanticLabel,
  }) : size = LoadingSize.small;

  const LoadingIndicator.large({
    super.key,
    this.color,
    this.strokeWidth,
    this.semanticLabel,
  }) : size = LoadingSize.large;

  final LoadingSize size;
  final Color? color;
  final double? strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = color ?? colors.gold;
    final dimensions = _getDimensions();

    return Semantics(
      label: semanticLabel ?? 'Loading',
      child: SizedBox(
        width: dimensions.size,
        height: dimensions.size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? dimensions.strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        ),
      ),
    );
  }

  _LoadingDimensions _getDimensions() {
    switch (size) {
      case LoadingSize.small:
        return const _LoadingDimensions(size: 16, strokeWidth: 2);
      case LoadingSize.medium:
        return const _LoadingDimensions(size: 24, strokeWidth: 2.5);
      case LoadingSize.large:
        return const _LoadingDimensions(size: 40, strokeWidth: 3);
    }
  }
}

class _LoadingDimensions {
  final double size;
  final double strokeWidth;

  const _LoadingDimensions({
    required this.size,
    required this.strokeWidth,
  });
}

enum LoadingSize {
  small,
  medium,
  large,
}

/// Theme-aware color palette
class ThemeColors {
  final bool isDark;

  const ThemeColors._({required this.isDark});

  factory ThemeColors.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ThemeColors._(isDark: brightness == Brightness.dark);
  }

  Color get gold => isDark ? AppColors.gold500 : AppColorsLight.gold500;
}
