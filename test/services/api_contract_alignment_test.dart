import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/entities/notification_preferences.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart' as wallet_tx;
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/notifications/providers/notification_count_provider.dart'
    as notification_count;
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    as notification_feed;
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';
import 'package:usdc_wallet/features/payment_links/repositories/payment_links_repository.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/features/settings/repositories/sessions_repository.dart';
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
import 'package:usdc_wallet/services/auth/auth_service.dart';
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

    test('wallet exchange rate facade uses deployed alias route', () async {
      final dio = MockDio()
        ..queueResponse({
          'fromCurrency': 'XOF',
          'toCurrency': 'USD',
          'rate': 600,
          'timestamp': '2026-06-04T00:00:00.000Z',
        });
      final api = WalletApi(dio);

      await api.getRate(
        sourceCurrency: 'XOF',
        targetCurrency: 'USD',
        amount: 1000,
      );

      final request = dio.requestHistory.single;
      expect(request.method, 'GET');
      expect(request.path, '/wallet/exchange-rate');
      expect(request.queryParameters, {
        'sourceCurrency': 'XOF',
        'targetCurrency': 'USD',
        'amount': 1000.0,
        'direction': 'buy',
      });
    });

    test('refresh response accepts root and envelope token payloads', () {
      final root = RefreshResponse.fromJson({
        'accessToken': 'access-root',
        'refreshToken': 'refresh-root',
        'expiresIn': 900,
      });
      final enveloped = RefreshResponse.fromJson({
        'data': {
          'accessToken': 'access-envelope',
          'refreshToken': 'refresh-envelope',
          'expiresIn': 1200,
        },
      });

      expect(root.accessToken, 'access-root');
      expect(root.refreshToken, 'refresh-root');
      expect(root.expiresIn, 900);
      expect(enveloped.accessToken, 'access-envelope');
      expect(enveloped.refreshToken, 'refresh-envelope');
      expect(enveloped.expiresIn, 1200);
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
      expect(request.path, '/notifications/unread-count');
      expect(count, 4);
    });

    test(
      'home notification badge uses backend unread count provider',
      () async {
        final container = ProviderContainer(
          overrides: [
            notification_feed.unreadNotificationCountProvider.overrideWith((
              ref,
            ) async {
              return 7;
            }),
          ],
        );
        addTearDown(container.dispose);

        await container.read(
          notification_feed.unreadNotificationCountProvider.future,
        );

        expect(
          container.read(notification_count.unreadNotificationCountProvider),
          7,
        );
      },
    );

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
      expect(request.path, '/notifications/device-token');
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
          ..queueResponse({
            'data': {
              'channels': {'push': true, 'email': true, 'sms': true},
              'categories': {'marketing': false},
            },
          })
          ..queueResponse({
            'data': {
              'channels': {'push': true, 'email': true, 'sms': true},
              'categories': {'marketing': true},
            },
          });
        final api = NotificationsApi(dio);

        await api.getPreferences();
        await api.updatePreferences({
          'categories': {'marketing': true},
        });

        expect(dio.requestHistory[0].method, 'GET');
        expect(dio.requestHistory[0].path, '/notifications/preferences');
        expect(dio.requestHistory[1].method, 'PUT');
        expect(dio.requestHistory[1].path, '/notifications/preferences');
        expect(dio.requestHistory[1].data, {
          'categories': {'marketing': true},
        });
      },
    );

    test(
      'notification preferences full save sends nested backend DTO keys',
      () {
        final preferences = UserNotificationPreferences.defaults().copyWith(
          pushEnabled: false,
          pushMarketing: true,
          emailMarketing: true,
          lowBalanceThreshold: 25,
        );

        expect(preferences.toUpdateJson(), {
          'channels': {
            'push': false,
            'email': true,
            'sms': true,
            'inApp': true,
          },
          'categories': {
            'transaction': true,
            'security': true,
            'marketing': true,
            'system': true,
          },
        });
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
          featureName: 'Korido virtual card',
          requestedFeature: 'virtual_card_launch',
          countryCode: 'CI',
          locale: 'fr-CI',
          platform: 'ios',
          appVersion: '1.0.0+1',
          metadata: {'surface': 'cards'},
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
        'featureName': 'Korido virtual card',
        'requestedFeature': 'virtual_card_launch',
        'countryCode': 'CI',
        'locale': 'fr-CI',
        'platform': 'ios',
        'appVersion': '1.0.0+1',
        'metadata': {'surface': 'cards'},
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

    test('cards service preserves backend capability metadata', () async {
      final dio = MockDio()
        ..queueResponse({
          'cards': [],
          'data': [],
          'available': false,
          'status': 'unavailable',
          'reason': 'provider_or_feature_disabled',
          'featureReason': 'card_issuing_unavailable',
          'provider': null,
        });
      final service = CardsService(dio);

      final result = await service.getCards();

      expect(dio.requestHistory.single.path, '/cards');
      expect(result['data'], isEmpty);
      expect(result['available'], isFalse);
      expect(result['status'], 'unavailable');
      expect(result['reason'], 'provider_or_feature_disabled');
      expect(result['featureReason'], 'card_issuing_unavailable');
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

    test('transaction parser accepts backend type aliases and direction', () {
      final sent = wallet_tx.Transaction.fromJson({
        'id': 'tx_sent',
        'walletId': 'wallet_1',
        'type': 'internal_transfer_sent',
        'status': 'completed',
        'amount': 25,
        'currency': 'USDC',
        'direction': 'debit',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });
      final received = wallet_tx.Transaction.fromJson({
        'id': 'tx_received',
        'walletId': 'wallet_1',
        'type': 'internal_transfer_received',
        'status': 'completed',
        'amount': 25,
        'currency': 'USDC',
        'direction': 'credit',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });
      final external = wallet_tx.Transaction.fromJson({
        'id': 'tx_external',
        'walletId': 'wallet_1',
        'type': 'external_transfer',
        'status': 'completed',
        'amount': 25,
        'currency': 'USDC',
        'direction': 'debit',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });
      final deposit = wallet_tx.Transaction.fromJson({
        'id': 'tx_deposit',
        'walletId': 'wallet_1',
        'type': 'mobile_money_deposit',
        'status': 'completed',
        'amount': 25,
        'currency': 'USDC',
        'direction': 'credit',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });
      final withdrawal = wallet_tx.Transaction.fromJson({
        'id': 'tx_withdrawal',
        'walletId': 'wallet_1',
        'type': 'mobile_money_withdrawal',
        'status': 'completed',
        'amount': 25,
        'currency': 'USDC',
        'direction': 'debit',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });

      expect(sent.type, TransactionType.transferInternal);
      expect(sent.isDebit, isTrue);
      expect(sent.isCredit, isFalse);
      expect(received.type, TransactionType.transferInternal);
      expect(received.isCredit, isTrue);
      expect(external.type, TransactionType.transferExternal);
      expect(external.isDebit, isTrue);
      expect(deposit.type, TransactionType.deposit);
      expect(deposit.isCredit, isTrue);
      expect(withdrawal.type, TransactionType.withdrawal);
      expect(withdrawal.isDebit, isTrue);
    });

    test(
      'transaction parser normalizes backend status and transfer aliases',
      () {
        final settledTransfer = wallet_tx.Transaction.fromJson({
          'transactionId': 'tx_settled',
          'walletId': 'wallet_1',
          'type': 'internal',
          'status': 'SETTLED',
          'amount': 12.5,
          'currency': 'USDC',
          'direction': 'DEBIT',
          'reference': 'INT-TXSETTLED',
          'note': 'Lunch',
          'toPhone': '+2250748805663',
          'createdAt': '2026-06-04T12:00:00.000Z',
        });
        final failedTransfer = wallet_tx.Transaction.fromJson({
          'id': 'tx_failed',
          'type': 'transfer_out',
          'status': 'timeout',
          'amount': 12.5,
          'currency': 'USDC',
          'errorMessage': 'Recipient unavailable',
          'createdAt': '2026-06-04T12:00:00.000Z',
        });

        expect(settledTransfer.id, 'tx_settled');
        expect(settledTransfer.type, TransactionType.transferInternal);
        expect(settledTransfer.status, TransactionStatus.completed);
        expect(settledTransfer.isDebit, isTrue);
        expect(settledTransfer.reference, 'INT-TXSETTLED');
        expect(settledTransfer.description, 'Lunch');
        expect(settledTransfer.recipientPhone, '+2250748805663');
        expect(failedTransfer.type, TransactionType.transferInternal);
        expect(failedTransfer.status, TransactionStatus.failed);
        expect(failedTransfer.failureReason, 'Recipient unavailable');
      },
    );

    test('transaction list item honors backend direction aliases', () {
      final sent = TransactionItem.fromJson({
        'id': 'tx_sent',
        'type': 'internal_transfer_sent',
        'amount': 25,
        'currency': 'USDC',
        'status': 'completed',
        'direction': 'debit',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });
      final received = TransactionItem.fromJson({
        'id': 'tx_received',
        'type': 'internal_transfer_received',
        'amount': 25,
        'currency': 'USDC',
        'status': 'completed',
        'direction': 'credit',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });

      expect(sent.isDebit, isTrue);
      expect(sent.isCredit, isFalse);
      expect(received.isCredit, isTrue);
      expect(received.isDebit, isFalse);
    });

    test(
      'transaction list item normalizes status and counterparty aliases',
      () {
        final item = TransactionItem.fromJson({
          'transactionId': 'tx_1',
          'type': 'transfer_in',
          'amount': 25,
          'currency': 'USDC',
          'status': 'SUCCESS',
          'note': 'Dinner',
          'recipientPhone': '+2250748805663',
          'recipientName': 'Awa Korido',
          'createdAt': '2026-06-04T12:00:00.000Z',
        });

        expect(item.id, 'tx_1');
        expect(item.type, 'transfer_in');
        expect(item.status, 'completed');
        expect(item.description, 'Dinner');
        expect(item.counterpartyName, 'Awa Korido');
        expect(item.counterpartyPhone, '+2250748805663');
        expect(item.isCredit, isTrue);
      },
    );

    test(
      'devices repository accepts backend device fields used by screen',
      () async {
        final dio = MockDio()
          ..queueResponse([
            {
              'id': 'device_1',
              'userId': 'user_1',
              'deviceIdentifier': 'ios-vendor-id',
              'displayName': 'iPhone 17',
              'brand': 'Apple',
              'model': 'iPhone17,2',
              'os': 'iOS',
              'osVersion': '26.0',
              'appVersion': '1.2.3',
              'platform': 'ios',
              'isTrusted': true,
              'trustedAt': '2026-06-04T08:00:00.000Z',
              'isActive': true,
              'lastLoginAt': '2026-06-04T10:00:00.000Z',
              'lastIpAddress': '127.0.0.1',
              'loginCount': 4,
              'createdAt': '2026-06-03T10:00:00.000Z',
            },
          ]);
        final repository = DevicesRepository(dio);

        final devices = await repository.getDevices();

        expect(dio.requestHistory.single.path, '/devices');
        expect(devices.single.id, 'device_1');
        expect(devices.single.userId, 'user_1');
        expect(devices.single.deviceIdentifier, 'ios-vendor-id');
        expect(devices.single.deviceName, 'iPhone 17');
        expect(devices.single.appVersion, '1.2.3');
        expect(devices.single.isTrusted, isTrue);
        expect(devices.single.loginCount, 4);
      },
    );

    test('devices repository uses deployed action routes', () async {
      final dio = MockDio()
        ..queueResponse({
          'id': 'device_1',
          'deviceIdentifier': 'ios-vendor-id',
          'platform': 'ios',
        })
        ..queueResponse({'success': true})
        ..queueResponse({'success': true})
        ..queueResponse({'success': true})
        ..queueResponse({'success': true});
      final repository = DevicesRepository(dio);

      await repository.registerDevice(
        deviceId: 'ios-vendor-id',
        platform: 'ios',
        model: 'iPhone17,2',
        brand: 'Apple',
        os: 'iOS',
        deviceName: 'Ben iPhone',
        osVersion: '26.0',
        appVersion: '1.2.3',
        fcmToken: 'fcm-token',
        locale: 'fr_CI',
        metadata: {'fingerprintHash': 'fp_123'},
      );
      await repository.trustDevice('device_1');
      await repository.untrustDevice('device_1');
      await repository.renameDevice('device_1', 'Travel iPhone');
      await repository.revokeDevice('device_1');

      expect(dio.requestHistory[0].method, 'POST');
      expect(dio.requestHistory[0].path, '/devices/register');
      expect(dio.requestHistory[0].data, {
        'deviceIdentifier': 'ios-vendor-id',
        'platform': 'ios',
        'deviceName': 'Ben iPhone',
        'model': 'iPhone17,2',
        'brand': 'Apple',
        'os': 'iOS',
        'osVersion': '26.0',
        'appVersion': '1.2.3',
        'fcmToken': 'fcm-token',
        'metadata': {'locale': 'fr_CI', 'fingerprintHash': 'fp_123'},
      });
      expect(dio.requestHistory[1].method, 'POST');
      expect(dio.requestHistory[1].path, '/devices/device_1/trust');
      expect(dio.requestHistory[2].method, 'POST');
      expect(dio.requestHistory[2].path, '/devices/device_1/untrust');
      expect(dio.requestHistory[3].method, 'POST');
      expect(dio.requestHistory[3].path, '/devices/device_1/rename');
      expect(dio.requestHistory[3].data, {'name': 'Travel iPhone'});
      expect(dio.requestHistory[4].method, 'DELETE');
      expect(dio.requestHistory[4].path, '/devices/device_1');
    });

    test(
      'session repository sends revoke reasons and parses active sessions',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'sessions': [
              {
                'id': 'session_1',
                'userId': 'user_1',
                'deviceId': 'device_1',
                'ipAddress': '::ffff:10.42.0.248',
                'userAgent': 'Korido/1.0.0 (iOS; iPhone17,2; 26.2)',
                'location': null,
                'isActive': true,
                'lastActivityAt': '2026-06-04T10:00:00.000Z',
                'expiresAt': '2026-06-11T10:00:00.000Z',
                'createdAt': '2026-06-04T09:00:00.000Z',
              },
            ],
            'items': [],
            'total': 1,
          })
          ..queueResponse({'success': true});
        final repository = SessionsRepository(dio);

        final sessions = await repository.getSessions();
        await repository.revokeSession('session_1');

        expect(dio.requestHistory[0].path, '/sessions');
        expect(sessions.single.id, 'session_1');
        expect(sessions.single.deviceId, 'device_1');
        expect(sessions.single.userAgent, contains('iPhone17,2'));
        expect(sessions.single.deviceDescription, 'iPhone');
        expect(sessions.single.displayIpAddress, '10.42.0.248');
        expect(dio.requestHistory[1].method, 'DELETE');
        expect(dio.requestHistory[1].path, '/sessions/session_1');
        expect(dio.requestHistory[1].data, {'reason': 'user_revoke_device'});
      },
    );

    test(
      'session repository accepts mobile-safe item aliases without failing screen',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'items': [
              {
                'sessionId': 'session_alias_1',
                'device_id': 'device_alias_1',
                'ip_address': '192.168.1.24',
                'user_agent': 'Korido/1.0.0 (Android; Pixel 9)',
                'is_active': 'true',
                'lastSeenAt': '2026-06-04T11:30:00.000Z',
                'revoked_reason': null,
              },
            ],
            'total': 1,
          });
        final repository = SessionsRepository(dio);

        final sessions = await repository.getSessions();

        expect(dio.requestHistory.single.path, '/sessions');
        expect(sessions.single.id, 'session_alias_1');
        expect(sessions.single.deviceId, 'device_alias_1');
        expect(sessions.single.displayIpAddress, '192.168.1.24');
        expect(sessions.single.deviceDescription, 'Android Device');
        expect(sessions.single.isActive, isTrue);
        expect(
          sessions.single.lastActivityAt.toIso8601String(),
          '2026-06-04T11:30:00.000Z',
        );
        expect(
          sessions.single.expiresAt,
          sessions.single.lastActivityAt.add(const Duration(days: 7)),
        );
      },
    );

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

    test(
      'send recipient validation fails closed when contact sync is unavailable',
      () async {
        final contactsService = ContactsService(MockSecureStorage());
        final dio = MockDio()
          ..queueResponse({
            'matches': [
              {'userId': 'old_user', 'displayName': 'Old Recipient'},
            ],
          })
          ..queueErrorResponse(statusCode: 503, message: 'unavailable');
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            contactsServiceProvider.overrideWithValue(contactsService),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(sendMoneyProvider.notifier);
        await notifier.setRecipient('+2250748805663');
        expect(container.read(sendMoneyProvider).recipient?.isKoridoUser, true);

        await notifier.setRecipient('+2250748805664');

        final state = container.read(sendMoneyProvider);
        expect(dio.requestHistory.last.path, '/contacts/sync');
        expect(state.recipient, isNull);
        expect(state.error, 'recipient_lookup_unavailable');
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

    test('contact lookup keeps masked backend users discoverable', () async {
      final dio = MockDio()
        ..queueResponse({
          'users': [
            {
              'userId': 'user_masked',
              'displayName': 'Awa Masked',
              'phone': '+22507****63',
              'avatarUrl': null,
              'isKoridoUser': true,
            },
          ],
          'total': 1,
        });
      final service = KoridoContactsService(dio);

      final users = await service.lookupKoridoUsers('awa');

      expect(dio.requestHistory.single.path, '/contacts/lookup');
      expect(users.single.id, 'user_masked');
      expect(users.single.joonaPayUserId, 'user_masked');
      expect(users.single.name, 'Awa Masked');
      expect(users.single.phone, isEmpty);
      expect(users.single.isKoridoUser, isTrue);
    });
  });
}
