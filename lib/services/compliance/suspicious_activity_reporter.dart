import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Déclaration de soupçon - rapporte les activités suspectes.
class SuspiciousActivityReporter {
  static const _tag = 'SAR';
  final AppLogger _log = AppLogger(_tag);
  final List<SuspiciousActivityReport> _reports = [];

  /// File a suspicious activity report.
  Future<String> fileReport(SuspiciousActivityReport report) async {
    _reports.add(report);
    _log.warn('SAR filed: ${report.reason}');
    return 'SAR-${DateTime.now().millisecondsSinceEpoch}';
  }

  List<SuspiciousActivityReport> getPending() {
    return _reports.where((r) => !r.submitted).toList();
  }
}

class SuspiciousActivityReport {
  final String transactionId;
  final String reason;
  final double amount;
  final String userId;
  final DateTime createdAt;
  bool submitted;

  SuspiciousActivityReport({
    required this.transactionId,
    required this.reason,
    required this.amount,
    required this.userId,
    this.submitted = false,
  }) : createdAt = DateTime.now();
}

final suspiciousActivityReporterProvider = Provider<SuspiciousActivityReporter>((ref) {
  return SuspiciousActivityReporter();
});
