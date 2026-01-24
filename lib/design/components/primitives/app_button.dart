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
/// Pure presentational component - no business logic
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
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: isFullWidth ? double.infinity : null,
      decoration: _buildDecoration(isDisabled),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          splashColor: _getSplashColor(),
          child: Padding(
            padding: _getPadding(),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDisabled) {
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
          color: isDisabled ? AppColors.elevated : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isDisabled ? null : AppShadows.goldGlow,
        );

      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDisabled ? AppColors.borderSubtle : AppColors.borderDefault,
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
          color: isDisabled ? AppColors.elevated : AppColors.successBase,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );

      case AppButtonVariant.danger:
        return BoxDecoration(
          color: isDisabled ? AppColors.elevated : AppColors.errorBase,
          borderRadius: BorderRadius.circular(AppRadius.md),
        );
    }
  }

  Color _getSplashColor() {
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

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) return AppColors.textDisabled;

    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.textInverse;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.ghost:
        return AppColors.gold500;
      case AppButtonVariant.success:
        return AppColors.textPrimary;
      case AppButtonVariant.danger:
        return AppColors.textPrimary;
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

  Widget _buildContent() {
    final isDisabled = onPressed == null || isLoading;
    final textColor = _getTextColor(isDisabled);

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

    final textWidget = Text(
      label,
      style: AppTypography.button.copyWith(
        color: textColor,
        fontSize: _getFontSize(),
      ),
    );

    if (icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(
      icon,
      size: _getFontSize() + 4,
      color: textColor,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [iconWidget, const SizedBox(width: AppSpacing.sm), textWidget]
          : [textWidget, const SizedBox(width: AppSpacing.sm), iconWidget],
    );
  }
}

enum IconPosition { left, right }
