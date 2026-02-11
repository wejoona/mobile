import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Prevents duplicate API requests within a time window.
class RequestDeduplicator {
  static const _tag = 'Dedup';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, DateTime> _pending = {};
  final Duration _window;

  RequestDeduplicator({Duration window = const Duration(seconds: 2)})
      : _window = window;

  /// Returns true if this request should proceed (not a duplicate).
  bool shouldProceed(String requestKey) {
    final now = DateTime.now();
    final last = _pending[requestKey];
    if (last != null && now.difference(last) < _window) {
      _log.debug('Duplicate request blocked: $requestKey');
      return false;
    }
    _pending[requestKey] = now;
    return true;
  }

  void complete(String requestKey) {
    _pending.remove(requestKey);
  }

  void clearAll() => _pending.clear();
}

final requestDeduplicatorProvider = Provider<RequestDeduplicator>((ref) {
  return RequestDeduplicator();
});
