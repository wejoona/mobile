import 'package:flutter/material.dart';

import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Button Variants
enum AppButtonVariant {
  /// Gold background - Primary CTA
  primary,

  /// Outlined with border - Secondary actions
  secondary,

  /// Minimal background - Tertiary actions
  tertiary,

  /// Text only - Ghost actions
  ghost,

  /// Success state (green)
  success,

  /// Error/Danger state (red)
  danger,
}

/// Button Sizes
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Luxury Wallet Button Component
/// Enhanced with proper text alignment, overflow handling, and accessibility
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.semanticLabel,
    this.enableHaptics = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconPosition iconPosition;
  /// Optional semantic label for screen readers (defaults to label)
  final String? semanticLabel;
  /// Enable haptic feedback on tap (default: true)
  final bool enableHaptics;

  /// Handle button tap with haptic feedback
  void _handleTap() {
    if (enableHaptics) {
      // Provide contextual haptic feedback based on variant
      switch (variant) {
        case AppButtonVariant.primary:
          hapticService.mediumTap();
          break;
        case AppButtonVariant.secondary:
        case AppButtonVariant.tertiary:
        case AppButtonVariant.ghost:
          hapticService.lightTap();
          break;
        case AppButtonVariant.success:
          hapticService.mediumTap();
          break;
        case AppButtonVariant.danger:
          hapticService.heavyTap();
          break;
      }
    }
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final colors = context.colors;

    // Build semantic label for screen readers
    final String effectiveLabel = semanticLabel ?? label;
    final String semanticHint = isLoading
        ? 'Loading, please wait'
        : isDisabled
            ? 'Button disabled'
            : 'Double tap to activate';

    return Semantics(
      label: effectiveLabel,
      hint: semanticHint,
      button: true,
      enabled: !isDisabled,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isFullWidth ? double.infinity : null,
        constraints: isFullWidth
            ? const BoxConstraints(minHeight: 48)
            : const BoxConstraints(minWidth: 88, minHeight: 40),
        decoration: _buildDecoration(isDisabled, colors),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : _handleTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            splashColor: _getSplashColor(colors),
            highlightColor: _getHighlightColor(colors),
            hoverColor: _getHoverColor(colors),
            child: Padding(
              padding: _getPadding(),
              child: Center(
                child: _buildContent(colors),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDisabled, ThemeColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
        if (isDisabled) {
          return BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
          );
        }

        // Theme-aware primary button
        if (colors.isDark) {
          // Dark mode: Use gold gradient with glow
          return BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.goldGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.goldGlow,
          );
        } else {
          // Light mode: Solid gold background with subtle shadow
          return BoxDecoration(
            color: colors.gold,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: colors.gold.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          );
        }

      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDisabled ? colors.borderSubtle : colors.border,
            width: 1.5,
          ),
        );

      case AppButtonVariant.tertiary:
        return BoxDecoration(
          color: isDisabled ? Colors.transparent : colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );

      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );

      case AppButtonVariant.success:
        return BoxDecoration(
          color: isDisabled ? colors.elevated : colors.success,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );

      case AppButtonVariant.danger:
        return BoxDecoration(
          color: isDisabled ? colors.elevated : colors.error,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
    }
  }

  Color _getSplashColor(ThemeColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
        // Darker gold for ripple effect
        return colors.isDark
            ? AppColors.gold700.withOpacity(0.3)
            : AppColorsLight.gold700.withOpacity(0.3);

      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
        // Subtle overlay based on theme
        return colors.isDark
            ? AppColors.overlayLight
            : AppColorsLight.overlayLight;

      case AppButtonVariant.ghost:
        // Minimal ripple for ghost buttons
        return colors.isDark
            ? AppColors.overlayLight.withOpacity(0.5)
            : AppColorsLight.overlayLight.withOpacity(0.5);

      case AppButtonVariant.success:
        return colors.isDark
            ? AppColors.successDark.withOpacity(0.3)
            : AppColorsLight.successBase.withOpacity(0.2);

      case AppButtonVariant.danger:
        return colors.isDark
            ? AppColors.errorDark.withOpacity(0.3)
            : AppColorsLight.errorBase.withOpacity(0.2);
    }
  }

  Color _getHighlightColor(ThemeColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colors.isDark
            ? AppColors.gold800.withOpacity(0.2)
            : AppColorsLight.gold600.withOpacity(0.2);

      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
      case AppButtonVariant.ghost:
        return colors.isDark
            ? AppColors.overlayLight.withOpacity(0.3)
            : AppColorsLight.overlayLight.withOpacity(0.3);

      case AppButtonVariant.success:
        return colors.isDark
            ? AppColors.successDark.withOpacity(0.2)
            : AppColorsLight.successBase.withOpacity(0.15);

      case AppButtonVariant.danger:
        return colors.isDark
            ? AppColors.errorDark.withOpacity(0.2)
            : AppColorsLight.errorBase.withOpacity(0.15);
    }
  }

  Color _getHoverColor(ThemeColors colors) {
    switch (variant) {
      case AppButtonVariant.primary:
        return colors.isDark
            ? AppColors.gold700.withOpacity(0.1)
            : AppColorsLight.gold600.withOpacity(0.1);

      case AppButtonVariant.secondary:
      case AppButtonVariant.tertiary:
      case AppButtonVariant.ghost:
        return colors.isDark
            ? AppColors.overlayLight.withOpacity(0.15)
            : AppColorsLight.overlayLight.withOpacity(0.15);

      case AppButtonVariant.success:
        return colors.isDark
            ? AppColors.successDark.withOpacity(0.1)
            : AppColorsLight.successBase.withOpacity(0.08);

      case AppButtonVariant.danger:
        return colors.isDark
            ? AppColors.errorDark.withOpacity(0.1)
            : AppColorsLight.errorBase.withOpacity(0.08);
    }
  }

  Color _getTextColor(bool isDisabled, ThemeColors colors) {
    if (isDisabled) return colors.textDisabled;

    switch (variant) {
      case AppButtonVariant.primary:
        // Inverse text on gold background (dark on light, light on dark)
        return colors.textInverse;

      case AppButtonVariant.secondary:
        // Primary text color for outlined buttons
        return colors.textPrimary;

      case AppButtonVariant.tertiary:
        // Gold accent for tertiary buttons
        return colors.gold;

      case AppButtonVariant.ghost:
        // Gold for ghost text
        return colors.gold;

      case AppButtonVariant.success:
        // High contrast text on success background
        return colors.isDark ? colors.textPrimary : AppColorsLight.textInverse;

      case AppButtonVariant.danger:
        // High contrast text on error background
        return colors.isDark ? colors.textPrimary : AppColorsLight.textInverse;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        );
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 17;
    }
  }

  Widget _buildContent(ThemeColors colors) {
    final isDisabled = onPressed == null || isLoading;
    final textColor = _getTextColor(isDisabled, colors);

    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    // Text widget
    final textChild = Text(
      label,
      style: AppTypography.button.copyWith(
        color: textColor,
        fontSize: _getFontSize(),
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    if (icon == null) {
      // No icon - just return the text (no Flexible needed outside of Row)
      return textChild;
    }

    // Flexible wrapper for use inside Row
    final textWidget = Flexible(child: textChild);

    final iconWidget = Icon(
      icon,
      size: _getFontSize() + 4,
      color: textColor,
    );

    // With icon - ensure proper spacing and alignment
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [
              iconWidget,
              const SizedBox(width: AppSpacing.sm),
              textWidget,
            ]
          : [
              textWidget,
              const SizedBox(width: AppSpacing.sm),
              iconWidget,
            ],
    );
  }
}

enum IconPosition { left, right }
