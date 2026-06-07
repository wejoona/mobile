import 'package:dio/dio.dart';
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

    final data = options.data is Map<String, dynamic>
        ? options.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final featureKey = data['featureKey'] as String?;
    final source = data['source'] as String?;
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
    final status = data['status'] as String? ?? 'subscribed';
    final response = {
      'id': existing?['id'] ?? MockDataGenerator.uuid(),
      'featureKey': featureKey,
      'source': source,
      'status': status,
      'phone': data['phone'],
      'email': data['email'],
      'userId': userId,
      'metadata': data['metadata'] ?? const <String, dynamic>{},
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

    final page = int.tryParse('${options.queryParameters['page'] ?? 1}') ?? 1;
    final limit =
        int.tryParse('${options.queryParameters['limit'] ?? 20}') ?? 20;

    final allItems = FeatureSubscriptionsMockState.subscriptions
        .where((subscription) => subscription['userId'] == userId)
        .toList();

    final start = ((page - 1) * limit).clamp(0, allItems.length);
    final end = (start + limit).clamp(0, allItems.length);
    final items = allItems.sublist(start, end);

    return MockResponse.success({
      'items': items,
      'total': allItems.length,
      'page': page,
      'limit': limit,
    });
  }
}
