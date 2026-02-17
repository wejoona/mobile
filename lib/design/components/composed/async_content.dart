import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Generic async content handler for Riverpod AsyncValue.
///
/// Eliminates repeated `.when(loading: ..., error: ..., data: ...)` boilerplate.
///
/// Usage:
/// ```dart
/// AsyncContent<List<Transaction>>(
///   value: ref.watch(transactionsProvider),
///   onData: (transactions) => TransactionList(transactions),
///   onRetry: () => ref.refresh(transactionsProvider),
/// )
/// ```
class AsyncContent<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) onData;
  final VoidCallback? onRetry;
  final Widget? loading;
  final String? emptyMessage;
  final bool Function(T data)? isEmpty;

  const AsyncContent({
    super.key,
    required this.value,
    required this.onData,
    this.onRetry,
    this.loading,
    this.emptyMessage,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return value.when(
      loading: () => loading ?? _defaultLoading(colors),
      error: (error, _) => _buildError(context, error.toString(), colors),
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return _buildEmpty(colors);
        }
        return onData(data);
      },
    );
  }

  Widget _buildError(BuildContext context, String message, ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.action_retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _defaultLoading(ThemeColors colors) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: ShimmerLoading(height: 200),
      ),
    );
  }

  Widget _buildEmpty(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No data available',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
