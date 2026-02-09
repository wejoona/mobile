import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import '../tokens/index.dart';
import 'primitives/index.dart';

/// Error State Widget
///
/// Displays error states with icon, message, and optional retry button.
/// Use in screens when data loading fails.
///
/// Usage:
/// ```dart
/// if (state.hasError) {
///   return ErrorStateWidget(
///     errorKey: state.errorKey,
///     onRetry: () => ref.refresh(dataProvider),
///   );
/// }
/// ```
class ErrorStateWidget extends StatelessWidget {
  /// Error message key for localization
  final String? errorKey;

  /// Optional custom error message (overrides errorKey)
  final String? message;

  /// Optional title (defaults to "Error")
  final String? title;

  /// Icon to display (defaults to error_outline)
  final IconData? icon;

  /// Retry callback (if provided, shows retry button)
  final VoidCallback? onRetry;

  /// Whether to show retry button (auto-determined if null)
  final bool? showRetry;

  /// Custom retry button label
  final String? retryLabel;

  /// Whether to show full screen error or compact version
  final bool fullScreen;

  const ErrorStateWidget({
    super.key,
    this.errorKey,
    this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.showRetry,
    this.retryLabel,
    this.fullScreen = true,
  }) : assert(errorKey != null || message != null,
            'Either errorKey or message must be provided');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final errorMessage = message ?? (errorKey != null ? _getLocalizedMessage(l10n, errorKey!) : '');
    final errorTitle = title ?? l10n.common_error;
    final errorIcon = icon ?? Icons.error_outline;

    if (fullScreen) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: _buildContent(context, l10n, errorTitle, errorMessage, errorIcon),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: _buildContent(context, l10n, errorTitle, errorMessage, errorIcon),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    String title,
    String message,
    IconData icon,
  ) {
    final shouldShowRetry = showRetry ?? (onRetry != null);

    return Column(
      mainAxisSize: fullScreen ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Error Icon
        Icon(
          icon,
          size: 64,
          color: AppColors.error,
        ),

        SizedBox(height: AppSpacing.lg),

        // Title
        AppText(
          title,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: AppSpacing.sm),

        // Message
        AppText(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.silver,
          ),
          textAlign: TextAlign.center,
        ),

        // Retry Button
        if (shouldShowRetry && onRetry != null) ...[
          SizedBox(height: AppSpacing.xl),
          AppButton(
            label: retryLabel ?? l10n.common_retry,
            onPressed: onRetry,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
          ),
        ],
      ],
    );
  }

  String _getLocalizedMessage(AppLocalizations l10n, String key) {
    // Map error keys to localized messages
    // This uses reflection-like approach via the generated l10n class
    try {
      // Use a switch to map common error keys
      switch (key) {
        case 'error_generic':
          return l10n.error_generic;
        case 'error_network':
          return l10n.error_network;
        case 'error_timeout':
          return l10n.error_timeout;
        case 'error_noInternet':
          return l10n.error_noInternet;
        case 'error_failedToLoadBalance':
          return l10n.error_failedToLoadBalance;
        case 'error_failedToLoadTransactions':
          return l10n.error_failedToLoadTransactions;
        case 'error_sessionExpired':
          return l10n.error_sessionExpired;
        case 'error_kycRequired':
          return l10n.error_kycRequired;
        case 'error_insufficientBalance':
          return l10n.error_insufficientBalance;
        case 'error_serverError':
          return l10n.error_serverError;
        case 'error_serviceUnavailable':
          return l10n.error_serviceUnavailable;
        default:
          return l10n.error_generic;
      }
    } catch (e) {
      return l10n.error_generic;
    }
  }
}

/// Empty State Widget
///
/// Similar to ErrorStateWidget but for empty data states.
/// Use when there's no data but no error.
///
/// Usage:
/// ```dart
/// if (transactions.isEmpty) {
///   return EmptyStateWidget(
///     icon: Icons.history,
///     title: l10n.transactions_emptyTitle,
///     message: l10n.transactions_emptyMessage,
///   );
/// }
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool fullScreen;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: fullScreen ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Icon(
          icon,
          size: 64,
          color: AppColors.silver,
        ),

        SizedBox(height: AppSpacing.lg),

        // Title
        AppText(
          title,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: AppSpacing.sm),

        // Message
        AppText(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.silver,
          ),
          textAlign: TextAlign.center,
        ),

        // Action Button
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: AppSpacing.xl),
          AppButton(
            label: actionLabel!,
            onPressed: onAction,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: content,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: content,
    );
  }
}

/// Offline Banner Widget
///
/// Shows a banner when the app is offline.
/// Typically used at the top of screens.
///
/// Usage:
/// ```dart
/// if (isOffline) {
///   OfflineBanner(
///     onRetry: () => ref.refresh(dataProvider),
///   );
/// }
/// ```
class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.warning.withOpacity(0.2),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 20,
            color: AppColors.warning,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              l10n.error_offline_message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              child: AppText(
                l10n.error_offline_retry,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading State Widget
///
/// Displays loading state with optional message.
///
/// Usage:
/// ```dart
/// if (state.isLoading) {
///   return LoadingStateWidget();
/// }
/// ```
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
        ),
        if (message != null) ...[
          SizedBox(height: AppSpacing.lg),
          AppText(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.silver,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Center(child: content);
    }

    return content;
  }
}
