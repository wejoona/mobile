/// Mock interceptor responses for sub-business endpoints.
library;

import 'package:dio/dio.dart';

class SubBusinessMock {
  static Response? handle(RequestOptions options) {
    final path = options.path;
    final method = options.method;

    if (path == '/sub-businesses' && method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {'items': _mockBusinesses},
      );
    }

    if (path == '/sub-businesses' && method == 'POST') {
      return Response(
        requestOptions: options,
        statusCode: 201,
        data: {
          'id': 'sb_new_${DateTime.now().millisecondsSinceEpoch}',
          ...options.data as Map<String, dynamic>,
          'isActive': true,
          'staffCount': 0,
          'totalRevenue': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    }

    if (path.contains('/staff') && method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {'staff': _mockStaff},
      );
    }

    if (path.contains('/staff') && method == 'POST') {
      return Response(
        requestOptions: options,
        statusCode: 201,
        data: {
          'id': 'staff_new',
          ...options.data as Map<String, dynamic>,
          'isActive': true,
          'joinedAt': DateTime.now().toIso8601String(),
        },
      );
    }

    if (path.startsWith('/sub-businesses/') && method == 'GET') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: _mockBusinesses.first,
      );
    }

    return null;
  }

  static final List<Map<String, dynamic>> _mockBusinesses = [
    {
      'id': 'sb_001',
      'name': 'Abidjan Downtown Branch',
      'type': 'retail',
      'description': 'Main retail point in Plateau',
      'address': 'Rue du Commerce, Plateau, Abidjan',
      'isActive': true,
      'staffCount': 3,
      'totalRevenue': 12500.00,
      'createdAt': '2025-06-15T10:00:00Z',
    },
    {
      'id': 'sb_002',
      'name': 'Cocody Mobile Agent',
      'type': 'agent',
      'description': 'Mobile money agent in Cocody',
      'address': 'Cocody, Abidjan',
      'isActive': true,
      'staffCount': 1,
      'totalRevenue': 5200.00,
      'createdAt': '2025-09-01T08:00:00Z',
    },
  ];

  static final List<Map<String, dynamic>> _mockStaff = [
    {
      'id': 'staff_001',
      'name': 'Kouame Yao',
      'phone': '+2250701234567',
      'role': 'manager',
      'isActive': true,
      'joinedAt': '2025-06-20T09:00:00Z',
    },
    {
      'id': 'staff_002',
      'name': 'Awa Traore',
      'phone': '+2250709876543',
      'role': 'cashier',
      'isActive': true,
      'joinedAt': '2025-07-10T09:00:00Z',
    },
  ];
}
