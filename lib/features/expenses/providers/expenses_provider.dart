import 'package:usdc_wallet/features/expenses/models/expenses_state.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Expenses provider — aggregates transaction data into expense categories.
/// Falls back to client-side aggregation from transaction history if the
/// stats endpoint returns no category data.
final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());

  try {
    final response = await dio.get('/wallet/transactions/stats');
    final data = response.data as Map<String, dynamic>;
    final categories = data['categories'] as List? ?? [];
    if (categories.isNotEmpty) {
      return categories.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (_) {
    // Stats endpoint unavailable — fall through to client-side aggregation
  }

  // Fallback: aggregate from recent transactions
  try {
    final txResponse = await dio.get('/wallet/transactions', queryParameters: {
      'limit': 100,
      'type': 'withdrawal',
    });
    final txData = txResponse.data as Map<String, dynamic>;
    final transactions = (txData['transactions'] ?? txData['data'] ?? txData['items']) as List? ?? [];

    final categoryMap = <String, double>{};
    for (final tx in transactions) {
      final map = tx as Map<String, dynamic>;
      final category = map['category'] as String? ?? 'Other';
      final amount = (map['amount'] as num?)?.toDouble() ?? 0;
      categoryMap[category] = (categoryMap[category] ?? 0) + amount;
    }

    return categoryMap.entries
        .map((e) => Expense(category: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  } catch (_) {
    return [];
  }
});

/// Expense actions — provides access to the API for expense mutations.
final expenseActionsProvider = Provider((ref) => ref.watch(dioProvider));

/// Total expenses this month.
final totalExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
});

/// Top spending category.
final topExpenseCategoryProvider = Provider<Expense?>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? [];
  if (expenses.isEmpty) return null;
  return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
});

/// Adapter: wraps raw list into ExpensesState for views.
final expensesStateProvider = Provider<ExpensesState>((ref) {
  final async = ref.watch(expensesProvider);
  return ExpensesState(
    isLoading: async.isLoading,
    error: async.error?.toString(),
    expenses: async.value ?? <Expense>[],
  );
});
