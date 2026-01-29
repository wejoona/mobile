import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/transaction.dart';
import '../../../services/insights/insights_service.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../../mocks/services/insights/insights_mock.dart';
import '../../../mocks/mock_config.dart';
import '../models/insights_period.dart';
import '../models/spending_category.dart';
import '../models/spending_summary.dart';
import '../models/spending_trend.dart';
import '../models/top_recipient.dart';

/// Selected period state
class SelectedPeriodNotifier extends Notifier<InsightsPeriod> {
  @override
  InsightsPeriod build() => InsightsPeriod.month;

  void setPeriod(InsightsPeriod period) => state = period;
}

final selectedPeriodProvider =
    NotifierProvider<SelectedPeriodNotifier, InsightsPeriod>(
  SelectedPeriodNotifier.new,
);

/// Insights service provider
final insightsServiceProvider = Provider<InsightsService>((ref) {
  return InsightsService();
});

/// All transactions for insights (use mock data in dev mode)
final insightsTransactionsProvider = Provider<List<Transaction>>((ref) {
  // In mock mode, use generated mock data
  if (MockConfig.useMocks) {
    return InsightsMock.generateMockTransactions();
  }

  // In production, get from paginated transactions
  final paginatedState = ref.watch(filteredPaginatedTransactionsProvider);
  return paginatedState.transactions;
});

/// Spending summary provider
final spendingSummaryProvider = Provider<SpendingSummary>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(insightsTransactionsProvider);
  final service = ref.watch(insightsServiceProvider);

  if (transactions.isEmpty) {
    return SpendingSummary.empty();
  }

  return service.getSpendingSummary(transactions, period);
});

/// Spending by category provider
final spendingByCategoryProvider = Provider<List<SpendingCategory>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(insightsTransactionsProvider);
  final service = ref.watch(insightsServiceProvider);

  if (transactions.isEmpty) {
    return [];
  }

  return service.getSpendingByCategory(transactions, period);
});

/// Spending trend provider
final spendingTrendProvider = Provider<List<SpendingTrend>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(insightsTransactionsProvider);
  final service = ref.watch(insightsServiceProvider);

  if (transactions.isEmpty) {
    return [];
  }

  return service.getSpendingTrend(transactions, period);
});

/// Top recipients provider
final topRecipientsProvider = Provider<List<TopRecipient>>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final transactions = ref.watch(insightsTransactionsProvider);
  final service = ref.watch(insightsServiceProvider);

  if (transactions.isEmpty) {
    return [];
  }

  return service.getTopRecipients(transactions, period);
});
