import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/api_contract.dart';
import 'package:usdc_wallet/mocks/base/mock_data_generator.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';

class FeatureSubscriptionsMockState {
  static final List<Map<String, dynamic>> subscriptions = [];

  static void reset() {
    subscriptions.clear();
  }
}

class FeatureSubscriptionsMock {
  static void register(MockInterceptor interceptor) {
    interceptor.register(
      method: 'POST',
      path: '/feature-subscriptions',
      handler: _handleSubscribe,
    );

    interceptor.register(
      method: 'GET',
      path: '/feature-subscriptions',
      handler: _handleList,
    );
  }

  static Future<MockResponse> _handleSubscribe(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final data = options.data as Map<String, dynamic>?;
    final featureKey = data?['featureKey'] as String?;
    final source = data?['source'] as String?;
    if (featureKey == null || featureKey.isEmpty) {
      return MockResponse.badRequest('featureKey is required');
    }
    if (source == null || source.isEmpty) {
      return MockResponse.badRequest('source is required');
    }

    final now = DateTime.now().toIso8601String();
    final existingIndex = FeatureSubscriptionsMockState.subscriptions
        .indexWhere(
          (subscription) =>
              subscription['userId'] == userId &&
              subscription['featureKey'] == featureKey &&
              subscription['source'] == source,
        );

    final existing = existingIndex >= 0
        ? FeatureSubscriptionsMockState.subscriptions[existingIndex]
        : null;
    final status = data?['status'] as String? ?? 'subscribed';
    final response = {
      'id': existing?['id'] ?? MockDataGenerator.uuid(),
      'featureKey': featureKey,
      'source': source,
      'status': status,
      'phone': data?['phone'],
      'email': data?['email'],
      'userId': userId,
      'metadata': data?['metadata'],
      'isActive': status == 'subscribed',
      'createdAt': existing?['createdAt'] ?? now,
      'updatedAt': now,
    };

    if (existingIndex >= 0) {
      FeatureSubscriptionsMockState.subscriptions[existingIndex] = response;
    } else {
      FeatureSubscriptionsMockState.subscriptions.add(response);
    }

    return MockResponse.created(response);
  }

  static Future<MockResponse> _handleList(RequestOptions options) async {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return MockResponse.unauthorized();
    }

    final items = FeatureSubscriptionsMockState.subscriptions
        .where((subscription) => subscription['userId'] == userId)
        .toList();

    return MockResponse.success({
      'items': items,
      'meta': {
        'total': items.length,
        'page': 1,
        'limit': 10,
        'totalPages': items.isEmpty ? 0 : 1,
        'hasNextPage': false,
        'hasPreviousPage': false,
      },
    });
  }
}
