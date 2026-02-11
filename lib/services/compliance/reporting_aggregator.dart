import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Aggregated reporting period.
enum ReportingPeriod { daily, weekly, monthly }

/// Summary of transactions for a reporting period.
class ReportingSummary {
  final ReportingPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int transactionCount;
  final double totalVolumeCfa;
  final double totalVolumeUsdc;
  final int crossBorderCount;
  final double crossBorderVolumeCfa;
  final int flaggedCount;
  final Map<String, int> categoryBreakdown;

  const ReportingSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.transactionCount,
    required this.totalVolumeCfa,
    required this.totalVolumeUsdc,
    this.crossBorderCount = 0,
    this.crossBorderVolumeCfa = 0,
    this.flaggedCount = 0,
    this.categoryBreakdown = const {},
  });
}

/// Aggregates transaction data for regulatory reporting periods.
class ReportingAggregator {
  static const _tag = 'ReportingAggregator';
  final AppLogger _log = AppLogger(_tag);

  /// Compute daily summary from transaction list.
  ReportingSummary aggregateDaily({
    required DateTime date,
    required List<Map<String, dynamic>> transactions,
  }) {
    return _aggregate(
      period: ReportingPeriod.daily,
      startDate: DateTime(date.year, date.month, date.day),
      endDate: DateTime(date.year, date.month, date.day, 23, 59, 59),
      transactions: transactions,
    );
  }

  /// Compute monthly summary.
  ReportingSummary aggregateMonthly({
    required int year,
    required int month,
    required List<Map<String, dynamic>> transactions,
  }) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return _aggregate(
      period: ReportingPeriod.monthly,
      startDate: start,
      endDate: end,
      transactions: transactions,
    );
  }

  ReportingSummary _aggregate({
    required ReportingPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> transactions,
  }) {
    double totalCfa = 0;
    double totalUsdc = 0;
    int crossBorder = 0;
    double crossBorderVol = 0;
    int flagged = 0;
    final categories = <String, int>{};

    for (final tx in transactions) {
      final amount = (tx['amountCfa'] as num?)?.toDouble() ?? 0;
      totalCfa += amount;
      totalUsdc += (tx['amountUsdc'] as num?)?.toDouble() ?? 0;

      if (tx['isCrossBorder'] == true) {
        crossBorder++;
        crossBorderVol += amount;
      }
      if (tx['isFlagged'] == true) flagged++;

      final cat = tx['category'] as String? ?? 'other';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }

    _log.debug('Aggregated $period: ${transactions.length} txs, '
        '${totalCfa.toStringAsFixed(0)} XOF');

    return ReportingSummary(
      period: period,
      startDate: startDate,
      endDate: endDate,
      transactionCount: transactions.length,
      totalVolumeCfa: totalCfa,
      totalVolumeUsdc: totalUsdc,
      crossBorderCount: crossBorder,
      crossBorderVolumeCfa: crossBorderVol,
      flaggedCount: flagged,
      categoryBreakdown: categories,
    );
  }
}

final reportingAggregatorProvider = Provider<ReportingAggregator>((ref) {
  return ReportingAggregator();
});
