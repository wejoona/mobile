import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/expenses_service.dart';

class ExpensesState {
  final bool isLoading;
  final String? error;
  final List<Expense> expenses;
  final Map<String, double> categoryTotals;
  final double totalAmount;

  const ExpensesState({
    this.isLoading = false,
    this.error,
    this.expenses = const [],
    this.categoryTotals = const {},
    this.totalAmount = 0,
  });

  ExpensesState copyWith({
    bool? isLoading,
    String? error,
    List<Expense>? expenses,
    Map<String, double>? categoryTotals,
    double? totalAmount,
  }) {
    return ExpensesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      expenses: expenses ?? this.expenses,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

class ExpensesNotifier extends Notifier<ExpensesState> {
  @override
  ExpensesState build() {
    _loadExpenses();
    return const ExpensesState();
  }

  Future<void> _loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await ExpensesService.getExpenses();
      final categoryTotals = _calculateCategoryTotals(expenses);
      final totalAmount = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

      state = state.copyWith(
        isLoading: false,
        expenses: expenses,
        categoryTotals: categoryTotals,
        totalAmount: totalAmount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await ExpensesService.addExpense(expense);
      await _loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await ExpensesService.deleteExpense(id);
      await _loadExpenses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() => _loadExpenses();

  List<Expense> getExpensesByCategory(String category) {
    return state.expenses
        .where((expense) => expense.category == category)
        .toList();
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return state.expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(
  ExpensesNotifier.new,
);
