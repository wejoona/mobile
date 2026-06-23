import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/fx/fx_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('FxService contract', () {
    test('loads supported currencies from canonical FX endpoint', () async {
      final dio = MockDio()
        ..queueResponse({
          'currencies': [
            {
              'code': 'USDC',
              'name': 'USD Coin',
              'symbol': 'USDC',
              'decimals': 6,
              'stablecoinPeg': 'USD',
            },
            {
              'code': 'XOF',
              'name': 'West African CFA franc',
              'symbol': 'F CFA',
              'decimals': 0,
            },
          ],
        });
      final service = FxService(dio);

      final currencies = await service.getSupportedCurrencies();

      expect(dio.requestHistory.single.method, 'GET');
      expect(dio.requestHistory.single.path, '/fx/currencies');
      expect(currencies.map((currency) => currency.code), ['USDC', 'XOF']);
      expect(currencies.first.stablecoinPeg, 'USD');
    });

    test('requests indicative quotes with explicit currency fields', () async {
      final dio = MockDio()
        ..queueResponse({
          'sourceCurrency': 'USDC',
          'targetCurrency': 'XOF',
          'sourceAmount': 100,
          'targetAmount': 60000,
          'rate': 600,
          'inverseRate': 0.001667,
          'fee': 0,
          'quoteType': 'indicative',
          'source': 'fallback',
          'updatedAt': '2026-06-04T00:00:00.000Z',
          'expiresAt': '2026-06-04T00:05:00.000Z',
        });
      final service = FxService(dio);

      final quote = await service.quote(
        amount: 100,
        sourceCurrency: 'usdc',
        targetCurrency: 'xof',
      );

      final request = dio.requestHistory.single;
      expect(request.method, 'GET');
      expect(request.path, '/fx/quote');
      expect(request.queryParameters, {
        'amount': 100.0,
        'sourceCurrency': 'USDC',
        'targetCurrency': 'XOF',
      });
      expect(quote.targetAmount, 60000);
      expect(quote.quoteType, 'indicative');
      expect(quote.updatedAt, DateTime.parse('2026-06-04T00:00:00.000Z'));
    });
  });
}
