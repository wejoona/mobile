import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'daily_aggregation_service.dart';

/// Agrégation mensuelle des transactions.
class MonthlyAggregationService {
  static const _tag = 'MonthlyAgg';
  final AppLogger _log = AppLogger(_tag);

  /// Aggregate daily summaries into monthly report.
  MonthlyAggregation aggregate(int year, int month, List<DailyAggregation> dailies) {
    double totalIn = 0, totalOut = 0;
    int countIn = 0, countOut = 0;

    for (final daily in dailies) {
      totalIn += daily.totalIncoming;
      totalOut += daily.totalOutgoing;
      countIn += daily.incomingCount;
      countOut += daily.outgoingCount;
    }

    return MonthlyAggregation(
      year: year,
      month: month,
      totalIncoming: totalIn,
      totalOutgoing: totalOut,
      incomingCount: countIn,
      outgoingCount: countOut,
      daysReported: dailies.length,
    );
  }
}

class MonthlyAggregation {
  final int year;
  final int month;
  final double totalIncoming;
  final double totalOutgoing;
  final int incomingCount;
  final int outgoingCount;
  final int daysReported;

  double get netFlow => totalIncoming - totalOutgoing;

  const MonthlyAggregation({
    required this.year,
    required this.month,
    required this.totalIncoming,
    required this.totalOutgoing,
    required this.incomingCount,
    required this.outgoingCount,
    required this.daysReported,
  });
}

final monthlyAggregationServiceProvider = Provider<MonthlyAggregationService>((ref) {
  return MonthlyAggregationService();
});
