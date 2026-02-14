import 'package:usdc_wallet/domain/entities/expense.dart';

class ExpensesState {
  final bool isLoading;
  final String? error;
  final List<Expense> expenses;
  final double total;
  final double totalAmount;
  final Map<String, double> categoryTotals;

  const ExpensesState({this.isLoading = false, this.error, this.expenses = const [], this.total = 0, this.totalAmount = 0, this.categoryTotals = const {}});
}
