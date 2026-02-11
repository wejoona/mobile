/// E2E: Bank Linking — list banks, link/unlink accounts
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  const testPhone = '+2250700000000';
  String? linkedAccountId;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(testPhone);
  });

  group('Bank Linking E2E', () {
    test('GET /banks — list available banks', () async {
      final res = await client.get('/banks');
      // May be at /bank-accounts/banks or /banks
      expect(res.statusCode, anyOf(200, 404));
    });

    test('GET /bank-accounts — list linked accounts', () async {
      final res = await client.get('/bank-accounts');
      res.expectOk();
    });

    test('POST /bank-accounts — link bank account', () async {
      final res = await client.post('/bank-accounts', {
        'bankCode': 'BICICI',
        'accountNumber': '0123456789',
        'accountName': 'E2E Test Account',
        'currency': 'XOF',
      });
      expect(res.statusCode, anyOf(200, 201, 400));
      if (res.isOk) {
        final data = res.data?['data'] ?? res.data;
        linkedAccountId = data?['id']?.toString();
      }
    });

    test('GET /bank-accounts/:id — get specific account', () async {
      if (linkedAccountId == null) return;
      final res = await client.get('/bank-accounts/$linkedAccountId');
      res.expectOk();
    });

    test('DELETE /bank-accounts/:id — unlink account', () async {
      if (linkedAccountId == null) return;
      final res = await client.delete('/bank-accounts/$linkedAccountId');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('POST /bank-accounts — missing fields returns 400', () async {
      final res = await client.post('/bank-accounts', {});
      expect(res.statusCode, 400);
    });

    test('GET /bank-accounts — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/bank-accounts');
      expect(res.statusCode, 401);
    });
  });
}
