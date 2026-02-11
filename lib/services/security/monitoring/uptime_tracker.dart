import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Tracks app and API uptime for reliability monitoring.
class UptimeTracker {
  static const _tag = 'Uptime';
  final AppLogger _log = AppLogger(_tag);
  final DateTime _startTime = DateTime.now();
  int _healthCheckCount = 0;
  int _healthCheckFailures = 0;

  Duration get uptime => DateTime.now().difference(_startTime);

  void recordHealthCheck(bool success) {
    _healthCheckCount++;
    if (!success) _healthCheckFailures++;
  }

  double get uptimePercent {
    if (_healthCheckCount == 0) return 100.0;
    return ((_healthCheckCount - _healthCheckFailures) / _healthCheckCount) * 100;
  }

  Map<String, dynamic> getReport() {
    return {
      'uptimeMs': uptime.inMilliseconds,
      'checks': _healthCheckCount,
      'failures': _healthCheckFailures,
      'uptimePercent': uptimePercent,
    };
  }
}

final uptimeTrackerProvider = Provider<UptimeTracker>((ref) {
  return UptimeTracker();
});
