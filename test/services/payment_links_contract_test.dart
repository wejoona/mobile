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
  });
}
