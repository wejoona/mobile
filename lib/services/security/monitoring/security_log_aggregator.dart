import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Aggregates security logs for batch reporting.
class SecurityLogAggregator {
  static const _tag = 'SecLogAgg';
  final AppLogger _log = AppLogger(_tag);
  final List<SecurityLogEntry> _buffer = [];
  static const int _maxBufferSize = 500;

  void add(SecurityLogEntry entry) {
    _buffer.add(entry);
    if (_buffer.length >= _maxBufferSize) {
      flush();
    }
  }

  /// Flush buffered logs to backend.
  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    _log.debug('Flushing ${_buffer.length} security log entries');
    // Would send batch to backend
    _buffer.clear();
  }

  int get pendingCount => _buffer.length;
}

class SecurityLogEntry {
  final String level;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  SecurityLogEntry({
    required this.level,
    required this.message,
    this.context,
  }) : timestamp = DateTime.now();
}

final securityLogAggregatorProvider = Provider<SecurityLogAggregator>((ref) {
  return SecurityLogAggregator();
});
