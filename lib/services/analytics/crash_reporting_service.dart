import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'package:dio/dio.dart';

/// Crash Reporting Service Provider
final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return CrashReportingService();
});

/// Firebase Crashlytics Service
/// Reports crashes and non-fatal errors to Firebase
class CrashReportingService {
  static final _logger = AppLogger('Crashlytics');
  final FirebaseCrashlytics? _crashlytics;
  final bool _isEnabled;

  CrashReportingService()
      : _crashlytics = _initializeCrashlytics(),
        _isEnabled = _initializeCrashlytics() != null;

  static FirebaseCrashlytics? _initializeCrashlytics() {
    try {
      return FirebaseCrashlytics.instance;
    } catch (e) {
      _logger.debug('Failed to initialize: $e');
      return null;
    }
  }

  /// Initialize crash reporting
  /// Call this early in main() to catch all errors
  Future<void> initialize() async {
    if (!_isEnabled) {
      _logger.debug('Service disabled - Firebase not configured');
      return;
    }

    try {
      // Enable crash collection in release mode only
      // In debug mode, we want to see the actual stack traces
      await _crashlytics?.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics?.recordFlutterFatalError(details);

        // Still print in debug mode for development
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
      };

      // Pass all uncaught async errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics?.recordError(error, stack, fatal: true);
        return true;
      };

      _logger.debug('Initialized successfully');
    } catch (e) {
      _logger.debug('Failed to initialize: $e');
    }
  }

  /// Record a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics?.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );

      if (kDebugMode) {
        _logger.debug('Error recorded: $exception');
        if (reason != null) _logger.debug('Reason: $reason');
      }
    } catch (e) {
      _logger.debug('Failed to record error: $e');
    }
  }

  /// Record API error with context
  Future<void> recordApiError(
    DioException exception, {
    String? endpoint,
    String? userId,
  }) async {
    if (!_isEnabled) return;

    try {
      final reason = _buildApiErrorReason(exception, endpoint);

      await _crashlytics?.setCustomKey('error_type', 'api_error');
      if (endpoint != null) {
        await _crashlytics?.setCustomKey('api_endpoint', endpoint);
      }
      if (exception.response?.statusCode != null) {
        await _crashlytics?.setCustomKey(
          'status_code',
          exception.response!.statusCode!,
        );
      }
      if (userId != null) {
        await _crashlytics?.setCustomKey('user_id', userId);
      }

      await recordError(
        exception,
        exception.stackTrace,
        reason: reason,
        fatal: false,
      );
    } catch (e) {
      _logger.debug('Failed to record API error: $e');
    }
  }

  String _buildApiErrorReason(DioException exception, String? endpoint) {
    final parts = <String>[];

    if (endpoint != null) {
      parts.add('Endpoint: $endpoint');
    }

    if (exception.response?.statusCode != null) {
      parts.add('Status: ${exception.response!.statusCode}');
    }

    parts.add('Type: ${exception.type.name}');

    return parts.join(' | ');
  }

  /// Record authentication error
  Future<void> recordAuthError(
    dynamic exception, {
    String? reason,
    String? userId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics?.setCustomKey('error_type', 'auth_error');
      if (userId != null) {
        await _crashlytics?.setCustomKey('user_id', userId);
      }

      await recordError(
        exception,
        exception is Error ? exception.stackTrace : StackTrace.current,
        reason: reason ?? 'Authentication error',
        fatal: false,
      );
    } catch (e) {
      _logger.debug('Failed to record auth error: $e');
    }
  }

  /// Record payment/transfer error
  Future<void> recordPaymentError(
    dynamic exception, {
    required String paymentType,
    String? amount,
    String? currency,
    String? transactionId,
    String? userId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics?.setCustomKey('error_type', 'payment_error');
      await _crashlytics?.setCustomKey('payment_type', paymentType);

      if (amount != null) {
        await _crashlytics?.setCustomKey('amount', amount);
      }
      if (currency != null) {
        await _crashlytics?.setCustomKey('currency', currency);
      }
      if (transactionId != null) {
        await _crashlytics?.setCustomKey('transaction_id', transactionId);
      }
      if (userId != null) {
        await _crashlytics?.setCustomKey('user_id', userId);
      }

      await recordError(
        exception,
        exception is Error ? exception.stackTrace : StackTrace.current,
        reason: 'Payment error: $paymentType',
        fatal: false,
      );
    } catch (e) {
      _logger.debug('Failed to record payment error: $e');
    }
  }

  /// Record KYC error
  Future<void> recordKycError(
    dynamic exception, {
    String? tier,
    String? step,
    String? userId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics?.setCustomKey('error_type', 'kyc_error');

      if (tier != null) {
        await _crashlytics?.setCustomKey('kyc_tier', tier);
      }
      if (step != null) {
        await _crashlytics?.setCustomKey('kyc_step', step);
      }
      if (userId != null) {
        await _crashlytics?.setCustomKey('user_id', userId);
      }

      await recordError(
        exception,
        exception is Error ? exception.stackTrace : StackTrace.current,
        reason: 'KYC error${tier != null ? ': $tier' : ''}',
        fatal: false,
      );
    } catch (e) {
      _logger.debug('Failed to record KYC error: $e');
    }
  }

  /// Log a custom message
  Future<void> log(String message) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics?.log(message);
      _logger.debug('Log: $message');
    } catch (e) {
      _logger.debug('Failed to log message: $e');
    }
  }

  /// Set user identifier
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;

    try {
      await _crashlytics?.setUserIdentifier(userId ?? '');
      _logger.debug('User ID set: $userId');
    } catch (e) {
      _logger.debug('Failed to set user ID: $e');
    }
  }

  /// Set custom key-value pair for crash context
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isEnabled) return;

    try {
      if (value is String) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics?.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics?.setCustomKey(key, value);
      } else {
        await _crashlytics?.setCustomKey(key, value.toString());
      }

      _logger.debug('Custom key set: $key = $value');
    } catch (e) {
      _logger.debug('Failed to set custom key: $e');
    }
  }

  /// Clear user data (e.g., on logout)
  Future<void> clearUserData() async {
    if (!_isEnabled) return;

    try {
      await _crashlytics?.setUserIdentifier('');
      // Clear any sensitive custom keys
      await _crashlytics?.setCustomKey('user_id', '');

      _logger.debug('User data cleared');
    } catch (e) {
      _logger.debug('Failed to clear user data: $e');
    }
  }

  /// Check if crash reporting is enabled
  bool get isEnabled => _isEnabled;

  /// Force a test crash (debug mode only)
  void testCrash() {
    if (kDebugMode) {
      throw Exception('Test crash from Crashlytics');
    }
  }
}
