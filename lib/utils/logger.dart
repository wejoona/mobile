import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app.
/// Only logs in debug mode to prevent sensitive data leakage in production.
class AppLogger {
  final String tag;

  const AppLogger(this.tag);

  /// Log debug information (only in debug mode)
  void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final dataStr = data != null ? '\n  Data: $data' : '';
      debugPrint('[$timestamp] [DEBUG] [$tag] $message$dataStr');
    }
  }

  /// Log informational messages (only in debug mode)
  void info(String message, [dynamic data]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final dataStr = data != null ? '\n  Data: $data' : '';
      debugPrint('[$timestamp] [INFO] [$tag] $message$dataStr');
    }
  }

  /// Log warnings (only in debug mode)
  void warn(String message, [dynamic data]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final dataStr = data != null ? '\n  Data: $data' : '';
      debugPrint('[$timestamp] [WARN] [$tag] $message$dataStr');
    }
  }

  /// Log errors (only in debug mode)
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final errorStr = error != null ? '\n  Error: $error' : '';
      final stackStr = stackTrace != null ? '\n  Stack: $stackTrace' : '';
      debugPrint('[$timestamp] [ERROR] [$tag] $message$errorStr$stackStr');
    }
  }

  /// Log security-related events (always logs to enable security monitoring)
  /// These are critical for security audits even in production
  void security(String message, {String? level = 'INFO'}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [SECURITY][$level] [$tag] $message');
  }
}
