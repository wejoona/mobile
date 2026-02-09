import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'error_types.dart';

/// Error Reporter Service - Reports errors to Crashlytics
///
/// Handles error reporting with context and severity levels
final errorReporterProvider = Provider<ErrorReporter>((ref) {
  return ErrorReporter();
});

class ErrorReporter {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Report a standard error
  ///
  /// [error] - The error object
  /// [stackTrace] - Optional stack trace
  /// [context] - Additional context (e.g., "LoginScreen", "PaymentFlow")
  /// [severity] - Error severity level
  /// [metadata] - Additional key-value data
  Future<void> reportError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Add context to Crashlytics
      if (context != null) {
        await _crashlytics.setCustomKey('error_context', context);
      }

      // Add severity
      await _crashlytics.setCustomKey('severity', severity.name);

      // Add metadata
      if (metadata != null) {
        for (final entry in metadata.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Determine if fatal
      final fatal = severity == ErrorSeverity.fatal;

      // Record error
      await _crashlytics.recordError(
        error,
        stackTrace ?? StackTrace.current,
        fatal: fatal,
        reason: context,
      );

      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('🔴 Error Reported [${severity.name}]: $error');
        if (context != null) {
          debugPrint('   Context: $context');
        }
        if (stackTrace != null) {
          debugPrint('   Stack: $stackTrace');
        }
        if (metadata != null) {
          debugPrint('   Metadata: $metadata');
        }
      }
    } catch (e) {
      // Don't let error reporting crash the app
      if (kDebugMode) {
        debugPrint('Failed to report error: $e');
      }
    }
  }

  /// Report a Flutter framework error
  Future<void> reportFlutterError(FlutterErrorDetails details) async {
    try {
      await _crashlytics.recordFlutterFatalError(details);

      if (kDebugMode) {
        debugPrint('🔴 Flutter Error: ${details.exception}');
        debugPrint('   Stack: ${details.stack}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to report Flutter error: $e');
      }
    }
  }

  /// Report a network error
  Future<void> reportNetworkError(
    Object error,
    StackTrace? stackTrace, {
    String? endpoint,
    int? statusCode,
    Map<String, dynamic>? requestData,
  }) async {
    final metadata = <String, dynamic>{
      if (endpoint != null) 'endpoint': endpoint,
      if (statusCode != null) 'status_code': statusCode,
      if (requestData != null) 'request_data': requestData.toString(),
    };

    await reportError(
      error,
      stackTrace,
      context: 'NetworkError',
      severity: ErrorSeverity.warning,
      metadata: metadata,
    );
  }

  /// Report a validation error (usually not sent to Crashlytics)
  void reportValidationError(
    String field,
    String message, {
    Map<String, dynamic>? metadata,
  }) {
    if (kDebugMode) {
      debugPrint('⚠️ Validation Error [$field]: $message');
      if (metadata != null) {
        debugPrint('   Metadata: $metadata');
      }
    }
    // Don't send validation errors to Crashlytics
  }

  /// Report a business logic error
  Future<void> reportBusinessError(
    String operation,
    String message, {
    Map<String, dynamic>? metadata,
  }) async {
    await reportError(
      Exception('Business Logic Error: $message'),
      StackTrace.current,
      context: operation,
      severity: ErrorSeverity.info,
      metadata: metadata,
    );
  }

  /// Set user information for error reports
  Future<void> setUserInfo({
    required String userId,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      await _crashlytics.setUserIdentifier(userId);

      if (email != null) {
        await _crashlytics.setCustomKey('user_email', email);
      }

      if (phoneNumber != null) {
        await _crashlytics.setCustomKey('user_phone', phoneNumber);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set user info: $e');
      }
    }
  }

  /// Clear user information (e.g., on logout)
  Future<void> clearUserInfo() async {
    try {
      await _crashlytics.setUserIdentifier('');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to clear user info: $e');
      }
    }
  }

  /// Log a breadcrumb for debugging
  void logBreadcrumb(
    String message, {
    Map<String, dynamic>? metadata,
  }) {
    if (kDebugMode) {
      debugPrint('🍞 Breadcrumb: $message');
      if (metadata != null) {
        debugPrint('   Data: $metadata');
      }
    }

    try {
      _crashlytics.log(message);
      if (metadata != null) {
        for (final entry in metadata.entries) {
          _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to log breadcrumb: $e');
      }
    }
  }

  /// Test crash reporting (debug only)
  void testCrash() {
    if (kDebugMode) {
      throw Exception('Test crash - Ignore this error');
    }
  }
}
