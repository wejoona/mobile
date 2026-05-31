import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';

import '../helpers/test_utils.dart';

void main() {
  group('mobile API contract alignment', () {
    test('PIN client contract stays on user PIN routes', () {
      final walletApiSource = File(
        'lib/services/api/providers/wallet_api.dart',
      ).readAsStringSync();
      final pinServiceSource = File(
        'lib/services/pin/pin_service.dart',
      ).readAsStringSync();
      final jweSource = File(
        'lib/services/security/jwe/jwe_interceptor.dart',
      ).readAsStringSync();
      final transferContractSource = File(
        'lib/mocks/services/transfers/transfers_contract.dart',
      ).readAsStringSync();
      final transferMockSource = File(
        'lib/mocks/services/transfers/transfers_mock.dart',
      ).readAsStringSync();

      final combinedContractText = [
        walletApiSource,
        jweSource,
        transferContractSource,
        transferMockSource,
      ].join('\n');

      expect(pinServiceSource, contains('/user/pin/verify'));
      expect(pinServiceSource, contains('/user/pin/set'));
      expect(combinedContractText, isNot(contains('/wallet/pin/verify')));
      expect(combinedContractText, isNot(contains('/wallet/pin/set')));
      expect(
        '$pinServiceSource\n$combinedContractText',
        contains('/user/pin/verify'),
      );
    });

    test('cards API uses backend verbs for freeze and unfreeze', () {
      final cardsApiSource = File(
        'lib/services/api/providers/cards_api.dart',
      ).readAsStringSync();

      expect(cardsApiSource, contains("_dio.put('/cards/\$id/freeze'"));
      expect(cardsApiSource, contains("_dio.put('/cards/\$id/unfreeze'"));
      expect(cardsApiSource, isNot(contains("_dio.post('/cards/\$id/freeze'")));
      expect(
        cardsApiSource,
        isNot(contains("_dio.post('/cards/\$id/unfreeze'")),
      );
    });

    test('cards transaction endpoint accepts backend empty response', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': <dynamic>[],
          'transactions': <dynamic>[],
          'total': 0,
          'limit': 20,
          'offset': 0,
        });
      final service = CardsService(dio);

      final result = await service.getCardTransactions('card_1');

      expect(result['data'], isEmpty);
      expect(result['transactions'], isEmpty);
      expect(result['total'], 0);
      expect(result['limit'], 20);
      expect(result['offset'], 0);
      expect(dio.requestHistory.single.path, '/cards/card_1/transactions');
      expect(dio.requestHistory.single.method, 'GET');
    });
  });
}
