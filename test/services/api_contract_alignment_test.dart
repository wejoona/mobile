import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/payment_links/repositories/payment_links_repository.dart';
import 'package:usdc_wallet/features/wallet/providers/transaction_stats_provider.dart';
import 'package:usdc_wallet/services/api/providers/wallet_api.dart';
import 'package:usdc_wallet/services/bulk_payments/bulk_payments_service.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';

import '../helpers/test_utils.dart';

void main() {
  group('API contract alignment', () {
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
      expect(request.path, '/deposits/initiate');
      expect(request.method, 'POST');
      expect(request.data, {
        'amount': 12000,
        'currency': 'XOF',
        'providerCode': 'OMCI',
        'phoneNumber': '+2250701020304',
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
      expect(request.path, '/notifications/unread-count');
      expect(count, 4);
    });

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
  });
}
