import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/expense.dart';
import '../../../services/api/api_client.dart';

/// Category spending breakdown.
final categorySpendingProvider =
    FutureProvider<List<SpendingSummary>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 10), () => link.close());

  try {
    final response = await dio.get('/wallet/transactions/stats');
    final data = response.data as Map<String, dynamic>;
    final categories = data['categories'] as List? ?? [];
    return categories
        .map((e) => SpendingSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

/// Monthly budget tracking.
class BudgetState {
  final double monthlyBudget;
  final double spent;
  final Map<String, double> categoryBudgets;

  const BudgetState({
    this.monthlyBudget = 0,
    this.spent = 0,
    this.categoryBudgets = const {},
  });

  double get remaining => (monthlyBudget - spent).clamp(0, monthlyBudget);
  double get usage => monthlyBudget > 0 ? spent / monthlyBudget : 0;
  bool get isOverBudget => spent > monthlyBudget;
}

final budgetProvider = StateProvider<BudgetState>((ref) {
  return const BudgetState();
});
