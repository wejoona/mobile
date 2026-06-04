import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/payment_links/repositories/payment_links_repository.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/transaction_stats_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/api/providers/wallet_api.dart';
import 'package:usdc_wallet/services/api/providers/notifications_api.dart';
import 'package:usdc_wallet/services/bulk_payments/bulk_payments_service.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

import '../helpers/test_utils.dart';

void main() {
  group('API contract alignment', () {
    test('auth phone normalization sends clean E.164 values', () {
      expect(
        normalizePhoneE164(dialCode: '+225', localNumber: '07 48 80 56 63'),
        '+2250748805663',
      );
      expect(
        normalizePhoneE164(dialCode: '1', localNumber: '(415) 555-0101'),
        '+14155550101',
      );
      expect(digitsOnly('+225 07-48-80-56-63'), '2250748805663');
    });

    test('wallet deposit facade sends backend DTO keys', () async {
      final dio = MockDio()
        ..queueResponse({'id': 'dep_1', 'status': 'pending'});
      final api = WalletApi(dio);

      await api.initiateDeposit({
        'amount': 12000,
        'sourceCurrency': 'XOF',
        'provider': 'orange_money',
        'phoneNumber': '07 01 02 03 04',
      });

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/deposit');
      expect(request.method, 'POST');
      expect(request.data, {
        'amount': 12000,
        'sourceCurrency': 'XOF',
        'channelId': 'orange_money_ci',
      });
    });

    test('transaction stats accepts backend aggregate names', () {
      final stats = TransactionStats.fromJson({
        'totalTransactions': 7,
        'totalDeposits': 3,
        'totalWithdrawals': 1,
        'totalTransfers': 3,
        'totalDeposited': 100,
        'totalWithdrawn': 20,
        'totalTransferred': 30,
      });

      expect(stats.totalCount, 7);
      expect(stats.depositCount, 3);
      expect(stats.withdrawalCount, 1);
      expect(stats.transferCount, 3);
      expect(stats.netFlow, 50);
    });

    test('transfer history uses limit and offset pagination', () async {
      final dio = MockDio()
        ..queueResponse({
          'transfers': [],
          'total': 45,
          'limit': 20,
          'offset': 20,
          'hasMore': true,
        });
      final service = TransfersService(dio);

      final page = await service.getTransfers(page: 2, pageSize: 20);

      final request = dio.requestHistory.single;
      expect(request.path, '/transfers');
      expect(request.queryParameters, {'limit': 20, 'offset': 20});
      expect(page.page, 2);
      expect(page.totalPages, 3);
    });

    test('deposit history uses backend offset pagination', () async {
      final dio = MockDio()
        ..queueResponse({'deposits': [], 'total': 0, 'hasMore': false});
      final service = DepositService(dio);

      await service.listDeposits(page: 3, limit: 20);

      final request = dio.requestHistory.single;
      expect(request.path, '/deposits');
      expect(request.queryParameters, {'limit': 20, 'offset': 40});
    });

    test('notifications parse backend category and readAt fields', () {
      final notification = AppNotification.fromJson({
        'id': 'notif_1',
        'userId': 'user_1',
        'category': 'transaction',
        'title': 'Deposit received',
        'body': 'Your deposit is ready.',
        'data': {'transactionId': 'txn_1'},
        'readAt': '2026-06-02T00:00:00.000Z',
        'createdAt': '2026-06-02T00:00:00.000Z',
      });

      expect(notification.type, NotificationType.transfer);
      expect(notification.isRead, isTrue);
      expect(notification.transactionId, 'txn_1');
    });

    test('notification actions use deployed backend verbs', () async {
      final dio = MockDio()
        ..queueResponse({'success': true})
        ..queueResponse({'success': true});
      final service = NotificationsService(dio);

      await service.markAsRead('notif_1');
      await service.markAllAsRead();

      expect(dio.requestHistory[0].method, 'PUT');
      expect(dio.requestHistory[0].path, '/notifications/notif_1/read');
      expect(dio.requestHistory[1].method, 'PUT');
      expect(dio.requestHistory[1].path, '/notifications/read-all');
    });

    test('notification unread count accepts backend envelope', () async {
      final dio = MockDio()
        ..queueResponse({
          'success': true,
          'data': {'count': 4},
        });
      final service = NotificationsService(dio);

      final count = await service.getUnreadCount();

      final request = dio.requestHistory.single;
      expect(request.path, '/notifications/unread/count');
      expect(count, 4);
    });

    test('push token registration uses deployed mobile SDK route', () async {
      final dio = MockDio()..queueResponse({'message': 'ok'});
      final service = NotificationsService(dio);

      await service.registerFcmToken(
        token: 'fcm-token-1',
        platform: 'ios',
        deviceId: 'device-1',
        deviceName: 'iPhone 17',
        appVersion: '1.0.0',
        osVersion: 'iOS 26.0',
      );

      final request = dio.requestHistory.single;
      expect(request.method, 'POST');
      expect(request.path, '/notifications/push/token');
      expect(request.data, {
        'token': 'fcm-token-1',
        'platform': 'ios',
        'deviceId': 'device-1',
        'deviceName': 'iPhone 17',
        'appVersion': '1.0.0',
        'osVersion': 'iOS 26.0',
      });
    });

    test(
      'notification facade preferences use user preferences route',
      () async {
        final dio = MockDio()
          ..queueResponse({'pushEnabled': true})
          ..queueResponse({'pushEnabled': false});
        final api = NotificationsApi(dio);

        await api.getPreferences();
        await api.updatePreferences({'pushEnabled': false});

        expect(dio.requestHistory[0].method, 'GET');
        expect(dio.requestHistory[0].path, '/user/notification-preferences');
        expect(dio.requestHistory[1].method, 'PUT');
        expect(dio.requestHistory[1].path, '/user/notification-preferences');
        expect(dio.requestHistory[1].data, {'pushEnabled': false});
      },
    );

    test('feature subscriptions include feature and source context', () async {
      final dio = MockDio()
        ..queueResponse({
          'id': 'sub_1',
          'featureKey': 'virtual_card',
          'source': 'cards_screen',
          'status': 'subscribed',
          'phone': '+2250748805663',
          'metadata': {'surface': 'cards', 'countryCode': 'CI'},
          'isActive': true,
        });
      final service = FeatureSubscriptionService(dio);

      final subscription = await service.subscribe(
        const FeatureSubscriptionRequest(
          featureKey: 'virtual_card',
          source: 'cards_screen',
          phone: '+2250748805663',
          metadata: {'surface': 'cards', 'countryCode': 'CI'},
        ),
      );

      final request = dio.requestHistory.single;
      expect(request.method, 'POST');
      expect(request.path, '/feature-subscriptions');
      expect(request.data, {
        'featureKey': 'virtual_card',
        'source': 'cards_screen',
        'status': 'subscribed',
        'phone': '+2250748805663',
        'metadata': {'surface': 'cards', 'countryCode': 'CI'},
      });
      expect(subscription.featureKey, 'virtual_card');
      expect(subscription.isActive, isTrue);
    });

    test('bulk CSV parsing creates the preview draft model', () async {
      final service = BulkPaymentsService(Dio());

      final batch = await service.parseCsvFile(
        'phone,amount,description\n'
        '+2250701020304,12500,Payroll\n'
        '+2250102030405,3500,"Market, bonus"\n',
      );

      expect(batch.payments, hasLength(2));
      expect(batch.totalCount, 2);
      expect(batch.totalAmount, 16000);
      expect(batch.payments.last.description, 'Market, bonus');
    });

    test('payment links repository accepts backend list wrapper', () async {
      final dio = MockDio()
        ..queueResponse({
          'links': [
            {
              'id': 'link_1',
              'shortCode': 'ABC123',
              'amount': 2500,
              'currency': 'USDC',
              'status': 'pending',
              'createdAt': '2026-05-31T00:00:00.000Z',
              'expiresAt': '2026-06-30T00:00:00.000Z',
            },
          ],
          'total': 1,
        });
      final repository = PaymentLinksRepository(dio);

      final links = await repository.getPaymentLinks();

      expect(links, hasLength(1));
      expect(links.single.id, 'link_1');
      expect(links.single.shortCode, 'ABC123');
    });

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

    test('contact sync accepts backend nested match envelope', () async {
      final service = ContactsService(MockSecureStorage());
      final contact = SyncedContact(
        id: 'local_1',
        name: 'Awa Local',
        phone: '+2250748805663',
      );
      final phoneHash = service.hashPhone(contact.phone);
      final dio = MockDio()
        ..queueResponse({
          'success': true,
          'data': {
            'matches': [
              {
                'phoneHash': phoneHash,
                'userId': 'user_1',
                'displayName': 'Awa Korido',
                'avatarUrl': 'https://cdn.example/avatar.png',
              },
            ],
          },
        });

      final contacts = await service.getKoridoContacts(dio, [contact]);

      expect(dio.requestHistory.single.path, '/contacts/sync');
      expect(dio.requestHistory.single.data, {
        'phoneHashes': [phoneHash],
      });
      expect(contacts.single.isKoridoUser, isTrue);
      expect(contacts.single.joonaPayUserId, 'user_1');
      expect(contacts.single.name, 'Awa Korido');
      expect(contacts.single.avatarUrl, 'https://cdn.example/avatar.png');
    });

    test(
      'send recipient validation accepts nested contact sync matches',
      () async {
        final contactsService = ContactsService(MockSecureStorage());
        final phoneHash = contactsService.hashPhone('+2250748805663');
        final dio = MockDio()
          ..queueResponse({
            'data': {
              'matches': [
                {
                  'phoneHash': phoneHash,
                  'userId': 'user_123',
                  'displayName': 'Awa Korido',
                },
              ],
            },
          });
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            contactsServiceProvider.overrideWithValue(contactsService),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(sendMoneyProvider.notifier)
            .setRecipient('+2250748805663');

        final recipient = container.read(sendMoneyProvider).recipient;
        expect(dio.requestHistory.single.path, '/contacts/sync');
        expect(dio.requestHistory.single.data, {
          'phoneHashes': [phoneHash],
        });
        expect(recipient?.isKoridoUser, isTrue);
        expect(recipient?.userId, 'user_123');
        expect(recipient?.name, 'Awa Korido');
      },
    );

    test('passive contact reads do not request iOS permission', () {
      final contactsServiceSource = File(
        'lib/services/contacts/contacts_service.dart',
      ).readAsStringSync();
      final getDeviceContactsBody = RegExp(
        r'Future<List<Contact>> getDeviceContacts\(\) async \{([\s\S]*?)\n  \}',
      ).firstMatch(contactsServiceSource)!.group(1)!;
      final contactSyncProviderSource = File(
        'lib/features/contacts/providers/contact_sync_provider.dart',
      ).readAsStringSync();
      final syncContactsBody = RegExp(
        r'Future<void> syncContacts\(\) async \{([\s\S]*?)\n  Future<void> syncIfNeeded',
      ).firstMatch(contactSyncProviderSource)!.group(1)!;

      expect(getDeviceContactsBody, contains('Permission.contacts.status'));
      expect(getDeviceContactsBody, isNot(contains('requestPermission')));
      expect(
        getDeviceContactsBody,
        isNot(contains('Permission.contacts.request')),
      );
      expect(syncContactsBody, contains('Permission.contacts.status'));
      expect(syncContactsBody, isNot(contains('await requestPermission')));
      expect(syncContactsBody, isNot(contains('Permission.contacts.request')));
    });

    test('contact lookup accepts backend nested user envelope', () async {
      final dio = MockDio()
        ..queueResponse({
          'success': true,
          'data': {
            'users': [
              {
                'id': 'user_1',
                'displayName': 'Awa Korido',
                'phoneNumber': '+2250748805663',
                'photoUrl': 'https://cdn.example/avatar.png',
              },
            ],
          },
        });
      final service = KoridoContactsService(dio);

      final users = await service.lookupKoridoUsers('awa');

      expect(dio.requestHistory.single.path, '/contacts/lookup');
      expect(dio.requestHistory.single.queryParameters, {'query': 'awa'});
      expect(users.single.isKoridoUser, isTrue);
      expect(users.single.joonaPayUserId, 'user_1');
      expect(users.single.name, 'Awa Korido');
      expect(users.single.phone, '+2250748805663');
      expect(users.single.avatarUrl, 'https://cdn.example/avatar.png');
    });
  });
}
