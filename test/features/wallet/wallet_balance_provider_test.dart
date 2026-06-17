import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/exchange_rate_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('walletBalanceProvider', () {
    test('does not create a wallet from the direct balance reader', () async {
      final dio = MockDio()
        ..queueErrorResponse(statusCode: 404, message: 'Wallet not found');

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      container.read(walletBalanceProvider);
      await pumpEventQueue();

      final state = container.read(walletBalanceProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          404,
        ),
      );

      expect(dio.requestHistory.single.method, 'GET');
      expect(dio.requestHistory.single.path, '/wallet');
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

    test('parses keyed balance maps from wallet responses', () async {
      final dio = MockDio()
        ..queueResponse({
          'walletId': 'wallet_1',
          'currency': 'USDC',
          'balances': {
            'usd': {'available': '0', 'pending': '0', 'total': '0'},
            'usdc': {
              'availableDecimal': '42.750000',
              'pendingDecimal': '1.250000',
              'totalDecimal': '44.000000',
            },
          },
        });

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final balance = await container.read(walletBalanceProvider.future);

      expect(balance.available, 42.75);
      expect(balance.pending, 1.25);
      expect(balance.total, 44);
      expect(balance.currency, 'USDC');
    });

    test('keeps sibling balances beside nested wallet envelope', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'wallet': {
              'id': 'wallet_nested',
              'address': '0xnested',
              'currency': 'USDC',
            },
            'balances': [
              {
                'currency': 'USDC',
                'availableDecimal': '52.000000',
                'pendingDecimal': '3.000000',
                'totalDecimal': '55.000000',
              },
            ],
          },
        });

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final balance = await container.read(walletBalanceProvider.future);

      expect(balance.available, 52);
      expect(balance.pending, 3);
      expect(balance.total, 55);
      expect(balance.currency, 'USDC');
    });
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

    test('does not fabricate a rate when the backend fails', () async {
      final dio = MockDio()
        ..queueErrorResponse(statusCode: 503, message: 'Rate unavailable');

      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      container.read(exchangeRateProvider);
      await pumpEventQueue();

      expect(container.read(exchangeRateProvider).hasError, isTrue);
    });

    test(
      'does not fabricate a rate when the response has no valid rate',
      () async {
        final dio = MockDio()
          ..queueResponse({'timestamp': '2026-06-11T08:00:00.000Z'});

        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        container.read(exchangeRateProvider);
        await pumpEventQueue();

        final state = container.read(exchangeRateProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<FormatException>());
      },
    );
  });
}
