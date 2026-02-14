import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/core/error_handling/error_types.dart';

/// Fallback UI displayed when an error is caught by ErrorBoundary
///
/// Provides a user-friendly error screen with retry functionality
class ErrorFallbackUI extends StatelessWidget {
  const ErrorFallbackUI({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.context,
    this.isRootError = false,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final String? context;
  final bool isRootError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final errorInfo = _getErrorInfo(error, l10n);

    return Container(
      color: AppColors.obsidian,
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Icon(
            errorInfo.icon,
            size: 72,
            color: errorInfo.color,
          ),
          SizedBox(height: AppSpacing.xxl),

          // Error Title
          AppText(
            errorInfo.title,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),

          // Error Message
          AppText(
            errorInfo.message,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          // Context (if provided and debug mode)
          if (this.context != null) ...[
            SizedBox(height: AppSpacing.lg),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: AppText(
                'Context: ${this.context}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],

          SizedBox(height: AppSpacing.xxxl),

          // Action Buttons
          if (onRetry != null) ...[
            AppButton(
              label: l10n.action_retry,
              onPressed: onRetry,
              variant: AppButtonVariant.primary,
              icon: Icons.refresh_rounded,
              isFullWidth: true,
            ),
            SizedBox(height: AppSpacing.md),
          ],

          // Go Home button for root errors
          if (isRootError)
            AppButton(
              label: 'Go to Home',
              onPressed: () {
                // This is a placeholder - actual navigation should be handled
                // by the app's navigation system
              },
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),
        ],
      ),
    );
  }

  _ErrorInfo _getErrorInfo(Object error, AppLocalizations l10n) {
    // Network errors
    if (error is NetworkError || error.isNetworkError) {
      return _ErrorInfo(
        title: l10n.error_network.split('.').first,
        message: error.userFriendlyMessage,
        icon: Icons.wifi_off_rounded,
        color: AppColors.warning,
      );
    }

    // Auth errors
    if (error is AuthError || error.isAuthError) {
      return _ErrorInfo(
        title: 'Authentication Error',
        message: error.userFriendlyMessage,
        icon: Icons.lock_outline_rounded,
        color: AppColors.error,
      );
    }

    // Validation errors
    if (error is ValidationError || error.isValidationError) {
      return _ErrorInfo(
        title: 'Validation Error',
        message: error.userFriendlyMessage,
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
      );
    }

    // Business errors
    if (error is BusinessError || error.isBusinessError) {
      return _ErrorInfo(
        title: 'Unable to Complete',
        message: error.userFriendlyMessage,
        icon: Icons.info_outline_rounded,
        color: AppColors.info,
      );
    }

    // Storage errors
    if (error is StorageError) {
      return _ErrorInfo(
        title: 'Storage Error',
        message: error.message,
        icon: Icons.sd_storage_rounded,
        color: AppColors.error,
      );
    }

    // Biometric errors
    if (error is BiometricError) {
      return _ErrorInfo(
        title: 'Biometric Error',
        message: error.message,
        icon: Icons.fingerprint_rounded,
        color: AppColors.warning,
      );
    }

    // Media errors
    if (error is MediaError) {
      return _ErrorInfo(
        title: 'Camera Error',
        message: error.message,
        icon: Icons.camera_alt_outlined,
        color: AppColors.warning,
      );
    }

    // QR Code errors
    if (error is QRCodeError) {
      return _ErrorInfo(
        title: 'QR Code Error',
        message: error.message,
        icon: Icons.qr_code_rounded,
        color: AppColors.warning,
      );
    }

    // Generic error
    return _ErrorInfo(
      title: l10n.common_error,
      message: l10n.error_generic,
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
    );
  }
}

/// Error information for UI display
class _ErrorInfo {
  const _ErrorInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
}

/// Compact Error Widget - For inline error display
///
/// Used in lists, cards, or small sections
class CompactErrorWidget extends StatelessWidget {
  const CompactErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.errorBase.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 20,
                color: AppColors.errorText,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.action_retry,
              onPressed: onRetry,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty State Error Widget - For failed data loads
///
/// Used when a list/grid fails to load
class EmptyStateErrorWidget extends StatelessWidget {
  const EmptyStateErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            AppText(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.action_retry,
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Snackbar Error - For transient errors
///
/// Usage:
/// ```dart
/// SnackbarError.show(context, 'Error message');
/// ```
class SnackbarError {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorBase,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        action: onRetry != null
            ? SnackBarAction(
                label: l10n.action_retry,
                textColor: AppColors.gold500,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
