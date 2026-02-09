import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'error_reporter.dart';
import 'error_types.dart';
import 'error_fallback_ui.dart';

/// Mixin for handling errors in widgets
///
/// Provides common error handling methods for stateful widgets
///
/// Usage:
/// ```dart
/// class MyWidgetState extends ConsumerState<MyWidget> with ErrorHandlerMixin {
///   Future<void> _loadData() async {
///     await handleAsyncError(() async {
///       final data = await fetchData();
///       setState(() => _data = data);
///     });
///   }
/// }
/// ```
mixin ErrorHandlerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Handle async operations with error catching
  ///
  /// Automatically catches errors, reports them, and shows user feedback
  Future<void> handleAsyncError(
    Future<void> Function() operation, {
    String? context,
    bool showSnackbar = true,
    String? customErrorMessage,
    VoidCallback? onError,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      _handleError(
        error,
        stackTrace,
        context: context,
        showSnackbar: showSnackbar,
        customErrorMessage: customErrorMessage,
        onError: onError,
      );
    }
  }

  /// Handle async operations with return value
  ///
  /// Returns null on error
  Future<R?> handleAsyncErrorWithResult<R>(
    Future<R> Function() operation, {
    String? context,
    bool showSnackbar = true,
    String? customErrorMessage,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      _handleError(
        error,
        stackTrace,
        context: context,
        showSnackbar: showSnackbar,
        customErrorMessage: customErrorMessage,
        onError: onError,
      );
      return null;
    }
  }

  /// Handle synchronous operations with error catching
  void handleSyncError(
    void Function() operation, {
    String? context,
    bool showSnackbar = true,
    String? customErrorMessage,
    VoidCallback? onError,
  }) {
    try {
      operation();
    } catch (error, stackTrace) {
      _handleError(
        error,
        stackTrace,
        context: context,
        showSnackbar: showSnackbar,
        customErrorMessage: customErrorMessage,
        onError: onError,
      );
    }
  }

  void _handleError(
    Object error,
    StackTrace stackTrace, {
    String? context,
    bool showSnackbar = true,
    String? customErrorMessage,
    VoidCallback? onError,
  }) {
    // Report to Crashlytics
    final errorReporter = ref.read(errorReporterProvider);
    errorReporter.reportError(
      error,
      stackTrace,
      context: context ?? runtimeType.toString(),
      severity: _getSeverity(error),
    );

    // Call custom error handler
    onError?.call();

    // Show user feedback
    if (showSnackbar && mounted) {
      final message = customErrorMessage ?? error.userFriendlyMessage;
      SnackbarError.show(this.context, message);
    }
  }

  ErrorSeverity _getSeverity(Object error) {
    if (error is ValidationError) return ErrorSeverity.info;
    if (error is NetworkError) return ErrorSeverity.warning;
    if (error is AuthError) return ErrorSeverity.error;
    return ErrorSeverity.error;
  }
}

/// Mixin for handling errors in Riverpod Notifiers
///
/// Usage:
/// ```dart
/// class MyNotifier extends Notifier<MyState> with NotifierErrorHandler {
///   Future<void> loadData() async {
///     await handleAsyncError(() async {
///       final data = await fetchData();
///       state = state.copyWith(data: data);
///     });
///   }
/// }
/// ```
mixin NotifierErrorHandler<T> on Notifier<T> {
  /// Handle async operations in notifier
  Future<void> handleAsyncError(
    Future<void> Function() operation, {
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      // Report error
      final errorReporter = ref.read(errorReporterProvider);
      errorReporter.reportError(
        error,
        stackTrace,
        context: context ?? runtimeType.toString(),
        severity: severity,
        metadata: metadata,
      );

      // Rethrow so caller can handle
      rethrow;
    }
  }

  /// Handle async operations with result
  Future<R?> handleAsyncErrorWithResult<R>(
    Future<R> Function() operation, {
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      // Report error
      final errorReporter = ref.read(errorReporterProvider);
      errorReporter.reportError(
        error,
        stackTrace,
        context: context ?? runtimeType.toString(),
        severity: severity,
        metadata: metadata,
      );

      return null;
    }
  }
}

/// Extension on BuildContext for quick error display
extension ErrorContextExtension on BuildContext {
  /// Show error snackbar
  void showErrorSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    SnackbarError.show(this, message, duration: duration, onRetry: onRetry);
  }

  /// Show error from exception
  void showError(
    Object error, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final message = error.userFriendlyMessage;
    SnackbarError.show(this, message, duration: duration, onRetry: onRetry);
  }
}
