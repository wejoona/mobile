import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Sanitizes request/response headers to prevent info leakage.
class HeaderSanitizer {
  static const _tag = 'HeaderSanitizer';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  static const _sensitiveHeaders = [
    'authorization', 'cookie', 'x-api-key', 'x-auth-token',
  ];

  /// Sanitize headers for logging (mask sensitive values).
  Map<String, String> sanitizeForLogging(Map<String, String> headers) {
    return headers.map((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value);
    });
  }

  /// Strip unnecessary headers from outgoing requests.
  Map<String, String> stripUnnecessary(Map<String, String> headers) {
    final stripped = Map<String, String>.from(headers);
    stripped.remove('x-debug');
    stripped.remove('x-trace-id');
    return stripped;
  }
}

final headerSanitizerProvider = Provider<HeaderSanitizer>((ref) {
  return HeaderSanitizer();
});
