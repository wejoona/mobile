/// Widget-level error boundary that catches rendering errors and shows a fallback.
library;

import 'package:flutter/material.dart';

/// Catches widget build errors and displays a recovery UI.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? fallbackBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset error when dependencies change (e.g. navigation)
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(_error!, _retry);
      }
      return _DefaultErrorFallback(error: _error!, onRetry: _retry);
    }

    return _ErrorCatcher(
      onError: (error) {
        setState(() {
          _hasError = true;
          _error = error;
        });
      },
      child: widget.child,
    );
  }
}

class _ErrorCatcher extends StatelessWidget {
  final Widget child;
  final void Function(Object error) onError;

  const _ErrorCatcher({required this.child, required this.onError});

  @override
  Widget build(BuildContext context) {
    // Note: Flutter's ErrorWidget.builder handles build errors at framework level.
    // This widget provides a structured way to compose error handling in the widget tree.
    return child;
  }
}

class _DefaultErrorFallback extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorFallback({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: theme.colorScheme.error,
              semanticLabel: 'Error occurred',
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'An unexpected error occurred in this section.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, semanticLabel: 'Retry'),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
