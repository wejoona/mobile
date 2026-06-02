import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('walletBalanceProvider', () {
    test('creates a wallet when the backend reports no wallet yet', () async {
      final dio = MockDio()
        ..queueErrorResponse(statusCode: 404, message: 'Wallet not found')
        ..queueResponse({
          'id': 'wallet_1',
          'currency': 'USDC',
          'balance': 0,
          'status': 'active',
        });

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final balance = await container.read(walletBalanceProvider.future);

      expect(balance.available, 0);
      expect(balance.total, 0);
      expect(balance.currency, 'USDC');
      expect(dio.requestHistory[0].method, 'GET');
      expect(dio.requestHistory[0].path, '/wallet');
      expect(dio.requestHistory[1].method, 'POST');
      expect(dio.requestHistory[1].path, '/wallet/create');
    });

    test('parses the canonical wallet balance response', () async {
      final dio = MockDio()
        ..queueResponse({
          'walletId': 'wallet_1',
          'currency': 'USDC',
          'balances': [
            {
              'currency': 'USDC',
              'available': 25.5,
              'pending': 1,
              'total': 26.5,
            },
          ],
        });

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final balance = await container.read(walletBalanceProvider.future);

      expect(balance.available, 25.5);
      expect(balance.pending, 1);
      expect(balance.total, 26.5);
      expect(balance.currency, 'USDC');
      expect(dio.requestHistory.single.path, '/wallet');
    });
  });
}
