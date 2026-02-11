import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Error state component with retry functionality
/// Themed for both light and dark modes
///
/// Usage:
/// ```dart
/// ErrorState(
///   title: 'Failed to load transactions',
///   message: 'Please check your connection and try again',
///   onRetry: () => ref.read(transactionsProvider.notifier).reload(),
/// )
///
/// // With contact support
/// ErrorState.withSupport(
///   title: 'Something went wrong',
///   message: error.toString(),
///   onRetry: _handleRetry,
///   onContactSupport: _handleContactSupport,
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    super.key,
    this.message,
    this.onRetry,
    this.onContactSupport,
    this.icon = Icons.error_outline,
    this.padding,
    this.showIcon = true,
  });

  /// Error state with contact support option
  const ErrorState.withSupport({
    required this.title,
    required this.onContactSupport,
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.padding,
  }) : showIcon = true;

  /// Network error variant
  const ErrorState.network({
    required this.onRetry,
    super.key,
    this.title = 'Connection Error',
    this.message = 'Please check your internet connection and try again',
  })  : icon = Icons.wifi_off_outlined,
        onContactSupport = null,
        padding = null,
        showIcon = true;

  /// Server error variant
  const ErrorState.server({
    required this.onRetry,
    super.key,
    this.title = 'Server Error',
    this.message = 'Our servers are experiencing issues. Please try again later',
    this.onContactSupport,
  })  : icon = Icons.cloud_off_outlined,
        padding = null,
        showIcon = true;

  /// Main error title
  final String title;

  /// Error message/description
  final String? message;

  /// Retry callback
  final VoidCallback? onRetry;

  /// Contact support callback
  final VoidCallback? onContactSupport;

  /// Icon to display
  final IconData icon;

  /// Whether to show the icon
  final bool showIcon;

  /// Padding around the content
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colors = _ThemeColors.of(context);
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.xxl);

    return Semantics(
      label: 'Error: $title. ${message ?? ''}',
      container: true,
      child: Center(
        child: Padding(
          padding: effectivePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              if (showIcon) ...[
                _buildErrorIcon(colors),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Title
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              // Message
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Action buttons
              const SizedBox(height: AppSpacing.xxl),
              _buildActions(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon(_ThemeColors colors) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colors.errorBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.errorBase.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 40,
        color: colors.errorBase,
      ),
    );
  }

  Widget _buildActions(_ThemeColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Retry button (primary)
        if (onRetry != null) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: colors.textInverse,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Try Again',
                    style: AppTypography.button,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Contact support button (secondary)
        if (onContactSupport != null) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onContactSupport,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.support_agent_outlined, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Contact Support',
                    style: AppTypography.button.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Inline error display for form fields or smaller components
class InlineError extends StatelessWidget {
  const InlineError({
    required this.message,
    super.key,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = _ThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.errorBase.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colors.errorBase,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: colors.errorText,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                size: 20,
                color: colors.errorBase,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Theme-aware colors helper
class _ThemeColors {
  final bool isDark;

  const _ThemeColors._({required this.isDark});

  factory _ThemeColors.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _ThemeColors._(isDark: brightness == Brightness.dark);
  }

  Color get textPrimary =>
      isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get textInverse =>
      isDark ? AppColors.textInverse : AppColorsLight.textInverse;
  Color get errorBase =>
      isDark ? AppColors.errorBase : AppColorsLight.errorBase;
  Color get errorBg => isDark ? AppColors.errorLight : AppColorsLight.errorLight;
  Color get errorText =>
      isDark ? AppColors.errorText : AppColorsLight.errorText;
  Color get border => isDark ? AppColors.borderDefault : AppColorsLight.borderDefault;
  Color get gold => isDark ? AppColors.gold500 : AppColorsLight.gold500;
}
