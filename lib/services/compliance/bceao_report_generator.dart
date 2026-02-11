import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Génère les rapports périodiques pour la BCEAO.
class BceaoReportGenerator {
  static const _tag = 'BceaoReport';
  final AppLogger _log = AppLogger(_tag);

  /// Generate daily transaction summary.
  Map<String, dynamic> generateDailySummary(DateTime date, List<Map<String, dynamic>> transactions) {
    _log.debug('Generating BCEAO daily summary for $date');
    double totalVolume = 0;
    int totalCount = 0;
    for (final tx in transactions) {
      totalVolume += (tx['amount'] as num?)?.toDouble() ?? 0;
      totalCount++;
    }
    return {
      'date': date.toIso8601String(),
      'totalTransactions': totalCount,
      'totalVolume': totalVolume,
      'currency': 'XOF',
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Generate monthly regulatory report.
  Map<String, dynamic> generateMonthlyReport(int year, int month, List<Map<String, dynamic>> dailySummaries) {
    return {
      'year': year,
      'month': month,
      'dailySummaries': dailySummaries,
      'reportType': 'BCEAO_MONTHLY',
    };
  }
}

final bceaoReportGeneratorProvider = Provider<BceaoReportGenerator>((ref) {
  return BceaoReportGenerator();
});
