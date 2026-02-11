/// Generic async screen wrapper with loading, error, and data states.
/// Integrates with Riverpod AsyncValue for consistent UX across all feature views.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A wrapper that handles loading, error, and data states for async screens.
/// Provides pull-to-refresh support and error retry.
class AsyncScreen<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Future<void> Function()? onRefresh;
  final String? loadingMessage;
  final String? emptyMessage;
  final String? emptySubtitle;
  final bool Function(T data)? isEmpty;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final VoidCallback? onRetry;

  const AsyncScreen({
    super.key,
    required this.value,
    required this.builder,
    this.onRefresh,
    this.loadingMessage,
    this.emptyMessage,
    this.emptySubtitle,
    this.isEmpty,
    this.emptyWidget,
    this.loadingWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loadingWidget ?? _buildLoading(context),
      error: (error, stack) => _buildError(context, error),
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return _wrapRefreshable(
            emptyWidget ?? _buildEmpty(context),
          );
        }
        return _wrapRefreshable(builder(data));
      },
    );
  }

  Widget _wrapRefreshable(Widget child) {
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: child is ScrollView
            ? child
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: child,
              ),
      );
    }
    return child;
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (loadingMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
              semanticLabel: 'Error',
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _friendlyError(error),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry ?? (onRefresh != null ? () => onRefresh!() : null),
              icon: const Icon(Icons.refresh, semanticLabel: 'Retry'),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
              semanticLabel: 'Empty',
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'Nothing here yet',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (emptySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                emptySubtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('SocketException') || message.contains('NetworkError')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (message.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    if (message.contains('401') || message.contains('Unauthorized')) {
      return 'Your session has expired. Please log in again.';
    }
    if (message.contains('500') || message.contains('Internal')) {
      return 'Server error. Please try again later.';
    }
    return 'Please try again later.';
  }
}
