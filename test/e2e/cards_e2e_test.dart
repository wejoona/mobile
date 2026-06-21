/// E2E: Cards — list, create, freeze/unfreeze, transactions
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }

  late E2EClient client;
  String? createdCardId;

  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
    await client.ensureWallet();
  });

  e2eGroup('Cards E2E', () {
    test('GET /cards — list cards', () async {
      final res = await client.get('/cards');
      res.expectOk();
      final data = _payload(res);
      expect(data['available'], isFalse);
      expect(data['status'], 'unavailable');
      expect(data['reason'], 'provider_or_feature_disabled');
      expect(data['featureReason'], 'card_issuing_unavailable');
    });

    test('POST /cards — create virtual card', () async {
      final res = await client.post('/cards', {
        'cardholderName': 'E2E Test User',
        'spendingLimit': 250,
        'cardType': 'virtual',
      });
      expect(res.statusCode, anyOf(200, 201, 400, 403));
      if (res.isOk) {
        final data = _payload(res);
        createdCardId = data['id']?.toString();
      } else {
        final error = _errorPayload(res);
        expect(error['code'], anyOf('E8006', 'FEATURE_UNAVAILABLE'));
        expect(error['message']?.toString(), contains('not available'));
        expect(error['featureReason'], isNotNull);
      }
    });

    test('GET /cards/:id — get card details', () async {
      if (createdCardId == null) {
        return;
      }
      final res = await client.get('/cards/$createdCardId');
      res.expectOk();
    });

    test('PUT /cards/:id/freeze — freeze card', () async {
      if (createdCardId == null) {
        return;
      }
      final res = await client.put('/cards/$createdCardId/freeze');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('PUT /cards/:id/unfreeze — unfreeze card', () async {
      if (createdCardId == null) {
        return;
      }
      final res = await client.put('/cards/$createdCardId/unfreeze');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('GET /cards/:id/transactions — card transactions', () async {
      if (createdCardId == null) {
        return;
      }
      final res = await client.get('/cards/$createdCardId/transactions');
      res.expectOk();
    });

    test('GET /cards — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/cards');
      expect(res.statusCode, 401);
    });
  });
}

Map<String, dynamic> _payload(E2EResponse res) {
  final body = res.data ?? <String, dynamic>{};
  final data = body['data'];
  return data is Map<String, dynamic> ? data : body;
}

Map<String, dynamic> _errorPayload(E2EResponse res) {
  final body = res.data ?? <String, dynamic>{};
  final error = body['error'];
  if (error is Map<String, dynamic>) {
    return error;
  }
  if (error is Map) {
    return Map<String, dynamic>.from(error);
  }
  return body;
}
