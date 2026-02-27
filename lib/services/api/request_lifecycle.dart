import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// A mixin for widgets that need consistent request lifecycle handling.
///
/// Provides:
/// - Automatic loading indicator display
/// - Consistent error handling with retry
/// - AsyncValue pattern matching helpers
///
/// Usage:
/// ```dart
/// class MyWidget extends ConsumerWidget {
///   Widget build(BuildContext context, WidgetRef ref) {
///     final data = ref.watch(myProvider);
///     return data.buildWith(
///       context,
///       data: (value) => MyContent(value),
///       onRetry: () => ref.invalidate(myProvider),
///     );
///   }
/// }
/// ```

extension AsyncValueUI<T> on AsyncValue<T> {
  /// Build a widget with consistent loading/error/data states.
  Widget buildWith(
    BuildContext context, {
    required Widget Function(T data) data,
    VoidCallback? onRetry,
    Widget? loading,
    Widget Function(Object error, StackTrace? stack)? error,
  }) {
    return when(
      loading: () =>
          loading ??
          const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, stack) {
        if (error != null) return error(err, stack);
        return _DefaultErrorWidget(
          error: err,
          onRetry: onRetry,
        );
      },
      data: data,
    );
  }

  /// Show a snackbar on error, return data widget or loading.
  Widget buildWithSnackbar(
    BuildContext context, {
    required Widget Function(T data) data,
    Widget? loading,
  }) {
    if (hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
    return when(
      loading: () =>
          loading ??
          const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, __) =>
          hasValue ? data(value as T) : const SizedBox.shrink(),
      data: data,
    );
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: context.colors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Retry',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper to execute an async action with automatic error handling.
///
/// Returns true if successful, false on error.
Future<bool> executeWithErrorHandling(
  BuildContext context, {
  required Future<void> Function() action,
  String? successMessage,
  String? errorMessage,
}) async {
  try {
    await action();
    if (successMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return true;
  } catch (e) {
    if (kDebugMode) debugPrint('[RequestLifecycle] Error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'An error occurred: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.errorBase,
        ),
      );
    }
    return false;
  }
}
