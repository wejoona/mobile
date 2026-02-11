/// Mock interceptor responses for expenses endpoints.
library;

import 'dart:convert';
import 'package:dio/dio.dart';

/// Mock data for expenses API endpoints.
class ExpensesMock {
  static Response? handle(RequestOptions options) {
    final path = options.path;
    final method = options.method;

    if (path == '/expenses' && method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'items': _mockExpenses,
          'pagination': {
            'page': 1,
            'limit': 20,
            'total': 3,
            'totalPages': 1,
          },
        },
      );
    }

    if (path == '/expenses/categories' && method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'categories': _mockCategories,
        },
      );
    }

    if (path == '/expenses/report' && method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'totalAmount': 245.50,
          'byCategory': {
            'food': 120.00,
            'transport': 75.50,
            'utilities': 50.00,
          },
          'totalCount': 3,
          'startDate': '2026-01-01T00:00:00Z',
          'endDate': '2026-01-31T23:59:59Z',
        },
      );
    }

    if (path.startsWith('/expenses/') && method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: _mockExpenses.first,
      );
    }

    if (path == '/expenses' && method == 'POST') {
      return Response(
        requestOptions: options,
        statusCode: 201,
        data: {
          'id': 'exp_new_${DateTime.now().millisecondsSinceEpoch}',
          ...options.data as Map<String, dynamic>,
          'currency': 'USDC',
          'date': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    }

    if (path.startsWith('/expenses/') && method == 'DELETE') {
      return Response(
        requestOptions: options,
        statusCode: 204,
      );
    }

    return null;
  }

  static final List<Map<String, dynamic>> _mockExpenses = [
    {
      'id': 'exp_001',
      'description': 'Lunch at Chez Maman',
      'amount': 15.00,
      'currency': 'USDC',
      'category': 'food',
      'note': 'Team lunch',
      'date': '2026-02-10T12:30:00Z',
      'createdAt': '2026-02-10T12:35:00Z',
    },
    {
      'id': 'exp_002',
      'description': 'Taxi to office',
      'amount': 5.50,
      'currency': 'USDC',
      'category': 'transport',
      'date': '2026-02-10T08:00:00Z',
      'createdAt': '2026-02-10T08:05:00Z',
    },
    {
      'id': 'exp_003',
      'description': 'Electricity bill',
      'amount': 25.00,
      'currency': 'USDC',
      'category': 'utilities',
      'note': 'January payment',
      'date': '2026-02-09T14:00:00Z',
      'createdAt': '2026-02-09T14:10:00Z',
    },
  ];

  static final List<Map<String, dynamic>> _mockCategories = [
    {'id': 'food', 'name': 'Food & Dining', 'icon': 'restaurant', 'color': '#FF9800'},
    {'id': 'transport', 'name': 'Transport', 'icon': 'directions_car', 'color': '#2196F3'},
    {'id': 'utilities', 'name': 'Utilities', 'icon': 'bolt', 'color': '#FFC107'},
    {'id': 'shopping', 'name': 'Shopping', 'icon': 'shopping_bag', 'color': '#E91E63'},
    {'id': 'health', 'name': 'Health', 'icon': 'medical_services', 'color': '#4CAF50'},
    {'id': 'education', 'name': 'Education', 'icon': 'school', 'color': '#9C27B0'},
    {'id': 'entertainment', 'name': 'Entertainment', 'icon': 'movie', 'color': '#F44336'},
    {'id': 'other', 'name': 'Other', 'icon': 'more_horiz', 'color': '#607D8B'},
  ];
}
