import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/core/error_handling/index.dart';

/// Helper to build a MaterialApp with localization delegates and fake reporter
Widget buildTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      errorReporterProvider.overrideWithValue(_FakeErrorReporter()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('ErrorBoundary', () {
    testWidgets('catches widget errors and shows fallback UI',
        (tester) async {
      // Override FlutterError.onError to suppress expected errors in test
      final oldOnError = FlutterError.onError;
      final errors = <FlutterErrorDetails>[];
      FlutterError.onError = (details) => errors.add(details);

      await tester.pumpWidget(
        buildTestApp(
          const ErrorBoundary(
            errorContext: 'Test',
            child: _ThrowingWidget(),
          ),
        ),
      );

      // Pump to let post-frame callback fire
      await tester.pump();
      await tester.pump();

      FlutterError.onError = oldOnError;
      // Drain pending exceptions for Flutter 3.38 compatibility
      dynamic ex; do { ex = tester.takeException(); } while (ex != null);

      expect(find.byType(ErrorFallbackUI), findsOneWidget);
    });

    testWidgets('shows custom fallback UI when provided', (tester) async {
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        buildTestApp(
          ErrorBoundary(
            fallbackBuilder: (context, error, stackTrace, reset) {
              return const Text('Custom Error UI');
            },
            child: const _ThrowingWidget(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      FlutterError.onError = oldOnError;
      // Drain pending exceptions for Flutter 3.38 compatibility
      dynamic ex; do { ex = tester.takeException(); } while (ex != null);

      expect(find.text('Custom Error UI'), findsOneWidget);
      expect(find.byType(ErrorFallbackUI), findsNothing);
    });

    testWidgets('resets error when retry is tapped', (tester) async {
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        buildTestApp(
          const ErrorBoundary(
            errorContext: 'Test',
            child: _ConditionalThrowingWidget(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorFallbackUI), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      FlutterError.onError = oldOnError;
      // Drain pending exceptions for Flutter 3.38 compatibility
      dynamic ex; do { ex = tester.takeException(); } while (ex != null);

      // After retry, conditional widget stops throwing
      expect(find.byType(ErrorFallbackUI), findsNothing);
    });

    testWidgets('calls onError callback when error occurs', (tester) async {
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      var errorCallbackCalled = false;
      Object? capturedError;

      await tester.pumpWidget(
        buildTestApp(
          ErrorBoundary(
            onError: (error, stackTrace) {
              errorCallbackCalled = true;
              capturedError = error;
            },
            child: const _ThrowingWidget(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      FlutterError.onError = oldOnError;
      // Drain pending exceptions for Flutter 3.38 compatibility
      dynamic ex; do { ex = tester.takeException(); } while (ex != null);

      expect(errorCallbackCalled, isTrue);
      expect(capturedError, isA<TestException>());
    });

    testWidgets('respects shouldCapture predicate', (tester) async {
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {};

      await tester.pumpWidget(
        buildTestApp(
          ErrorBoundary(
            shouldCapture: (error) => error is! ValidationError,
            child: const _ValidationErrorWidget(),
          ),
        ),
      );

      await tester.pump();

      FlutterError.onError = oldOnError;
      // Drain pending exceptions for Flutter 3.38 compatibility
      dynamic ex; do { ex = tester.takeException(); } while (ex != null);

      expect(find.byType(ErrorFallbackUI), findsNothing);
    });
  });

  group('AsyncErrorBoundary', () {
    testWidgets('shows loading state while future is pending', (tester) async {
      late Future<String> future;
      future = Future.delayed(
        const Duration(seconds: 10),
        () => 'Data',
      );

      await tester.pumpWidget(
        buildTestApp(
          AsyncErrorBoundary<String>(
            future: future,
            builder: (context, data) => Text(data),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Dispose widget before timer fires to avoid pending timer error
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('shows data when future completes successfully',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          AsyncErrorBoundary<String>(
            future: Future.value('Success'),
            builder: (context, data) => Text(data),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('shows error UI when future fails', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          AsyncErrorBoundary<String>(
            future: Future.error(const NetworkError('Failed')),
            builder: (context, data) => Text(data),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ErrorFallbackUI), findsOneWidget);
    });

    testWidgets('uses custom error builder when provided', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          AsyncErrorBoundary<String>(
            future: Future.error(Exception('Error')),
            builder: (context, data) => Text(data),
            errorBuilder: (context, error, retry) {
              return const Text('Custom Error');
            },
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
        buildTestApp(
          const CompactErrorWidget(
            message: 'Test error message',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('CompactErrorWidget shows retry button when provided',
        (tester) async {
      var retryCalled = false;

      await tester.pumpWidget(
        buildTestApp(
          CompactErrorWidget(
            message: 'Error',
            onRetry: () => retryCalled = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });

    testWidgets('EmptyStateErrorWidget displays title and message',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const EmptyStateErrorWidget(
            title: 'No Data',
            message: 'Failed to load',
          ),
        ),
      );

      await tester.pumpAndSettle();

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
      Future.microtask(() {
        if (mounted) setState(() => _shouldThrow = false);
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

/// Fake ErrorReporter that doesn't depend on Firebase
class _FakeErrorReporter extends ErrorReporter {
  @override
  Future<void> reportError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? metadata,
  }) async {}

  @override
  Future<void> reportFlutterError(FlutterErrorDetails details) async {}
}
