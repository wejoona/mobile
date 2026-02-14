import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/core/error_handling/error_reporter.dart';
import 'package:usdc_wallet/core/error_handling/error_types.dart';
import 'package:usdc_wallet/core/error_handling/error_fallback_ui.dart';

/// Error Boundary Widget - Catches errors in child widget tree
///
/// Wraps a widget tree to catch and handle errors gracefully without
/// crashing the entire app. Reports errors to Crashlytics.
///
/// Usage:
/// ```dart
/// ErrorBoundary(
///   child: MyFeatureWidget(),
/// )
/// ```
///
/// With custom fallback:
/// ```dart
/// ErrorBoundary(
///   fallbackBuilder: (context, error, stackTrace, reset) => CustomErrorUI(),
///   child: MyFeatureWidget(),
/// )
/// ```
class ErrorBoundary extends ConsumerStatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackBuilder,
    this.onError,
    this.errorContext,
    this.shouldCapture,
  });

  /// The widget tree to protect
  final Widget child;

  /// Custom error UI builder
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
    VoidCallback reset,
  )? fallbackBuilder;

  /// Called when an error is caught
  final void Function(Object error, StackTrace? stackTrace)? onError;

  /// Context for error reporting (e.g., "WalletScreen", "TransferFlow")
  final String? errorContext;

  /// Predicate to determine if error should be captured
  /// Return false to let error propagate up
  final bool Function(Object error)? shouldCapture;

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Reset error state when widget is rebuilt
    _error = null;
    _stackTrace = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackBuilder?.call(
            context,
            _error!,
            _stackTrace,
            _resetError,
          ) ??
          ErrorFallbackUI(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: _resetError,
            context: widget.errorContext,
          );
    }

    return ErrorHandler(
      onError: _handleError,
      child: widget.child,
    );
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    // Check if we should capture this error
    if (widget.shouldCapture != null && !widget.shouldCapture!(error)) {
      // Let it propagate
      Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current);
      // ignore: dead_code
      return;
    }

    // Call custom error handler
    widget.onError?.call(error, stackTrace);

    // Report to Crashlytics
    final errorReporter = ref.read(errorReporterProvider);
    errorReporter.reportError(
      error,
      stackTrace,
      context: widget.errorContext,
      severity: ErrorSeverity.error,
    );

    // Schedule UI update to avoid setState during build
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
          });
        }
      });
    }
  }

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }
}

/// Internal widget that catches errors using ErrorWidget.builder override
class ErrorHandler extends StatelessWidget {
  const ErrorHandler({
    super.key,
    required this.child,
    required this.onError,
  });

  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  @override
  Widget build(BuildContext context) {
    return _ErrorBoundaryWrapper(
      onError: onError,
      child: child,
    );
  }
}

/// Wrapper that uses ErrorWidget to catch rendering errors
class _ErrorBoundaryWrapper extends StatefulWidget {
  const _ErrorBoundaryWrapper({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  @override
  State<_ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<_ErrorBoundaryWrapper> {
  ErrorWidgetBuilder? _previousErrorBuilder;

  @override
  void initState() {
    super.initState();
    _previousErrorBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Call error handler
      widget.onError(details.exception, details.stack);
      // Return empty container to prevent default error widget
      return const SizedBox.shrink();
    };
  }

  @override
  void dispose() {
    // Restore previous error builder
    if (_previousErrorBuilder != null) {
      ErrorWidget.builder = _previousErrorBuilder!;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Root Error Boundary - Should wrap the entire app
///
/// Catches all unhandled errors and shows a full-screen error UI
///
/// Usage in main.dart:
/// ```dart
/// runApp(
///   ProviderScope(
///     child: RootErrorBoundary(
///       child: MyApp(),
///     ),
///   ),
/// );
/// ```
class RootErrorBoundary extends ConsumerStatefulWidget {
  const RootErrorBoundary({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<RootErrorBoundary> createState() => _RootErrorBoundaryState();
}

class _RootErrorBoundaryState extends ConsumerState<RootErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();

    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Catch async errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _buildRootErrorUI(details.exception, details.stack);
    };
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    // Report to Crashlytics
    final errorReporter = ref.read(errorReporterProvider);
    errorReporter.reportFlutterError(details);

    // Update UI for critical errors
    if (mounted) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildRootErrorUI(_error!, _stackTrace);
    }

    return widget.child;
  }

  Widget _buildRootErrorUI(Object error, StackTrace? stackTrace) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: AppColors.obsidian,
        body: SafeArea(
          child: ErrorFallbackUI(
            error: error,
            stackTrace: stackTrace,
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
            isRootError: true,
          ),
        ),
      ),
    );
  }
}

/// Async Error Boundary - For FutureBuilder/StreamBuilder errors
///
/// Usage:
/// ```dart
/// AsyncErrorBoundary(
///   future: fetchData(),
///   builder: (context, data) => MyWidget(data: data),
/// )
/// ```
class AsyncErrorBoundary<T> extends ConsumerWidget {
  const AsyncErrorBoundary({
    super.key,
    required this.future,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.errorContext,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
      errorBuilder;
  final String? errorContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call(context) ??
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.gold500),
                ),
              );
        }

        if (snapshot.hasError) {
          final error = snapshot.error!;
          final stackTrace = snapshot.stackTrace;

          // Report error
          final errorReporter = ref.read(errorReporterProvider);
          errorReporter.reportError(
            error,
            stackTrace,
            context: errorContext,
            severity: ErrorSeverity.warning,
          );

          if (errorBuilder != null) {
            return errorBuilder!(context, error, () {
              // Rebuild widget to retry
              (context as Element).markNeedsBuild();
            });
          }

          return ErrorFallbackUI(
            error: error,
            stackTrace: stackTrace,
            onRetry: () {
              (context as Element).markNeedsBuild();
            },
            context: errorContext,
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
