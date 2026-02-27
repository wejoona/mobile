import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Standard error view with retry button.
class ErrorView extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  const ErrorView({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon = Icons.error_outline_rounded,
  });

  /// Network error preset.
  factory ErrorView.network({VoidCallback? onRetry}) => ErrorView(
        title: 'Connection Error',
        message: 'Unable to connect. Please check your internet and try again.',
        onRetry: onRetry,
        icon: Icons.wifi_off_rounded,
      );

  /// Server error preset.
  factory ErrorView.server({VoidCallback? onRetry}) => ErrorView(
        title: 'Server Error',
        message: 'Something went wrong on our end. Please try again later.',
        onRetry: onRetry,
        icon: Icons.cloud_off_rounded,
      );

  /// Not found preset.
  factory ErrorView.notFound({String? message}) => ErrorView(
        title: 'Not Found',
        message: message ?? 'The requested item could not be found.',
        icon: Icons.search_off_rounded,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            if (title != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
