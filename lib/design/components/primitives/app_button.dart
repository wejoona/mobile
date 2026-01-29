import 'package:flutter/material.dart';
import '../../tokens/index.dart';

/// Button Variants
enum AppButtonVariant {
  /// Gold background, dark text - Primary CTA
  primary,

  /// Transparent with border - Secondary actions
  secondary,

  /// Text only - Tertiary actions
  ghost,

  /// Success state
  success,

  /// Error/Danger state
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
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.semanticLabel,
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
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.md),
            splashColor: _getSplashColor(colors),
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
        return BoxDecoration(
          gradient: isDisabled
              ? null
              : const LinearGradient(
                  colors: AppColors.goldGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isDisabled ? colors.elevated : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isDisabled ? null : AppShadows.goldGlow,
        );

      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDisabled ? colors.borderSubtle : colors.border,
            width: 1,
          ),
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
        return AppColors.gold700.withOpacity(0.3);
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return AppColors.overlayLight;
      case AppButtonVariant.success:
        return AppColors.successDark.withOpacity(0.3);
      case AppButtonVariant.danger:
        return AppColors.errorDark.withOpacity(0.3);
    }
  }

  Color _getTextColor(bool isDisabled, ThemeColors colors) {
    if (isDisabled) return colors.textDisabled;

    switch (variant) {
      case AppButtonVariant.primary:
        return colors.textInverse;
      case AppButtonVariant.secondary:
        return colors.textPrimary;
      case AppButtonVariant.ghost:
        return colors.gold;
      case AppButtonVariant.success:
        return colors.textPrimary;
      case AppButtonVariant.danger:
        return colors.textPrimary;
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
