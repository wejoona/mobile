import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/features/expenses/models/expenses_state.dart';
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
    final response = await dio.get(ApiEndpoints.walletTransactionStats);
    final categories = _listPayload(response.data, const [
      'categories',
      'byCategory',
      'items',
    ]);
    if (categories.isNotEmpty) {
      return categories
          .whereType<Map>()
          .map((item) => Expense.fromJson(Map<String, dynamic>.from(item)))
          .where((expense) => expense.amount > 0)
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
    }
  } catch (_) {
    // Stats endpoint unavailable — fall through to client-side aggregation
  }

  // Fallback: aggregate from recent transactions
  try {
    final txResponse = await dio.get(
      ApiEndpoints.walletTransactions,
      queryParameters: {'limit': 100, 'type': 'withdrawal'},
    );
    final transactions = _listPayload(txResponse.data, const [
      'transactions',
      'items',
      'data',
    ]);

    final categoryMap = <String, double>{};
    for (final tx in transactions) {
      if (tx is! Map) continue;
      final map = Map<String, dynamic>.from(tx);
      final category = map['category'] as String? ?? ExpenseCategory.other;
      final amount = _readAmount(map);
      categoryMap[category] = (categoryMap[category] ?? 0) + amount;
    }

    return categoryMap.entries
        .map(
          (entry) => Expense(
            id: entry.key,
            date: DateTime.now(),
            category: entry.key,
            amount: entry.value,
          ),
        )
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
  final expenses = async.value ?? <Expense>[];
  final categoryTotals = <String, double>{};
  for (final expense in expenses) {
    categoryTotals[expense.category] =
        (categoryTotals[expense.category] ?? 0) + expense.amount;
  }
  final total = expenses.fold<double>(
    0,
    (sum, expense) => sum + expense.amount,
  );

  return ExpensesState(
    isLoading: async.isLoading,
    error: async.error?.toString(),
    expenses: expenses,
    total: total,
    totalAmount: total,
    categoryTotals: categoryTotals,
  );
});

Object? _unwrapPayload(Object? raw) {
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data != null) return data;
    return raw;
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data != null) return data;
    return map;
  }
  return raw;
}

List<dynamic> _listPayload(Object? raw, List<String> keys) {
  final payload = _unwrapPayload(raw);
  if (payload is List) return payload;
  if (payload is! Map) return const [];
  final data = Map<String, dynamic>.from(payload);
  for (final key in keys) {
    final value = data[key];
    if (value is List) return value;
    if (value is Map) {
      final nested = _listPayload(value, keys);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

double _readAmount(Map<String, dynamic> data) {
  for (final key in const ['amount', 'totalAmount', 'total_amount', 'value']) {
    final value = data[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
  }
  return 0;
}
