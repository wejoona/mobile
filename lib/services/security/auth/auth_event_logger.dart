import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Types of authentication events.
enum AuthEventType {
  loginAttempt, loginSuccess, loginFailure,
  mfaChallenge, mfaSuccess, mfaFailure,
  logoutManual, logoutTimeout, logoutForced,
  pinChange, biometricEnroll, deviceBind,
}

/// Records authentication events for audit trail.
class AuthEventLogger {
  static const _tag = 'AuthEventLog';
  final AppLogger _log = AppLogger(_tag);
  final List<AuthEvent> _events = [];

  void log(AuthEventType type, {Map<String, dynamic>? metadata}) {
    final event = AuthEvent(
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
    _events.add(event);
    _log.debug('Auth event: ${type.name}');
  }

  List<AuthEvent> getEvents({int limit = 50}) {
    return _events.reversed.take(limit).toList();
  }

  List<AuthEvent> getEventsByType(AuthEventType type) {
    return _events.where((e) => e.type == type).toList();
  }

  void clear() => _events.clear();
}

class AuthEvent {
  final AuthEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AuthEvent({
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });
}

final authEventLoggerProvider = Provider<AuthEventLogger>((ref) {
  return AuthEventLogger();
});
