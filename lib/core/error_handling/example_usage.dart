/// Example Usage of Error Handling System
///
/// This file demonstrates all the ways to use the error handling system
/// Copy-paste these patterns into your features

// ignore_for_file: unused_element, dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import '../../design/components/primitives/index.dart';
import 'index.dart';

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 1: Screen with ErrorBoundary
// ═══════════════════════════════════════════════════════════════════════════

class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      errorContext: 'ExampleScreen',
      child: const _ExampleScreenContent(),
    );
  }
}

class _ExampleScreenContent extends StatelessWidget {
  const _ExampleScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: const Center(child: Text('Content')),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 2: Widget with Error Handling Mixin
// ═══════════════════════════════════════════════════════════════════════════

class ExampleWidgetWithMixin extends ConsumerStatefulWidget {
  const ExampleWidgetWithMixin({super.key});

  @override
  ConsumerState<ExampleWidgetWithMixin> createState() =>
      _ExampleWidgetWithMixinState();
}

class _ExampleWidgetWithMixinState extends ConsumerState<ExampleWidgetWithMixin>
    with ErrorHandlerMixin {
  bool _isLoading = false;
  String? _data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_data != null)
          Text(_data!)
        else
          AppButton(
            label: 'Load Data',
            onPressed: _loadData,
          ),
      ],
    );
  }

  // Method 1: Basic async error handling
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await handleAsyncError(
      () async {
        // Simulated API call
        await Future.delayed(const Duration(seconds: 1));
        throw NetworkError('Failed to load data');
      },
      context: 'LoadData',
      showSnackbar: true,
    );

    setState(() => _isLoading = false);
  }

  // Method 2: Async with return value
  Future<void> _loadDataWithResult() async {
    setState(() => _isLoading = true);

    final data = await handleAsyncErrorWithResult<String>(
      () async {
        // Simulated API call
        await Future.delayed(const Duration(seconds: 1));
        return 'Data loaded successfully';
      },
      context: 'LoadDataWithResult',
    );

    setState(() {
      _isLoading = false;
      _data = data;
    });
  }

  // Method 3: Custom error message
  Future<void> _saveData() async {
    await handleAsyncError(
      () async {
        // Simulated save operation
        throw const StorageError('Disk full');
      },
      context: 'SaveData',
      customErrorMessage: 'Unable to save. Please free up storage space.',
    );
  }

  // Method 4: With custom error callback
  Future<void> _deleteData() async {
    await handleAsyncError(
      () async {
        // Simulated delete
        throw Exception('Delete failed');
      },
      context: 'DeleteData',
      onError: () {
        // Custom handling
        debugPrint('Delete failed - showing custom dialog');
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 3: Notifier with Error Handling
// ═══════════════════════════════════════════════════════════════════════════

class ExampleState {
  const ExampleState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  final bool isLoading;
  final String? data;
  final String? error;

  ExampleState copyWith({
    bool? isLoading,
    String? data,
    String? error,
  }) {
    return ExampleState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class ExampleNotifier extends Notifier<ExampleState>
    with NotifierErrorHandler {
  @override
  ExampleState build() => const ExampleState();

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await handleAsyncError(
        () async {
          // Simulated API call
          await Future.delayed(const Duration(seconds: 1));
          final data = 'Loaded data';
          state = state.copyWith(data: data, isLoading: false);
        },
        context: 'ExampleNotifier.loadData',
        severity: ErrorSeverity.error,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userFriendlyMessage,
      );
    }
  }

  Future<void> refreshData() async {
    final data = await handleAsyncErrorWithResult<String>(
      () async {
        // Simulated refresh
        await Future.delayed(const Duration(seconds: 1));
        return 'Refreshed data';
      },
      context: 'ExampleNotifier.refreshData',
      metadata: {'timestamp': DateTime.now().toIso8601String()},
    );

    if (data != null) {
      state = state.copyWith(data: data);
    }
  }
}

final exampleProvider = NotifierProvider<ExampleNotifier, ExampleState>(
  ExampleNotifier.new,
);

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 4: Async Error Boundary
// ═══════════════════════════════════════════════════════════════════════════

class ExampleAsyncWidget extends ConsumerWidget {
  const ExampleAsyncWidget({super.key});

  Future<List<String>> _fetchItems() async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate error
    throw const NetworkError('Failed to fetch items');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncErrorBoundary<List<String>>(
      future: _fetchItems(),
      builder: (context, items) {
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(items[index]));
          },
        );
      },
      loadingBuilder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, retry) {
        return CompactErrorWidget(
          message: error.userFriendlyMessage,
          onRetry: retry,
        );
      },
      errorContext: 'ItemsList',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 5: Custom Error Handling
// ═══════════════════════════════════════════════════════════════════════════

class ExampleCustomErrorHandling extends ConsumerWidget {
  const ExampleCustomErrorHandling({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorBoundary(
      // Custom error UI
      fallbackBuilder: (context, error, stackTrace, reset) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text('Oops! ${error.userFriendlyMessage}'),
              const SizedBox(height: 24),
              AppButton(
                label: 'Try Again',
                onPressed: reset,
              ),
            ],
          ),
        );
      },

      // Custom error callback
      onError: (error, stackTrace) {
        debugPrint('Custom error handler: $error');
      },

      // Filter which errors to capture
      shouldCapture: (error) {
        // Don't capture validation errors
        return error is! ValidationError;
      },

      errorContext: 'CustomHandling',
      child: const _ThrowingWidget(),
    );
  }
}

