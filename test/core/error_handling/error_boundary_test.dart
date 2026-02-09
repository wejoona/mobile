import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/error_handling/index.dart';

void main() {
  group('ErrorBoundary', () {
    testWidgets('catches widget errors and shows fallback UI',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ErrorBoundary(
              errorContext: 'Test',
              child: _ThrowingWidget(),
            ),
          ),
        ),
      );

      // Wait for error to be caught
      await tester.pumpAndSettle();

      // Should show error fallback UI
      expect(find.byType(ErrorFallbackUI), findsOneWidget);
    });

    testWidgets('shows custom fallback UI when provided', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ErrorBoundary(
              fallbackBuilder: (context, error, stackTrace, reset) {
                return const Text('Custom Error UI');
              },
              child: const _ThrowingWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Error UI'), findsOneWidget);
      expect(find.byType(ErrorFallbackUI), findsNothing);
    });

    testWidgets('resets error when retry is tapped', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ErrorBoundary(
              errorContext: 'Test',
              child: _ConditionalThrowingWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error UI
      expect(find.byType(ErrorFallbackUI), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Error should be cleared, showing child widget
      expect(find.byType(ErrorFallbackUI), findsNothing);
    });

    testWidgets('calls onError callback when error occurs', (tester) async {
      var errorCallbackCalled = false;
      Object? capturedError;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ErrorBoundary(
              onError: (error, stackTrace) {
                errorCallbackCalled = true;
                capturedError = error;
              },
              child: const _ThrowingWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(errorCallbackCalled, isTrue);
      expect(capturedError, isA<TestException>());
    });

    testWidgets('respects shouldCapture predicate', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ErrorBoundary(
              shouldCapture: (error) => error is! ValidationError,
              child: const _ValidationErrorWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Validation error should not be captured
      // App will show red error screen instead
      expect(find.byType(ErrorFallbackUI), findsNothing);
    });
  });

  group('AsyncErrorBoundary', () {
    testWidgets('shows loading state while future is pending', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AsyncErrorBoundary<String>(
              future: Future.delayed(
                const Duration(seconds: 1),
                () => 'Data',
              ),
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows data when future completes successfully',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AsyncErrorBoundary<String>(
              future: Future.value('Success'),
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('shows error UI when future fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AsyncErrorBoundary<String>(
              future: Future.error(const NetworkError('Failed')),
              builder: (context, data) => Text(data),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ErrorFallbackUI), findsOneWidget);
    });

    testWidgets('uses custom error builder when provided', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AsyncErrorBoundary<String>(
              future: Future.error(Exception('Error')),
              builder: (context, data) => Text(data),
              errorBuilder: (context, error, retry) {
                return const Text('Custom Error');
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Error'), findsOneWidget);
    });
  });

  group('Error Types', () {
    test('NetworkError provides user-friendly message', () {
      const error = NetworkError('Connection timeout');
      expect(error.userFriendlyMessage, contains('Connection timeout'));
    });

    test('AuthError.sessionExpired has correct message', () {
      const error = AuthError.sessionExpired;
      expect(error.message, contains('session has expired'));
    });

    test('ValidationError includes field name', () {
      const error = ValidationError('Invalid format', field: 'email');
      expect(error.field, equals('email'));
    });

    test('BusinessError.insufficientBalance has correct message', () {
      const error = BusinessError.insufficientBalance;
      expect(error.message, contains('Insufficient balance'));
    });

    test('isNetworkError extension works correctly', () {
      const networkError = NetworkError('Error');
      const authError = AuthError('Error');

      expect(networkError.isNetworkError, isTrue);
      expect(authError.isNetworkError, isFalse);
    });

    test('userFriendlyMessage extension handles different error types', () {
      const appError = NetworkError('Network issue');
      final genericError = Exception('Generic error');

      expect(
        appError.userFriendlyMessage,
        equals('Network issue'),
      );
      expect(
        genericError.userFriendlyMessage,
        contains('unexpected error'),
      );
    });
  });

  group('Error UI Components', () {
    testWidgets('CompactErrorWidget displays message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactErrorWidget(
              message: 'Test error message',
            ),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('CompactErrorWidget shows retry button when provided',
        (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactErrorWidget(
              message: 'Error',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });

    testWidgets('EmptyStateErrorWidget displays title and message',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateErrorWidget(
              title: 'No Data',
              message: 'Failed to load',
            ),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Failed to load'), findsOneWidget);
    });
  });
}

// Test Widgets

class _ThrowingWidget extends StatelessWidget {
  const _ThrowingWidget();

  @override
  Widget build(BuildContext context) {
    throw TestException('Test error');
  }
}

class _ConditionalThrowingWidget extends StatefulWidget {
  const _ConditionalThrowingWidget();

  @override
  State<_ConditionalThrowingWidget> createState() =>
      _ConditionalThrowingWidgetState();
}

class _ConditionalThrowingWidgetState
    extends State<_ConditionalThrowingWidget> {
  bool _shouldThrow = true;

  @override
  Widget build(BuildContext context) {
    if (_shouldThrow) {
      // This simulates error being fixed on retry
      Future.microtask(() {
        setState(() => _shouldThrow = false);
      });
      throw TestException('Conditional error');
    }
    return const Text('Success');
  }
}

class _ValidationErrorWidget extends StatelessWidget {
  const _ValidationErrorWidget();

  @override
  Widget build(BuildContext context) {
    throw const ValidationError('Invalid input');
  }
}

class TestException implements Exception {
  const TestException(this.message);
  final String message;

  @override
  String toString() => message;
}
