import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/exchange_rate_provider.dart';
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

    test(
      'selects the spendable USDC row instead of trusting row order',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'walletId': 'wallet_1',
            'currency': 'USD',
            'balances': [
              {
                'currency': 'EUR',
                'availableDecimal': '0.000000',
                'pendingDecimal': '0.000000',
                'totalDecimal': '0.000000',
              },
              {
                'currency': 'USDC',
                'availableDecimal': '42.750000',
                'pendingDecimal': '0.250000',
                'totalDecimal': '43.000000',
              },
            ],
          });

        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        final balance = await container.read(walletBalanceProvider.future);

        expect(balance.available, 42.75);
        expect(balance.pending, 0.25);
        expect(balance.total, 43);
        expect(balance.currency, 'USDC');
      },
    );
  });

  group('exchangeRateProvider', () {
    test('uses the canonical wallet exchange-rate endpoint', () async {
      final dio = MockDio()
        ..queueResponse({
          'fromCurrency': 'XOF',
          'toCurrency': 'USD',
          'rate': 602.25,
          'timestamp': '2026-06-11T08:00:00.000Z',
        });

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final rate = await container.read(exchangeRateProvider.future);

      expect(rate.rate, 602.25);
      expect(rate.toXof(2), 1204.5);
      expect(dio.requestHistory.single.method, 'GET');
      expect(dio.requestHistory.single.path, '/wallet/exchange-rate');
      expect(dio.requestHistory.single.queryParameters, {
        'sourceCurrency': 'XOF',
        'targetCurrency': 'USD',
        'amount': 10000,
        'direction': 'buy',
      });
    });

    test('derives XOF per USD from canonical amount fields', () async {
      final dio = MockDio()
        ..queueResponse({
          'sourceCurrency': 'XOF',
          'targetCurrency': 'USD',
          'sourceAmountDecimal': '10000.000000',
          'targetAmountDecimal': '16.250000',
        });

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final rate = await container.read(exchangeRateProvider.future);

      expect(rate.rate, closeTo(615.3846, 0.0001));
    });
  });
}
