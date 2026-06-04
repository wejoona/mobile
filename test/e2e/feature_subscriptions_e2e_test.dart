/// E2E: Feature subscriptions — coming-soon and waitlist surfaces.
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  late String phone;

  setUpAll(() async {
    client = E2EClient();
    phone = uniqueE2EPhone();
    await client.loginFlow(phone);
  });

  e2eGroup('Feature Subscriptions E2E', () {
    test('POST /feature-subscriptions — subscribes with feature context', () async {
      final res = await client.post('/feature-subscriptions', {
        'featureKey': 'virtual_card',
        'source': 'cards_screen',
        'status': 'subscribed',
        'phone': phone,
        'metadata': {
          'surface': 'cards',
          'featureName': 'Korido virtual card',
          'countryCode': 'CI',
          'locale': 'en',
        },
      });

      res.expectOk();
      final raw = res.data?['data'] ?? res.data;
      expect(raw, isA<Map<String, dynamic>>());
      final data = raw! as Map<String, dynamic>;

      expect(data['featureKey'], 'virtual_card');
      expect(data['source'], 'cards_screen');
      expect(data['status'], 'subscribed');
      expect(data['isActive'], isA<bool>());
      expect(data['metadata'], isA<Map<String, dynamic>>());
      expect((data['metadata'] as Map<String, dynamic>)['surface'], 'cards');
    });

    test('GET /feature-subscriptions — lists current user subscriptions', () async {
      final res = await client.get('/feature-subscriptions?page=1&limit=20');

      res.expectOk();
      final raw = res.data?['data'] ?? res.data;
      expect(raw, isA<Map<String, dynamic>>());
      final data = raw! as Map<String, dynamic>;
      final items = data['items'];

      expect(items, isA<List<dynamic>>());
      expect(
        items,
        contains(
          predicate<dynamic>(
            (item) =>
                item is Map<String, dynamic> &&
                item['featureKey'] == 'virtual_card' &&
                item['source'] == 'cards_screen',
          ),
        ),
      );
    });

    test('GET /feature-subscriptions — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/feature-subscriptions');

      expect(res.statusCode, 401);
    });
  });
}
