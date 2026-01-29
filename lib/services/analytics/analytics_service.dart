import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Firebase Analytics Service
/// Tracks key user events and screen views
class AnalyticsService {
  final FirebaseAnalytics? _analytics;
  final bool _isEnabled;
  static final _logger = AppLogger('Analytics');

  AnalyticsService()
      : _analytics = _initializeAnalytics(),
        _isEnabled = _initializeAnalytics() != null;

  static FirebaseAnalytics? _initializeAnalytics() {
    try {
      return FirebaseAnalytics.instance;
    } catch (e) {
      _logger.warn('Failed to initialize Firebase Analytics', e);
      return null;
    }
  }

  /// Track screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      _logger.debug('Screen view: $screenName');
    } catch (e) {
      _logger.error('Failed to log screen view', e);
    }
  }

  // Auth Events

  /// Track successful login
  Future<void> logLoginSuccess({
    required String method,
    String? userId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics?.logLogin(
        loginMethod: method,
      );
      await _logCustomEvent(
        'login_success',
        parameters: {
          'method': method,
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.error('Failed to log login success', e);
    }
  }

  /// Track failed login
  Future<void> logLoginFailed({
    required String method,
    required String reason,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'login_failed',
        parameters: {
          'method': method,
          'reason': reason,
        },
      );
    } catch (e) {
      _logger.error('Failed to log login failed', e);
    }
  }

  // Transfer Events

  /// Track transfer initiation
  Future<void> logTransferInitiated({
    required String transferType,
    required double amount,
    required String currency,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'transfer_initiated',
        parameters: {
          'transfer_type': transferType,
          'amount': amount,
          'currency': currency,
        },
      );
    } catch (e) {
      _logger.error('Failed to log transfer initiated', e);
    }
  }

  /// Track successful transfer
  Future<void> logTransferCompleted({
    required String transferType,
    required double amount,
    required String currency,
    String? transactionId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'transfer_completed',
        parameters: {
          'transfer_type': transferType,
          'amount': amount,
          'currency': currency,
          if (transactionId != null) 'transaction_id': transactionId,
        },
      );
    } catch (e) {
      _logger.error('Failed to log transfer completed', e);
    }
  }

  /// Track failed transfer
  Future<void> logTransferFailed({
    required String transferType,
    required double amount,
    required String currency,
    required String reason,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'transfer_failed',
        parameters: {
          'transfer_type': transferType,
          'amount': amount,
          'currency': currency,
          'reason': reason,
        },
      );
    } catch (e) {
      _logger.error('Failed to log transfer failed', e);
    }
  }

  // KYC Events

  /// Track KYC flow start
  Future<void> logKycStarted({
    required String tier,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'kyc_started',
        parameters: {
          'tier': tier,
        },
      );
    } catch (e) {
      _logger.error('Failed to log KYC started', e);
    }
  }

  /// Track KYC completion
  Future<void> logKycCompleted({
    required String tier,
    required String status,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'kyc_completed',
        parameters: {
          'tier': tier,
          'status': status,
        },
      );
    } catch (e) {
      _logger.error('Failed to log KYC completed', e);
    }
  }

  // Deposit Events

  /// Track deposit initiation
  Future<void> logDepositInitiated({
    required String method,
    required double amount,
    required String currency,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'deposit_initiated',
        parameters: {
          'method': method,
          'amount': amount,
          'currency': currency,
        },
      );
    } catch (e) {
      _logger.error('Failed to log deposit initiated', e);
    }
  }

  /// Track successful deposit
  Future<void> logDepositCompleted({
    required String method,
    required double amount,
    required String currency,
    String? transactionId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'deposit_completed',
        parameters: {
          'method': method,
          'amount': amount,
          'currency': currency,
          if (transactionId != null) 'transaction_id': transactionId,
        },
      );
    } catch (e) {
      _logger.error('Failed to log deposit completed', e);
    }
  }

  // Bill Payment Events

  /// Track bill payment completion
  Future<void> logBillPaymentCompleted({
    required String billerName,
    required String category,
    required double amount,
    required String currency,
    String? transactionId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _logCustomEvent(
        'bill_payment_completed',
        parameters: {
          'biller_name': billerName,
          'category': category,
          'amount': amount,
          'currency': currency,
          if (transactionId != null) 'transaction_id': transactionId,
        },
      );
    } catch (e) {
      _logger.error('Failed to log bill payment', e);
    }
  }

  // User Properties

  /// Set user ID
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;

    try {
      await _analytics?.setUserId(id: userId);
      _logger.debug('User ID set', userId);
    } catch (e) {
      _logger.error('Failed to set user ID', e);
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics?.setUserProperty(
        name: name,
        value: value,
      );
      _logger.debug('User property set: $name = $value');
    } catch (e) {
      _logger.error('Failed to set user property', e);
    }
  }

  // Generic Event Logging

  /// Log custom event with parameters
  Future<void> _logCustomEvent(
    String eventName, {
    Map<String, Object?>? parameters,
  }) async {
    if (!_isEnabled) return;

    try {
      // Convert Map<String, Object?> to Map<String, Object> by filtering out null values
      final nonNullParameters = parameters?.map(
        (key, value) => MapEntry(key, value ?? 'null'),
      );

      await _analytics?.logEvent(
        name: eventName,
        parameters: nonNullParameters,
      );
      _logger.debug('Event: $eventName', parameters);
    } catch (e) {
      _logger.error('Failed to log event $eventName', e);
    }
  }

  /// Reset analytics data (e.g., on logout)
  Future<void> reset() async {
    if (!_isEnabled) return;

    try {
      await _analytics?.setUserId(id: null);
      _logger.info('Analytics reset');
    } catch (e) {
      _logger.error('Failed to reset analytics', e);
    }
  }
}
