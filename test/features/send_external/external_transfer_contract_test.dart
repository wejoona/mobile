import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/send_external/models/external_transfer_request.dart';

void main() {
  group('External transfer contract', () {
    test('serializes backend recipientAddress field', () {
      const request = ExternalTransferRequest(
        address: '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
        amount: 12.5,
        network: NetworkOption.polygon,
      );

      expect(request.toJson(), {
        'recipientAddress': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0',
        'amount': 12.5,
        'network': 'polygon',
      });
    });

    test('parses transfer response without tx hash yet', () {
      final result = ExternalTransferResult.fromJson({
        'id': 'txn_123',
        'status': 'pending',
        'amount': 12.5,
        'fee': 0.01,
        'recipientBlockchain': 'polygon',
        'createdAt': '2026-05-25T12:00:00.000Z',
      });

      expect(result.transactionId, 'txn_123');
      expect(result.txHash, isEmpty);
      expect(result.network, NetworkOption.polygon);
      expect(result.status, 'pending');
    });
  });
}
