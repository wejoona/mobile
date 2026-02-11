import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages session security: timeouts, token rotation, and invalidation.
class SessionSecurityService {
  static const _tag = 'SessionSecurity';
  final AppLogger _log = AppLogger(_tag);

  Timer? _inactivityTimer;
  DateTime? _lastActivity;
  final Duration _sessionTimeout;
  final Duration _inactivityTimeout;

  final _onTimeout = StreamController<void>.broadcast();
  Stream<void> get onSessionTimeout => _onTimeout.stream;

  SessionSecurityService({
    Duration sessionTimeout = const Duration(hours: 1),
    Duration inactivityTimeout = const Duration(minutes: 15),
  })  : _sessionTimeout = sessionTimeout,
        _inactivityTimeout = inactivityTimeout;

  /// Record user activity to reset inactivity timer.
  void recordActivity() {
    _lastActivity = DateTime.now();
    _resetInactivityTimer();
  }

  /// Start session monitoring.
  void startMonitoring() {
    _lastActivity = DateTime.now();
    _resetInactivityTimer();
    _log.debug('Session monitoring started');
  }

  /// Stop session monitoring.
  void stopMonitoring() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, () {
      _log.debug('Session inactivity timeout');
      _onTimeout.add(null);
    });
  }

  /// Check if session is still valid.
  bool isSessionValid(DateTime sessionStartedAt) {
    return DateTime.now().difference(sessionStartedAt) < _sessionTimeout;
  }

  void dispose() {
    stopMonitoring();
    _onTimeout.close();
  }
}

final sessionSecurityServiceProvider =
    Provider<SessionSecurityService>((ref) {
  final service = SessionSecurityService();
  ref.onDispose(service.dispose);
  return service;
});
