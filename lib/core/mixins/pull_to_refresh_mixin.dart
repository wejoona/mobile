/// Mixin to standardize pull-to-refresh behavior across ConsumerWidgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a standard refresh pattern for views using Riverpod providers.
mixin PullToRefreshMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  /// Override to provide the list of providers to invalidate on refresh.
  List<ProviderOrFamily> get refreshProviders;

  /// Called after all providers are invalidated.
  Future<void> onPostRefresh() async {}

  /// Use as onRefresh callback for RefreshIndicator.
  Future<void> handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      for (final provider in refreshProviders) {
        ref.invalidate(provider);
      }
      await onPostRefresh();
      // Brief delay for visual feedback
      await Future<void>.delayed(const Duration(milliseconds: 300));
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }
}
