/// Expenses API service - mirrors backend ExpenseController.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

class ExpensesService {
  final Dio _dio;

  ExpensesService(this._dio);

  /// GET /expenses
  Future<ExpenseListResponse> getExpenses({
    int page = 1,
    int limit = 20,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (category != null) params['category'] = category;
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await _dio.get('/expenses', queryParameters: params);
      return ExpenseListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /expenses
  Future<ExpenseItem> createExpense({
    required String description,
    required double amount,
    required String category,
    String? receiptUrl,
    String? note,
    DateTime? date,
  }) async {
    try {
      final response = await _dio.post('/expenses', data: {
        'description': description,
        'amount': amount,
        'category': category,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
        if (note != null) 'note': note,
        if (date != null) 'date': date.toIso8601String(),
      });
      return ExpenseItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /expenses/:id
  Future<ExpenseItem> getExpense(String id) async {
    try {
      final response = await _dio.get('/expenses/$id');
      return ExpenseItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// DELETE /expenses/:id
  Future<void> deleteExpense(String id) async {
    try {
      await _dio.delete('/expenses/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /expenses/categories
  Future<List<ExpenseCategory>> getCategories() async {
    try {
      final response = await _dio.get('/expenses/categories');
      // ignore: avoid_dynamic_calls
      return (response.data['categories'] as List<dynamic>)
          .map((e) => ExpenseCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /expenses/report
  Future<ExpenseReport> getReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get('/expenses/report', queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });
      return ExpenseReport.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// Models

class ExpenseItem {
  final String id;
  final String description;
  final double amount;
  final String currency;
  final String category;
  final String? receiptUrl;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const ExpenseItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.currency,
    required this.category,
    this.receiptUrl,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      category: json['category'] as String,
      receiptUrl: json['receiptUrl'] as String?,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ExpenseListResponse {
  final List<ExpenseItem> items;
  final int page;
  final int total;
  final int totalPages;

  const ExpenseListResponse({
    required this.items,
    required this.page,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  factory ExpenseListResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return ExpenseListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      total: pagination['total'] as int,
      totalPages: pagination['totalPages'] as int,
    );
  }
}

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final String color;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String? ?? '#666666',
    );
  }
}

class ExpenseReport {
  final double totalAmount;
  final Map<String, double> byCategory;
  final int totalCount;
  final DateTime startDate;
  final DateTime endDate;

  const ExpenseReport({
    required this.totalAmount,
    required this.byCategory,
    required this.totalCount,
    required this.startDate,
    required this.endDate,
  });

  factory ExpenseReport.fromJson(Map<String, dynamic> json) {
    return ExpenseReport(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      byCategory: (json['byCategory'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      totalCount: json['totalCount'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}

final expensesServiceProvider = Provider<ExpensesService>((ref) {
  return ExpensesService(ref.watch(dioProvider));
});
