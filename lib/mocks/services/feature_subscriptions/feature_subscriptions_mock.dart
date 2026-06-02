import 'package:dio/dio.dart';
import 'package:usdc_wallet/mocks/base/mock_data_generator.dart';
import 'package:usdc_wallet/mocks/base/mock_interceptor.dart';

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
    final data = options.data is Map<String, dynamic>
        ? options.data as Map<String, dynamic>
        : const <String, dynamic>{};
    final now = DateTime.now().toIso8601String();
    final featureKey = data['featureKey'] as String? ?? 'unknown_feature';
    final source = data['source'] as String? ?? 'unknown_source';

    final existing = FeatureSubscriptionsMockState.subscriptions
        .where(
          (item) =>
              item['featureKey'] == featureKey && item['source'] == source,
        )
        .cast<Map<String, dynamic>?>()
        .firstWhere((item) => item != null, orElse: () => null);

    final subscription = {
      'id': existing?['id'] ?? MockDataGenerator.uuid(),
      'featureKey': featureKey,
      'source': source,
      'status': data['status'] ?? 'subscribed',
      'phone': data['phone'],
      'email': data['email'],
      'metadata': data['metadata'] ?? const <String, dynamic>{},
      'isActive': (data['status'] ?? 'subscribed') == 'subscribed',
      'createdAt': existing?['createdAt'] ?? now,
      'updatedAt': now,
    };

    FeatureSubscriptionsMockState.subscriptions.removeWhere(
      (item) => item['id'] == subscription['id'],
    );
    FeatureSubscriptionsMockState.subscriptions.insert(0, subscription);
    return MockResponse.success(subscription);
  }

  static Future<MockResponse> _handleList(RequestOptions options) async {
    final page = int.tryParse('${options.queryParameters['page'] ?? 1}') ?? 1;
    final limit =
        int.tryParse('${options.queryParameters['limit'] ?? 20}') ?? 20;
    final start = ((page - 1) * limit).clamp(
      0,
      FeatureSubscriptionsMockState.subscriptions.length,
    );
    final end = (start + limit).clamp(
      0,
      FeatureSubscriptionsMockState.subscriptions.length,
    );

    return MockResponse.success({
      'items': FeatureSubscriptionsMockState.subscriptions.sublist(start, end),
      'total': FeatureSubscriptionsMockState.subscriptions.length,
      'page': page,
      'limit': limit,
    });
  }
}
