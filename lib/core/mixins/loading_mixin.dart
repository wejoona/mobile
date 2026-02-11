import 'package:flutter/material.dart';

/// Mixin that provides loading state management for StatefulWidgets.
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Execute an async operation with automatic loading state management.
  Future<R?> withLoading<R>(Future<R> Function() action) async {
    if (_isLoading) return null;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await action();
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return result;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
      return null;
    }
  }

  /// Clear error message.
  void clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }
}
