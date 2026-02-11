import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Agrégation journalière des transactions pour rapports.
class DailyAggregationService {
  static const _tag = 'DailyAgg';
  final AppLogger _log = AppLogger(_tag);

  /// Aggregate transactions for a given day.
  DailyAggregation aggregate(DateTime date, List<Map<String, dynamic>> transactions) {
    double totalIn = 0, totalOut = 0;
    int countIn = 0, countOut = 0;

    for (final tx in transactions) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
      if (tx['type'] == 'credit') {
        totalIn += amount;
        countIn++;
      } else {
        totalOut += amount;
        countOut++;
      }
    }

    return DailyAggregation(
      date: date,
      totalIncoming: totalIn,
      totalOutgoing: totalOut,
      incomingCount: countIn,
      outgoingCount: countOut,
    );
  }
}

class DailyAggregation {
  final DateTime date;
  final double totalIncoming;
  final double totalOutgoing;
  final int incomingCount;
  final int outgoingCount;

  double get netFlow => totalIncoming - totalOutgoing;
  int get totalCount => incomingCount + outgoingCount;

  const DailyAggregation({
    required this.date,
    required this.totalIncoming,
    required this.totalOutgoing,
    required this.incomingCount,
    required this.outgoingCount,
  });
}

final dailyAggregationServiceProvider = Provider<DailyAggregationService>((ref) {
  return DailyAggregationService();
});
