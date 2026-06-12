import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/payment_links/payment_links_service.dart';

import '../helpers/test_utils.dart';

void main() {
  group('PaymentLinksService contract', () {
    test('payLink sends payable USDC amount in request body', () async {
      final dio = MockDio()
        ..queueResponse({
          'transactionId': 'txn_pay_123',
          'amount': 12.5,
          'status': 'completed',
        });
      final service = PaymentLinksService(dio);

      final result = await service.payLink(
        'ABC123',
        amount: 12.5,
        pinToken: 'pin_token',
        idempotencyKey: 'pay-link-idempotency',
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/payment-links/code/ABC123/pay');
      expect(request.data, {'amount': 12.5});
      expect(result.transactionId, 'txn_pay_123');
      expect(result.amount, 12.5);
      expect(result.status, 'completed');
    });

    test('accepts wrapped link responses from backend envelopes', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'id': 'link_wrapped',
            'shortCode': 'WRAP01',
            'amount': '25.50',
            'currency': 'USDC',
            'status': 'pending',
            'createdAt': '2026-06-01T00:00:00.000Z',
            'expiresAt': '2026-07-01T00:00:00.000Z',
          },
        })
        ..queueResponse({
          'links': [
            {
              'id': 'link_list',
              'shortCode': 'LIST01',
              'amount': 10,
              'currency': 'USDC',
              'status': 'pending',
              'createdAt': '2026-06-01T00:00:00.000Z',
              'expiresAt': '2026-07-01T00:00:00.000Z',
            },
          ],
        });
      final service = PaymentLinksService(dio);

      final link = await service.createPaymentLink(
        amount: 25.5,
        currency: 'USDC',
      );
      final links = await service.getLinks();

      expect(link.id, 'link_wrapped');
      expect(link.amount, 25.5);
      expect(links.single.shortCode, 'LIST01');
    });
  });
}
