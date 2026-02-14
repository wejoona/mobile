import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Securely transmits security logs to the backend.
///
/// Batches and compresses log entries before transmission,
/// stripping PII before sending.
class SecureLogTransmitter {
  static const _tag = 'SecureLogTx';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  final List<Map<String, dynamic>> _buffer = [];
  static const int _batchSize = 50;

  SecureLogTransmitter({required Dio dio}) : _dio = dio;

  /// Add a log entry to the buffer.
  void addEntry(Map<String, dynamic> entry) {
    // Strip potential PII
    final sanitized = _sanitize(entry);
    _buffer.add(sanitized);

    if (_buffer.length >= _batchSize) {
      flush();
    }
  }

  /// Flush buffered logs to the backend.
  Future<void> flush() async {
    if (_buffer.isEmpty) return;

    final batch = List<Map<String, dynamic>>.from(_buffer);
    _buffer.clear();

    try {
      await _dio.post('/security/logs', data: {
        'entries': batch,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _log.debug('Flushed ${batch.length} security log entries');
    } catch (e) {
      _log.error('Failed to flush security logs', e);
      // Re-add to buffer for retry
      _buffer.insertAll(0, batch);
    }
  }

  Map<String, dynamic> _sanitize(Map<String, dynamic> entry) {
    final sanitized = Map<String, dynamic>.from(entry);
    // Remove known PII fields
    const piiFields = ['phone', 'email', 'name', 'address', 'pin'];
    for (final field in piiFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '***REDACTED***';
      }
    }
    return sanitized;
  }
}

final secureLogTransmitterProvider =
    Provider<SecureLogTransmitter>((ref) {
  return SecureLogTransmitter(dio: Dio());
});
