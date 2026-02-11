import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Record of a login attempt.
class LoginAttempt {
  final DateTime timestamp;
  final bool successful;
  final String? ipAddress;
  final String? deviceId;
  final String? location;
  final String? failureReason;

  const LoginAttempt({
    required this.timestamp,
    required this.successful,
    this.ipAddress,
    this.deviceId,
    this.location,
    this.failureReason,
  });
}

/// Tracks login attempts for anomaly detection.
///
/// Monitors patterns like rapid failures, unusual locations,
/// or new devices to trigger additional security checks.
class LoginAttemptTracker {
  static const _tag = 'LoginTracker';
  final AppLogger _log = AppLogger(_tag);

  final List<LoginAttempt> _recentAttempts = [];
  static const int _maxTracked = 50;

  /// Record a login attempt.
  void record(LoginAttempt attempt) {
    _recentAttempts.add(attempt);
    if (_recentAttempts.length > _maxTracked) {
      _recentAttempts.removeAt(0);
    }

    if (!attempt.successful) {
      _log.debug('Failed login: ${attempt.failureReason}');
    }
  }

  /// Count recent failures within a time window.
  int recentFailures({Duration window = const Duration(minutes: 30)}) {
    final cutoff = DateTime.now().subtract(window);
    return _recentAttempts
        .where((a) => !a.successful && a.timestamp.isAfter(cutoff))
        .length;
  }

  /// Check if there is a rapid failure pattern (possible attack).
  bool hasRapidFailurePattern() {
    return recentFailures(window: const Duration(minutes: 5)) >= 3;
  }

  /// Get last successful login.
  LoginAttempt? get lastSuccessfulLogin {
    try {
      return _recentAttempts.lastWhere((a) => a.successful);
    } catch (_) {
      return null;
    }
  }

  List<LoginAttempt> get attempts => List.unmodifiable(_recentAttempts);
}

final loginAttemptTrackerProvider = Provider<LoginAttemptTracker>((ref) {
  return LoginAttemptTracker();
});
