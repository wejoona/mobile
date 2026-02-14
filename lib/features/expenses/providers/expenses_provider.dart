import 'package:usdc_wallet/features/expenses/models/expenses_state.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Expenses provider — aggregates transaction data into expense categories.
final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () => link.close());

  final response = await dio.get('/wallet/transactions/stats');
  final data = response.data as Map<String, dynamic>;
  final categories = data['categories'] as List? ?? [];
  return categories.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
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
