/// Manages session timeout for security.
/// Forces re-authentication after prolonged inactivity.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Tracks user activity and triggers session timeout.
class SessionTimeoutService {
  Timer? _inactivityTimer;
  final Duration timeout;
  final VoidCallback onTimeout;
  DateTime _lastActivity = DateTime.now();

  SessionTimeoutService({
    this.timeout = const Duration(minutes: 30),
    required this.onTimeout,
  });

  /// Record user activity (tap, scroll, etc.).
  void recordActivity() {
    _lastActivity = DateTime.now();
    _resetTimer();
  }

  /// Start the inactivity timer.
  void start() {
    _resetTimer();
    if (kDebugMode) debugPrint('[Session] Timeout timer started (${timeout.inMinutes}min)');
  }

  /// Stop the inactivity timer.
  void stop() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  /// Check if session has timed out.
  bool get isExpired {
    return DateTime.now().difference(_lastActivity) > timeout;
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeout, () {
      if (kDebugMode) debugPrint('[Session] Inactivity timeout reached');
      onTimeout();
    });
  }

  void dispose() {
    stop();
  }
}
