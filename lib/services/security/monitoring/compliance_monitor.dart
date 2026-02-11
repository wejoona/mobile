import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Monitors compliance status in real-time.
class ComplianceMonitor {
  static const _tag = 'ComplianceMonitor';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, bool> _checks = {};

  /// Run a compliance check.
  void recordCheck(String checkName, bool passed) {
    _checks[checkName] = passed;
    if (!passed) {
      _log.warn('Compliance check failed: $checkName');
    }
  }

  /// Get overall compliance status.
  bool get isCompliant => _checks.values.every((v) => v);

  /// Get failed checks.
  List<String> get failedChecks =>
      _checks.entries.where((e) => !e.value).map((e) => e.key).toList();

  /// Get compliance percentage.
  double get complianceScore {
    if (_checks.isEmpty) return 100.0;
    final passed = _checks.values.where((v) => v).length;
    return (passed / _checks.length) * 100;
  }

  Map<String, bool> get allChecks => Map.unmodifiable(_checks);
}

final complianceMonitorProvider = Provider<ComplianceMonitor>((ref) {
  return ComplianceMonitor();
});
