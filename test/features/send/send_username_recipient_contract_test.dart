import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/features/send/models/transfer_request.dart';
import 'package:usdc_wallet/services/api/providers/transfers_api.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  test(
    'transfer request serializes phone recipient using backend toPhone key',
    () {
      const request = TransferRequest(
        recipientPhone: '+2250748805663',
        amount: 12.5,
        note: 'Dinner',
      );

      expect(request.toJson(), {
        'toPhone': '+2250748805663',
        'amount': 12.5,
        'note': 'Dinner',
      });
      expect(request.toJson().containsKey('recipientPhone'), isFalse);
    },
  );

  test(
    'transfer request keeps exactly one recipient identifier by stability order',
    () {
      const request = TransferRequest(
        recipientId: ' 123e4567-e89b-12d3-a456-426614174003 ',
        recipientPhone: '+225+2250748805663',
        recipientUsername: '@awa_k',
        amount: 12.5,
      );

      expect(request.toJson(), {
        'recipientId': '123e4567-e89b-12d3-a456-426614174003',
        'amount': 12.5,
      });
    },
  );

  test('transfer request normalizes phone-only recipients to E.164', () {
    const request = TransferRequest(
      recipientPhone: '+225+2250748805663',
      amount: 12.5,
    );

    expect(request.toJson(), {'toPhone': '+2250748805663', 'amount': 12.5});
  });

  test('transaction headers carry completed step-up proof token', () {
    final headers = transactionHeaders(
      pinToken: 'pin-token',
      idempotencyKey: 'idem-123',
      stepUpToken: 'step-up-123',
    );

    expect(headers['X-Pin-Token'], 'pin-token');
    expect(headers['X-Idempotency-Key'], 'idem-123');
    expect(headers['X-Step-Up-Token'], 'step-up-123');
  });

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

  test(
    'internal transfer normalizes malformed phone before backend submit',
    () async {
      final dio = MockDio();
      dio.queueResponse({
        'transactionId': 'tx-phone',
        'status': 'completed',
        'amount': 10,
        'currency': 'USDC',
        'supportReference': 'tx-phone',
      });

      final service = TransfersService(dio);
      await service.createInternalTransfer(
        recipientPhone: '+225+2250748805663',
        amount: 10,
        pinToken: 'pin-token',
        idempotencyKey: 'idem-phone',
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/transfer/internal');
      final body = request.data as Map<String, dynamic>;
      expect(body['toPhone'], '+2250748805663');
      expect(body.containsKey('recipientPhone'), isFalse);
    },
  );

  test('internal transfer forwards completed step-up token header', () async {
    final dio = MockDio();
    dio.queueResponse({
      'transactionId': 'tx-step-up',
      'status': 'completed',
      'amount': 10,
      'currency': 'USDC',
      'supportReference': 'tx-step-up',
    });

    final service = TransfersService(dio);
    await service.createInternalTransfer(
      recipientUsername: '@awa_k',
      amount: 10,
      pinToken: 'pin-token',
      idempotencyKey: 'idem-step-up',
      stepUpToken: 'challenge-token-123',
    );

    final request = dio.requestHistory.single;
    expect(request.path, '/wallet/transfer/internal');
    expect(request.headers['X-Pin-Token'], 'pin-token');
    expect(request.headers['X-Idempotency-Key'], 'idem-step-up');
    expect(request.headers['X-Step-Up-Token'], 'challenge-token-123');
  });

  test('transfers api adapter canonicalizes legacy recipient maps', () async {
    final dio = MockDio();
    dio.queueResponse({'transactionId': 'tx-api', 'status': 'completed'});

    await TransfersApi(dio).sendInternal({
      'recipientId': ' 123e4567-e89b-12d3-a456-426614174003 ',
      'recipientPhone': '+225+2250748805663',
      'recipientUsername': '@awa_k',
      'amount': 10,
    });

    final request = dio.requestHistory.single;
    expect(request.path, '/wallet/transfer/internal');
    expect(request.data, {
      'amount': 10,
      'recipientId': '123e4567-e89b-12d3-a456-426614174003',
    });
  });

  test(
    'transfers api adapter forwards completed step-up token header',
    () async {
      final dio = MockDio();
      dio.queueResponse({
        'transactionId': 'tx-api-step-up',
        'status': 'completed',
      });

      await TransfersApi(dio).sendInternal(
        {'recipientUsername': '@awa_k', 'amount': 10},
        pinToken: 'pin-token',
        idempotencyKey: 'idem-api-step-up',
        stepUpToken: 'api-step-up-token',
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/transfer/internal');
      expect(request.headers['X-Pin-Token'], 'pin-token');
      expect(request.headers['X-Idempotency-Key'], 'idem-api-step-up');
      expect(request.headers['X-Step-Up-Token'], 'api-step-up-token');
    },
  );

  test(
    'internal transfer sends recipientId when selected from lookup',
    () async {
      final dio = MockDio();
      dio.queueResponse({
        'transactionId': 'tx-456',
        'status': 'completed',
        'amount': 12,
        'currency': 'USDC',
        'supportReference': 'tx-456',
      });

      final service = TransfersService(dio);
      await service.createInternalTransfer(
        recipientId: '123e4567-e89b-12d3-a456-426614174003',
        amount: 12,
        pinToken: 'pin-token',
        idempotencyKey: 'idem-456',
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/transfer/internal');
      expect(request.data, isA<Map<String, dynamic>>());
      final body = request.data as Map<String, dynamic>;
      expect(body['recipientId'], '123e4567-e89b-12d3-a456-426614174003');
      expect(body.containsKey('toPhone'), isFalse);
      expect(body.containsKey('recipientUsername'), isFalse);
    },
  );

  test(
    'internal transfer prefers stable recipientId when lookup also has phone and username',
    () async {
      final dio = MockDio();
      dio.queueResponse({
        'transactionId': 'tx-789',
        'status': 'completed',
        'amount': 20,
        'currency': 'USDC',
        'supportReference': 'tx-789',
      });

      final service = TransfersService(dio);
      await service.createInternalTransfer(
        recipientId: '123e4567-e89b-12d3-a456-426614174003',
        recipientPhone: '+2250748805663',
        recipientUsername: '@awa_k',
        amount: 20,
        pinToken: 'pin-token',
        idempotencyKey: 'idem-789',
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/transfer/internal');
      final body = request.data as Map<String, dynamic>;
      expect(body, {
        'recipientId': '123e4567-e89b-12d3-a456-426614174003',
        'amount': 20,
      });
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
    expect(recipient, contains('_hasUserIdRecipient'));
    expect(
      recipient,
      contains(
        'final myUsername = _normalizeUsername(authState.user?.username);',
      ),
    );
    expect(recipient, contains('_selectedRecipientUsername == myUsername'));
  });

  test('recent recipients preserve Korido user identity for stable sends', () {
    final recent = RecentRecipient.fromJson({
      'phoneNumber': '+2250748805663',
      'name': 'Awa Konan',
      'userId': 'user-123',
      'username': 'awa_k',
      'lastTransferDate': '2026-06-14T10:00:00.000Z',
      'lastAmount': 15,
      'isKoridoUser': true,
    });

    expect(recent.userId, 'user-123');
    expect(recent.username, 'awa_k');
    expect(recent.isKoridoUser, isTrue);

    final recipientScreen = File(
      'lib/features/send/views/recipient_screen.dart',
    ).readAsStringSync();
    expect(recipientScreen, contains('username: recipient.username'));
    expect(recipientScreen, contains('userId: recipient.userId'));
  });
}
