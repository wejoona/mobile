import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_request.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscriptions_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('Feature subscription contract', () {
    test('serializes feature waitlist subscription with feature context', () {
      final request = FeatureSubscriptionRequest(
        featureKey: 'virtual_card',
        source: 'cards_screen',
        metadata: {'locale': 'en', 'region': 'US'},
      );

      expect(request.toJson(), {
        'featureKey': 'virtual_card',
        'source': 'cards_screen',
        'metadata': {'locale': 'en', 'region': 'US'},
      });
    });

    test('posts to backend feature-subscriptions endpoint', () async {
      final dio = MockDio()
        ..queueResponse({
          'id': 'sub_1',
          'featureKey': 'virtual_card',
          'source': 'cards_screen',
          'status': 'subscribed',
          'userId': 'user_1',
          'metadata': {'surface': 'cards'},
          'isActive': true,
          'createdAt': '2026-06-02T00:00:00.000Z',
          'updatedAt': '2026-06-02T00:00:00.000Z',
        }, statusCode: 201);
      final service = FeatureSubscriptionsService(dio);

      final response = await service.subscribe(
        FeatureSubscriptionRequest(
          featureKey: 'virtual_card',
          source: 'cards_screen',
          metadata: {'surface': 'cards'},
        ),
      );

      expect(response.featureKey, 'virtual_card');
      expect(response.source, 'cards_screen');
      expect(response.isActive, isTrue);
      expect(dio.requestHistory.single.path, '/feature-subscriptions');
      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.data, {
        'featureKey': 'virtual_card',
        'source': 'cards_screen',
        'metadata': {'surface': 'cards'},
      });
    });

    test('accepts enveloped backend subscription response', () async {
      final dio = MockDio()
        ..queueResponse({
          'subscription': {
            'id': 'sub_1',
            'featureKey': 'virtual_card',
            'source': 'cards_screen',
            'status': 'subscribed',
            'userId': 'user_1',
            'metadata': {'surface': 'cards'},
            'isActive': true,
            'createdAt': '2026-06-02T00:00:00.000Z',
            'updatedAt': '2026-06-02T00:00:00.000Z',
          },
        }, statusCode: 201);
      final service = FeatureSubscriptionsService(dio);

      final response = await service.subscribe(
        FeatureSubscriptionRequest(
          featureKey: 'virtual_card',
          source: 'cards_screen',
          metadata: {'surface': 'cards'},
        ),
      );

      expect(response.id, 'sub_1');
      expect(response.userId, 'user_1');
      expect(response.metadata?['surface'], 'cards');
    });
  });
}