class _ThrowingWidget extends StatelessWidget {
  const _ThrowingWidget();

  @override
  Widget build(BuildContext context) {
    // This will throw an error
    throw const NetworkError('Simulated error');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 6: Manual Error Reporting
// ═══════════════════════════════════════════════════════════════════════════

class ExampleManualReporting extends ConsumerWidget {
  const ExampleManualReporting({super.key});

  Future<void> _performOperation(WidgetRef ref) async {
    final errorReporter = ref.read(errorReporterProvider);

    try {
      // Breadcrumb - track user flow
      errorReporter.logBreadcrumb(
        'User started payment',
        metadata: {'amount': '100'},
      );

      // Simulated operation
      await Future.delayed(const Duration(seconds: 1));
      throw Exception('Payment processing failed');
    } catch (error, stackTrace) {
      // Report with full context
      await errorReporter.reportError(
        error,
        stackTrace,
        context: 'PaymentProcessing',
        severity: ErrorSeverity.error,
        metadata: {
          'amount': '100',
          'recipient': 'user123',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      rethrow;
    }
  }

  Future<void> _networkOperation(WidgetRef ref) async {
    final errorReporter = ref.read(errorReporterProvider);

    try {
      // Simulated network call
      throw Exception('Network failed');
    } catch (error, stackTrace) {
      // Report as network error
      await errorReporter.reportNetworkError(
        error,
        stackTrace,
        endpoint: '/api/transactions',
        statusCode: 500,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      label: 'Test Error Reporting',
      onPressed: () => _performOperation(ref),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 7: Different Error UI Components
// ═══════════════════════════════════════════════════════════════════════════

class ExampleErrorUIComponents extends StatelessWidget {
  const ExampleErrorUIComponents({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Full Screen Error
        SizedBox(
          height: 400,
          child: ErrorFallbackUI(
            error: const NetworkError('Connection failed'),
            onRetry: () {},
            context: 'Example',
          ),
        ),

        const SizedBox(height: 24),

        // 2. Compact Error
        CompactErrorWidget(
          message: 'Failed to load data',
          onRetry: () {},
        ),

        const SizedBox(height: 24),

        // 3. Empty State Error
        SizedBox(
          height: 300,
          child: EmptyStateErrorWidget(
            title: 'No Data',
            message: 'Failed to load your data',
            onRetry: () {},
          ),
        ),

        const SizedBox(height: 24),

        // 4. Snackbar Error (triggered by button)
        AppButton(
          label: 'Show Snackbar Error',
          onPressed: () {
            context.showErrorSnackbar('This is an error message');
          },
        ),

        const SizedBox(height: 12),

        // 5. Snackbar with Retry
        AppButton(
          label: 'Show Error with Retry',
          onPressed: () {
            SnackbarError.show(
              context,
              'Operation failed',
              onRetry: () {
                debugPrint('Retry tapped');
              },
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE 8: Throwing Different Error Types
// ═══════════════════════════════════════════════════════════════════════════

class ExampleErrorTypes extends StatelessWidget {
  const ExampleErrorTypes({super.key});

  Future<void> _throwNetworkError() async {
    throw const NetworkError(
      'Server unreachable',
      code: 'NETWORK_001',
      statusCode: 503,
    );
  }

  Future<void> _throwAuthError() async {
    throw AuthError.sessionExpired;
  }

  Future<void> _throwValidationError() async {
    throw const ValidationError(
      'Invalid phone number format',
      field: 'phoneNumber',
    );
  }

  Future<void> _throwBusinessError() async {
    throw BusinessError.insufficientBalance;
  }

  Future<void> _throwBiometricError() async {
    throw BiometricError.notEnrolled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Throw Network Error',
          onPressed: () async {
            try {
              await _throwNetworkError();
            } catch (e) {
              context.showError(e);
            }
          },
        ),
        AppButton(
          label: 'Throw Auth Error',
          onPressed: () async {
            try {
              await _throwAuthError();
            } catch (e) {
              context.showError(e);
            }
          },
        ),
        AppButton(
          label: 'Throw Validation Error',
          onPressed: () async {
            try {
              await _throwValidationError();
            } catch (e) {
              context.showError(e);
            }
          },
        ),
      ],
    );
  }
}
