import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Scrubs PII from crash reports and logs.
class PiiScrubber {
  static const _tag = 'PiiScrubber';
  final AppLogger _log = AppLogger(_tag);

  static final _patterns = [
    RegExp(r'\b\d{10,}\b'), // Phone numbers
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Emails
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Card numbers
    RegExp(r'\b0x[a-fA-F0-9]{40}\b'), // Wallet addresses
    RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*'), // Auth tokens
  ];

  /// Scrub PII from text.
  String scrub(String text) {
    var result = text;
    for (final pattern in _patterns) {
      result = result.replaceAll(pattern, '[REDACTED]');
    }
    return result;
  }

  /// Scrub PII from a map of data.
  Map<String, dynamic> scrubMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) return MapEntry(key, scrub(value));
      if (value is Map<String, dynamic>) return MapEntry(key, scrubMap(value));
      return MapEntry(key, value);
    });
  }
}

final piiScrubberProvider = Provider<PiiScrubber>((ref) {
  return PiiScrubber();
});
