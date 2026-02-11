import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Collects security-related metrics for dashboard.
class SecurityMetricsCollector {
  static const _tag = 'SecMetrics';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, int> _counters = {};
  final Map<String, double> _gauges = {};

  void incrementCounter(String name, [int value = 1]) {
    _counters[name] = (_counters[name] ?? 0) + value;
  }

  void setGauge(String name, double value) {
    _gauges[name] = value;
  }

  Map<String, int> get counters => Map.unmodifiable(_counters);
  Map<String, double> get gauges => Map.unmodifiable(_gauges);

  /// Get a summary of all metrics.
  Map<String, dynamic> getSummary() {
    return {
      'counters': _counters,
      'gauges': _gauges,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void reset() {
    _counters.clear();
    _gauges.clear();
  }
}

final securityMetricsCollectorProvider = Provider<SecurityMetricsCollector>((ref) {
  return SecurityMetricsCollector();
});
