import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpensesService {
  static const _storageKey = 'expenses';

  static Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Expense.fromJson(json)).toList();
  }

  static Future<void> addExpense(Expense expense) async {
    final expenses = await getExpenses();
    expenses.insert(0, expense);
    await _saveExpenses(expenses);
  }

  static Future<void> deleteExpense(String id) async {
    final expenses = await getExpenses();
    expenses.removeWhere((expense) => expense.id == id);
    await _saveExpenses(expenses);
  }

  static Future<void> _saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((expense) => expense.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  /// OCR receipt processing
  /// Currently not available — backend OCR endpoint not yet implemented.
  /// Throws an UnsupportedError to signal the feature is coming soon.
  static Future<OcrResult> processReceipt(String imagePath) async {
    throw Exception(
      'Receipt scanning is coming soon. Please enter expense details manually.',
    );
  }
}
