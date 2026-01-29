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

  /// Mock OCR processing - extracts data from receipt image
  static Future<OcrResult> processReceipt(String imagePath) async {
    // Simulate OCR processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock OCR result
    return OcrResult(
      amount: 25000 + (DateTime.now().millisecond * 100).toDouble(),
      date: DateTime.now(),
      vendor: _getMockVendor(),
    );
  }

  static String _getMockVendor() {
    final vendors = [
      'Restaurant Le Jardin',
      'Hotel Ivoire',
      'Station Shell',
      'Supermarché Casino',
      'Taxi VIP',
      'Pharmacie du Plateau',
      'Café de la Paix',
    ];
    return vendors[DateTime.now().second % vendors.length];
  }
}
