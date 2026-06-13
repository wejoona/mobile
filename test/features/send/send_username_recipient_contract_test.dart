import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  test('Korido lookup keeps username when phone is masked', () async {
    final dio = MockDio();
    dio.queueResponse({
      'users': [
        {
          'userId': 'user-123',
          'displayName': 'Awa Konan',
          'username': 'awa_k',
          'phone': '+225******1234',
          'isKoridoUser': true,
        },
      ],
    });

    final service = KoridoContactsService(dio);
    final results = await service.lookupKoridoUsers('awa');

    expect(dio.requestHistory.single.path, '/contacts/lookup');
    expect(dio.requestHistory.single.queryParameters['query'], 'awa');
    expect(results, hasLength(1));
    expect(results.single.phone, isEmpty);
    expect(results.single.username, 'awa_k');
    expect(results.single.canSendInKorido, isTrue);
    expect(results.single.displayIdentifier, '@awa_k');
  });

  test(
    'internal transfer sends recipientUsername when phone is unavailable',
    () async {
      final dio = MockDio();
      dio.queueResponse({
        'transactionId': 'tx-123',
        'status': 'completed',
        'amount': 10,
        'currency': 'USDC',
        'supportReference': 'tx-123',
      });

      final service = TransfersService(dio);
      await service.createInternalTransfer(
        recipientUsername: '@awa_k',
        amount: 10,
        pinToken: 'pin-token',
        idempotencyKey: 'idem-123',
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/transfer/internal');
      expect(request.data, isA<Map<String, dynamic>>());
      final body = request.data as Map<String, dynamic>;
      expect(body['recipientUsername'], 'awa_k');
      expect(body.containsKey('toPhone'), isFalse);
    },
  );

  test('send screens allow discoverable username recipients', () {
    final contactsScreen = File(
      'lib/features/contacts/views/contacts_list_screen.dart',
    ).readAsStringSync();
    final picker = File(
      'lib/features/send/widgets/contact_picker_bottom_sheet.dart',
    ).readAsStringSync();
    final route = File(
      'lib/router/routes/money_movement_routes.dart',
    ).readAsStringSync();
    final recipient = File(
      'lib/features/send/views/recipient_screen.dart',
    ).readAsStringSync();

    expect(contactsScreen, contains('contact.canSendInKorido'));
    expect(contactsScreen, contains("'recipientUsername': contact.username"));
    expect(picker, contains('contact.canSendInKorido'));
    expect(route, contains("extra['username'] ?? extra['recipientUsername']"));
    expect(recipient, contains('setKnownKoridoRecipient'));
    expect(recipient, contains('_hasUsernameRecipient'));
  });
}
