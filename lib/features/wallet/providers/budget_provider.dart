import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Run 347: Budget tracking provider
class BudgetState {
  final double monthlyBudget;
  final double spent;
  final bool isLoading;
  final String? error;
  final Map<String, double> categorySpending;

  const BudgetState({
    this.monthlyBudget = 0,
    this.spent = 0,
    this.isLoading = false,
    this.error,
    this.categorySpending = const {},
  });

  double get remaining => monthlyBudget - spent;
  double get percentUsed => monthlyBudget > 0 ? (spent / monthlyBudget) : 0;
  bool get isOverBudget => spent > monthlyBudget;

  BudgetState copyWith({
    double? monthlyBudget,
    double? spent,
    bool? isLoading,
    String? error,
    Map<String, double>? categorySpending,
  }) => BudgetState(
    monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    spent: spent ?? this.spent,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    categorySpending: categorySpending ?? this.categorySpending,
  );
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier() : super(const BudgetState());

  Future<void> loadBudget() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load budget from local storage or API
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(
        isLoading: false,
        monthlyBudget: 500,
        spent: 0,
        categorySpending: {},
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setBudget(double amount) {
    state = state.copyWith(monthlyBudget: amount);
  }

  void addSpending(String category, double amount) {
    final updated = Map<String, double>.from(state.categorySpending);
    updated[category] = (updated[category] ?? 0) + amount;
    final total = updated.values.fold<double>(0, (a, b) => a + b);
    state = state.copyWith(spent: total, categorySpending: updated);
  }
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) {
  final notifier = BudgetNotifier();
  notifier.loadBudget();
  return notifier;
});
