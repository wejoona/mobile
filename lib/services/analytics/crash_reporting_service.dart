import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Crash Reporting Service Provider
final crashReportingServiceProvider = Provider<CrashReportingService>(
  (ref) => CrashReportingService(),
);

/// Firebase Crashlytics Service
/// Reports crashes and non-fatal errors to Firebase
class CrashReportingService {
  CrashReportingService() : this._(_initializeCrashlytics());

  CrashReportingService._(this._crashlytics)
    : _isEnabled = _crashlytics != null;
  static const _logger = AppLogger('Crashlytics');
  final FirebaseCrashlytics? _crashlytics;
  final bool _isEnabled;

  static FirebaseCrashlytics? _initializeCrashlytics() {
    if (MockConfig.useMocks) {
      return null;
    }

    try {
      return FirebaseCrashlytics.instance;
    } on Object catch (error) {
      _logger.debug('Failed to initialize: $error');
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
        unawaited(_crashlytics?.recordFlutterFatalError(details));

        // Still print in debug mode for development
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
      };

      // Pass all uncaught async errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(_crashlytics?.recordError(error, stack, fatal: true));
        return true;
      };

      _logger.debug('Initialized successfully');
    } on Object catch (error) {
      _logger.debug('Failed to initialize: $error');
    }
  }

  /// Record a non-fatal error
  Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _crashlytics?.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );

      if (kDebugMode) {
        _logger.debug('Error recorded: $exception');
        if (reason != null) {
          _logger.debug('Reason: $reason');
        }
      }
    } on Object catch (error) {
      _logger.debug('Failed to record error: $error');
    }
  }

  /// Record API error with context
  Future<void> recordApiError(
    DioException exception, {
    String? endpoint,
    String? userId,
  }) async {
    if (!_isEnabled) {
      return;
    }

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
        await _setSafeCustomKey('user_id', userId);
      }

      await recordError(exception, exception.stackTrace, reason: reason);
    } on Object catch (error) {
      _logger.debug('Failed to record API error: $error');
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
    Object exception, {
    String? reason,
    String? userId,
  }) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _crashlytics?.setCustomKey('error_type', 'auth_error');
      if (userId != null) {
        await _setSafeCustomKey('user_id', userId);
      }

      await recordError(
        exception,
        exception is Error ? exception.stackTrace : StackTrace.current,
        reason: reason ?? 'Authentication error',
      );
    } on Object catch (error) {
      _logger.debug('Failed to record auth error: $error');
    }
  }

  /// Record payment/transfer error
  Future<void> recordPaymentError(
    Object exception, {
    required String paymentType,
    String? amount,
    String? currency,
    String? transactionId,
    String? userId,
  }) async {
    if (!_isEnabled) {
      return;
    }

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
        await _setSafeCustomKey('user_id', userId);
      }

      await recordError(
        exception,
        exception is Error ? exception.stackTrace : StackTrace.current,
        reason: 'Payment error: $paymentType',
      );
    } on Object catch (error) {
      _logger.debug('Failed to record payment error: $error');
    }
  }

  /// Record KYC error
  Future<void> recordKycError(
    Object exception, {
    String? tier,
    String? step,
    String? userId,
  }) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _crashlytics?.setCustomKey('error_type', 'kyc_error');

      if (tier != null) {
        await _crashlytics?.setCustomKey('kyc_tier', tier);
      }
      if (step != null) {
        await _crashlytics?.setCustomKey('kyc_step', step);
      }
      if (userId != null) {
        await _setSafeCustomKey('user_id', userId);
      }

      await recordError(
        exception,
        exception is Error ? exception.stackTrace : StackTrace.current,
        reason: 'KYC error${tier != null ? ': $tier' : ''}',
      );
    } on Object catch (error) {
      _logger.debug('Failed to record KYC error: $error');
    }
  }

  /// Log a custom message
  Future<void> log(String message) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _crashlytics?.log(message);
      _logger.debug('Log: $message');
    } on Object catch (error) {
      _logger.debug('Failed to log message: $error');
    }
  }

  /// Set user identifier
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _crashlytics?.setUserIdentifier(userId ?? '');
      _logger.debug('User ID set: $userId');
    } on Object catch (error) {
      _logger.debug('Failed to set user ID: $error');
    }
  }

  /// Set custom key-value pair for crash context
  Future<void> setCustomKey(String key, Object? value) async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _setSafeCustomKey(key, value);

      _logger.debug('Custom key set: $key = $value');
    } on Object catch (error) {
      _logger.debug('Failed to set custom key: $error');
    }
  }

  Future<void> _setSafeCustomKey(String key, Object? value) async {
    if (_isSensitiveCrashKey(key)) {
      await _crashlytics?.setCustomKey(key, '[redacted]');
      return;
    }

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
  }

  bool _isSensitiveCrashKey(String key) {
    final normalized = key.toLowerCase();
    return normalized.contains('email') ||
        normalized.contains('phone') ||
        normalized.contains('token') ||
        normalized.contains('authorization') ||
        normalized.contains('wallet_address');
  }

  /// Clear user data (e.g., on logout)
  Future<void> clearUserData() async {
    if (!_isEnabled) {
      return;
    }

    try {
      await _crashlytics?.setUserIdentifier('');
      // Clear any sensitive custom keys
      await _crashlytics?.setCustomKey('user_id', '');

      _logger.debug('User data cleared');
    } on Object catch (error) {
      _logger.debug('Failed to clear user data: $error');
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
