import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Crash reporting with PII scrubbing.
///
/// Ensures that crash reports sent to external services do not
/// contain personally identifiable information.
class CrashReporter {
  static const _tag = 'CrashReporter';
  final AppLogger _log = AppLogger(_tag);

  /// PII patterns to scrub from crash reports.
  static final _piiPatterns = [
    RegExp(r'\b\d{8,15}\b'),                  // Phone numbers
    RegExp(r'\b[\w.]+@[\w.]+\.\w+\b'),        // Email addresses
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Card numbers
    RegExp(r'\b0x[a-fA-F0-9]{40}\b'),         // Wallet addresses
    RegExp(r'\b[A-Z0-9]{24,}\b'),             // API keys/tokens
    RegExp(r'pin["\s:=]+\d+', caseSensitive: false), // PIN values
  ];

  /// Report an error with PII scrubbed.
  Future<void> reportError({
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final scrubbed = _scrubPii(error.toString());
    final _scrubbedContext = context != null ? _scrubMap(context) : null;

    _log.error('Crash report: $scrubbed');

    // Would send to crash reporting service (e.g. Sentry, Crashlytics)
    // with scrubbed data only
  }

  /// Scrub PII from a string.
  String _scrubPii(String input) {
    String result = input;
    for (final pattern in _piiPatterns) {
      result = result.replaceAll(pattern, '[REDACTED]');
    }
    return result;
  }

  /// Scrub PII from a map.
  Map<String, dynamic> _scrubMap(Map<String, dynamic> input) {
    final result = <String, dynamic>{};
    const sensitiveKeys = [
      'phone', 'email', 'name', 'address', 'pin', 'token',
      'password', 'secret', 'key', 'firstName', 'lastName',
    ];

    for (final entry in input.entries) {
      if (sensitiveKeys.any((k) =>
          entry.key.toLowerCase().contains(k.toLowerCase()))) {
        result[entry.key] = '[REDACTED]';
      } else if (entry.value is String) {
        result[entry.key] = _scrubPii(entry.value as String);
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = _scrubMap(entry.value as Map<String, dynamic>);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

final crashReporterProvider = Provider<CrashReporter>((ref) {
  return CrashReporter();
});
