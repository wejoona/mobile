import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/entities/notification_preferences.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart' as wallet_tx;
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/features/notifications/providers/notification_count_provider.dart'
    as notification_count;
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart'
    as notification_feed;
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';
import 'package:usdc_wallet/features/payment_links/repositories/payment_links_repository.dart';
import 'package:usdc_wallet/features/payment_links/providers/pay_link_provider.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';
import 'package:usdc_wallet/features/qr_payment/models/qr_data.dart';
import 'package:usdc_wallet/features/qr_payment/providers/qr_payment_provider.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/features/settings/repositories/sessions_repository.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/wallet_actions_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/transaction_stats_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/withdraw_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/api/providers/contacts_api.dart';
import 'package:usdc_wallet/services/api/providers/wallet_api.dart';
import 'package:usdc_wallet/services/api/providers/notifications_api.dart';
import 'package:usdc_wallet/services/bulk_payments/bulk_payments_service.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/services/payment_links/payment_links_service.dart';
import 'package:usdc_wallet/services/preferences/notification_preferences_service.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

import '../helpers/test_utils.dart';

class _CountryUserStateMachine extends UserStateMachine {
  _CountryUserStateMachine(this.countryCode);

  final String countryCode;

  @override
  UserState build() => UserState(countryCode: countryCode);
}

class _IdentityUserStateMachine extends UserStateMachine {
  _IdentityUserStateMachine({required this.userId, required this.phone});

  final String userId;
  final String phone;

  @override
  UserState build() => UserState(
    status: AuthStatus.authenticated,
    userId: userId,
    phone: phone,
    countryCode: 'CI',
  );
}

class _QuietAuthNotifier extends auth.AuthNotifier {
  @override
  auth.AuthState build() =>
      const auth.AuthState(status: auth.AuthStatus.authenticated);
}

class _AuthWithUserNotifier extends auth.AuthNotifier {
  @override
  auth.AuthState build() => auth.AuthState(
    status: auth.AuthStatus.authenticated,
    user: User(
      id: 'user_self',
      phone: '+2250748805663',
      username: 'SelfHandle',
      countryCode: 'CI',
      isPhoneVerified: true,
      role: UserRole.user,
      status: UserStatus.active,
      createdAt: DateTime.parse('2026-06-04T09:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-04T09:00:00.000Z'),
    ),
  );
}

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
      expect(
        normalizePhoneE164(dialCode: '+225', localNumber: '+225+2250748805663'),
        '+2250748805663',
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
        'phoneNumber': '07 01 02 03 04',
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

    test('wallet KYC facade uses canonical KYC routes', () async {
      final dio = MockDio()
        ..queueResponse({'status': 'pending', 'canResubmit': false})
        ..queueResponse({'status': 'pending_verification'});
      final service = WalletService(dio);

      await service.getKycStatus();
      await service.submitKyc(
        firstName: 'Ben',
        lastName: 'Ouattara',
        dateOfBirth: '1990-01-01',
        country: 'CI',
        idType: 'passport',
        idNumber: 'A1234567',
      );

      expect(dio.requestHistory.map((request) => request.method), [
        'GET',
        'POST',
      ]);
      expect(dio.requestHistory.map((request) => request.path), [
        '/kyc/status',
        '/kyc/submit',
      ]);
      expect(dio.requestHistory.last.data, {
        'firstName': 'Ben',
        'lastName': 'Ouattara',
        'dateOfBirth': '1990-01-01',
        'country': 'CI',
        'idType': 'passport',
        'idNumber': 'A1234567',
      });
    });

    test('wallet balance parser accepts backend data envelope', () {
      final response = WalletBalanceResponse.fromJson({
        'success': true,
        'data': {
          'walletId': 'wallet_1',
          'walletAddress': '0xabc',
          'currency': 'USDC',
          'balances': [
            {
              'currency': 'USDC',
              'available': '15.5',
              'pending': 2,
              'total': 17.5,
            },
          ],
        },
      });

      expect(response.walletId, 'wallet_1');
      expect(response.walletAddress, '0xabc');
      expect(response.balances.single.currency, 'USDC');
      expect(response.balances.single.available, 15.5);
      expect(response.balances.single.pending, 2);
      expect(response.balances.single.total, 17.5);
    });

    test(
      'wallet balance parser keeps balances beside nested wallet object',
      () {
        final response = WalletBalanceResponse.fromJson({
          'success': true,
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
            'sourceOfTruth': 'blnk',
            'readStatus': 'fresh',
          },
        });

        expect(response.walletId, 'wallet_nested');
        expect(response.walletAddress, '0xnested');
        expect(response.balances.single.available, 52);
        expect(response.balances.single.pending, 3);
        expect(response.sourceOfTruth, 'blnk');
        expect(response.readStatus, 'fresh');
      },
    );

    test('wallet balance parser accepts flat live balance aliases', () {
      final response = WalletBalanceResponse.fromJson({
        'walletId': 'wallet_1',
        'walletAddress': '0xabc',
        'currency': 'USDC',
        'balanceUsdc': '21.250000',
        'availableBalance': '20.000000',
        'pendingBalance': '1.250000',
      });

      expect(response.walletId, 'wallet_1');
      expect(response.balances.single.currency, 'USDC');
      expect(response.balances.single.available, 20);
      expect(response.balances.single.pending, 1.25);
      expect(response.balances.single.total, 21.25);
    });

    test(
      'wallet balance parser exposes spendable USDC when first row is zero',
      () {
        final response = WalletBalanceResponse.fromJson({
          'walletId': 'wallet_1',
          'walletAddress': '0xabc',
          'currency': 'USDC',
          'balances': [
            {'currency': 'USD', 'available': 0, 'pending': 0, 'total': 0},
            {
              'currency': 'USDC',
              'availableDecimal': '84.250000',
              'pendingDecimal': '0.750000',
              'totalDecimal': '85.000000',
            },
          ],
        });

        expect(response.availableBalance, 84.25);
        expect(response.totalBalance, 85);
      },
    );

    test(
      'wallet balance parser prefers USDC over declared wallet currency',
      () {
        final response = WalletBalanceResponse.fromJson({
          'walletId': 'wallet_1',
          'walletAddress': '0xabc',
          'currency': 'USD',
          'balances': [
            {'currency': 'USD', 'available': 0, 'pending': 0, 'total': 0},
            {
              'currency': 'USDC',
              'availableDecimal': '31.500000',
              'pendingDecimal': '0.500000',
              'totalDecimal': '32.000000',
            },
          ],
        });

        expect(response.availableBalance, 31.5);
        expect(response.totalBalance, 32);
      },
    );

    test(
      'wallet balance parser repairs empty rows from flat live balance fields',
      () {
        final response = WalletBalanceResponse.fromJson({
          'walletId': 'wallet_1',
          'walletAddress': '0xabc',
          'currency': 'USDC',
          'balanceUsdc': '77.125000',
          'availableBalance': '75.000000',
          'pendingBalance': '2.125000',
          'balances': [
            {
              'currency': 'USDC',
              'availableDecimal': '0.000000',
              'pendingDecimal': '0.000000',
              'totalDecimal': '0.000000',
            },
          ],
        });

        expect(response.availableBalance, 75);
        expect(response.totalBalance, 77.125);
        expect(response.balances.single.pending, 2.125);
      },
    );

    test('wallet balance parser accepts keyed balance maps', () {
      final response = WalletBalanceResponse.fromJson({
        'walletId': 'wallet_1',
        'walletAddress': '0xabc',
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

      expect(response.balances, hasLength(2));
      expect(response.availableBalance, 42.75);
      expect(response.totalBalance, 44);
    });

    test(
      'home balance keeps rendering cached balance during degraded errors',
      () {
        final source = File(
          'lib/features/wallet/views/wallet_home_screen.dart',
        ).readAsStringSync();

        expect(
          source,
          contains('if (walletState.hasError && !walletState.hasBalanceData)'),
        );
      },
    );

    test('withdraw result accepts backend envelope and id aliases', () {
      final result = WithdrawResult.fromJson({
        'data': {
          'withdrawalId': 'wdr_123',
          'status': 'processing',
          'providerReference': 'yc_ref_123',
          'message': 'Withdrawal submitted',
        },
      });

      expect(result.id, 'wdr_123');
      expect(result.status, 'processing');
      expect(result.reference, 'yc_ref_123');
      expect(result.instructions, 'Withdrawal submitted');
    });

    test('withdraw fee preview uses backend withdrawal quote', () async {
      final dio = MockDio()
        ..queueResponse({
          'amount': 2500,
          'fee': 125,
          'totalAmount': 2625,
          'fiatAmount': 15000,
          'currency': 'XOF',
          'providerCode': 'OMCI',
          'commercialFeeSource': 'commercial_terms',
        });
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(withdrawProvider.notifier)
        ..selectMethod(WithdrawMethod.orangeMoney);
      await notifier.setAmount(25);

      final request = dio.requestHistory.single;
      expect(request.method, 'POST');
      expect(request.path, '/wallet/cash-out/mobile-money/quote');
      expect(request.data, {
        'amount': 2500,
        'providerCode': 'OMCI',
        'currency': 'XOF',
      });
      expect(container.read(withdrawProvider).fee, 1.25);
    });

    test('wallet actions withdrawal fee uses backend options', () async {
      final dio = MockDio()
        ..queueResponse({
          'country': 'CI',
          'currency': 'USDC',
          'options': [
            {
              'id': 'mtn_momo_ci',
              'type': 'mobile_money',
              'providerCode': 'MTNCI',
              'fee': 2,
              'feeType': 'percentage',
              'minFee': 1,
              'maxFee': 100,
              'enabled': true,
            },
          ],
        });
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final fee = await container
          .read(walletActionsProvider)
          .estimateFee(amount: 250, type: 'withdrawal', providerCode: 'MTNCI');

      final request = dio.requestHistory.single;
      expect(request.method, 'GET');
      expect(request.path, '/wallet/cash-out/mobile-money/options');
      expect(request.queryParameters, {'country': 'CI'});
      expect(fee, 5);
    });

    test(
      'withdraw notifier checks live limits before cash-out submit',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'amount': 2500,
            'fee': 125,
            'totalAmount': 2625,
            'currency': 'XOF',
            'providerCode': 'OMCI',
          })
          ..queueResponse({
            'currency': 'USDC',
            'daily': {
              'send': {'limit': 5000, 'used': 100},
              'withdraw': {'limit': 5000, 'used': 100},
              'deposit': {'limit': 5000, 'used': 100},
            },
            'monthly': {
              'total': {'limit': 50000, 'used': 500},
            },
            'perTransaction': {'send': 2500, 'withdraw': 2500},
          })
          ..queueResponse({
            'id': 'withdraw_123',
            'status': 'pending',
            'reference': 'MM-123',
          });
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(withdrawProvider.notifier)
          ..selectMethod(WithdrawMethod.orangeMoney)
          ..setPhoneNumber('+2250748805663');
        await notifier.setAmount(25);
        await notifier.submit(
          pinToken: 'pin_token_123',
          idempotencyKey: 'idem-withdraw-123',
        );

        expect(
          dio.requestHistory[0].path,
          '/wallet/cash-out/mobile-money/quote',
        );
        expect(dio.requestHistory[1].path, '/user/limits');
        expect(dio.requestHistory[2].path, '/wallet/cash-out/mobile-money');
        expect(container.read(withdrawProvider).result?.id, 'withdraw_123');
      },
    );

    test('wallet actions checks live limits before cash-out submit', () async {
      final dio = MockDio()
        ..queueResponse({
          'currency': 'USDC',
          'daily': {
            'send': {'limit': 5000, 'used': 100},
            'withdraw': {'limit': 5000, 'used': 100},
            'deposit': {'limit': 5000, 'used': 100},
          },
          'monthly': {
            'total': {'limit': 50000, 'used': 500},
          },
          'perTransaction': {'send': 2500, 'withdraw': 2500},
        })
        ..queueResponse({'id': 'withdraw_123', 'status': 'pending'});
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      await container
          .read(walletActionsProvider)
          .requestWithdrawal(
            amount: 25,
            provider: 'orangeMoney',
            phoneNumber: '+2250748805663',
            pinToken: 'pin_token_123',
            idempotencyKey: 'idem-withdraw-123',
          );

      expect(dio.requestHistory[0].path, '/user/limits');
      expect(dio.requestHistory[1].path, '/wallet/cash-out/mobile-money');
      expect(dio.requestHistory[1].headers['X-Pin-Token'], 'pin_token_123');
    });

    test(
      'withdrawal options provider parses backend-owned mobile rails',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'country': 'CI',
            'currency': 'USDC',
            'options': [
              {
                'id': 'wave_ci',
                'name': 'Wave CI',
                'type': 'mobile_money',
                'providerCode': 'WAVECI',
                'country': 'CI',
                'currency': 'USDC',
                'payoutCurrency': 'XOF',
                'minAmount': 1,
                'maxAmount': 5000,
                'fee': 2,
                'feeType': 'percentage',
                'minFee': 1,
                'maxFee': 100,
                'estimatedArrival': '5-15 minutes',
                'enabled': true,
              },
            ],
          });
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        final options = await container.read(
          withdrawalOptionsProvider('CI').future,
        );

        final request = dio.requestHistory.single;
        expect(request.method, 'GET');
        expect(request.path, '/wallet/cash-out/mobile-money/options');
        expect(request.queryParameters, {'country': 'CI'});
        expect(options, hasLength(1));
        expect(options.single.name, 'Wave CI');
        expect(options.single.providerCode, 'WAVECI');
        expect(options.single.isMobileMoney, isTrue);
        expect(options.single.payoutCurrency, 'XOF');
      },
    );

    test('wallet crypto withdraw uses guarded backend route', () async {
      final dio = MockDio()
        ..queueResponse({
          'transactionId': 'txn_withdraw_1',
          'amount': 25,
          'destinationAddress': '0x1234567890abcdef1234567890abcdef12345678',
          'network': 'polygon',
          'fee': 0.5,
          'status': 'pending',
        });
      final service = WalletService(dio);

      final response = await service.withdraw(
        amount: 25,
        destinationAddress: '0x1234567890abcdef1234567890abcdef12345678',
        network: 'polygon',
        pinToken: 'pin_token_123',
        idempotencyKey: 'idem-withdraw-123',
      );

      final request = dio.requestHistory.single;
      expect(request.method, 'POST');
      expect(request.path, '/wallet/transfer/external');
      expect(request.data, {
        'amount': 25.0,
        'toAddress': '0x1234567890abcdef1234567890abcdef12345678',
        'network': 'polygon',
        'currency': 'USDC',
      });
      expect(request.headers['X-Pin-Token'], 'pin_token_123');
      expect(request.headers['X-Idempotency-Key'], 'idem-withdraw-123');
      expect(response.transactionId, 'txn_withdraw_1');
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

    test('token refresh retries carry device security headers', () {
      final apiClientSource = File(
        'lib/services/api/api_client.dart',
      ).readAsStringSync();
      final sessionServiceSource = File(
        'lib/services/session/session_service.dart',
      ).readAsStringSync();
      final securityHeadersSource = File(
        'lib/services/security/security_headers_interceptor.dart',
      ).readAsStringSync();

      expect(
        securityHeadersSource,
        contains('Future<Map<String, String>> buildHeadersForPath'),
      );
      expect(
        securityHeadersSource,
        contains("headers['X-Device-Id']"),
        reason: 'backend device blacklist guard keys off X-Device-Id',
      );
      expect(
        securityHeadersSource,
        contains("headers['X-Device-Fingerprint']"),
      );

      for (final source in [apiClientSource, sessionServiceSource]) {
        expect(source, contains('securityHeadersInterceptorProvider'));
        expect(source, contains("buildHeadersForPath('/auth/refresh')"));
        expect(source, contains('options: Options(headers: securityHeaders)'));
      }
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

    test('expense summaries accept backend category aggregate shape', () {
      final expense = Expense.fromJson({
        'categoryId': 'transport',
        'name': 'Transport',
        'totalAmount': '42.50',
        'currency': 'USDC',
      });

      expect(expense.id, 'transport');
      expect(expense.category, 'Transport');
      expect(expense.amount, 42.5);
      expect(expense.currency, 'USDC');
      expect(expense.transactionId, isEmpty);
    });

    test(
      'transfer history uses canonical wallet transaction history',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'transactions': [],
            'total': 45,
            'limit': 20,
            'offset': 20,
            'hasMore': true,
          });
        final service = TransfersService(dio);

        final page = await service.getTransfers(page: 2, pageSize: 20);

        final request = dio.requestHistory.single;
        expect(request.path, '/wallet/transactions');
        expect(request.queryParameters, {'limit': 20, 'offset': 20});
        expect(page.page, 2);
        expect(page.totalPages, 3);
      },
    );

    test('transfer result accepts backend envelopes and id aliases', () {
      final result = TransferResult.fromJson({
        'data': {
          'transactionId': 'txn_123',
          'supportReference': 'SUP-123',
          'type': 'internal',
          'status': 'completed',
          'amountDecimal': '12.50',
          'feeDecimal': '0',
          'currency': 'USDC',
          'recipientPhone': '+2250748805663',
          'createdAt': '2026-06-04T12:00:00.000Z',
        },
      });

      expect(result.id, 'txn_123');
      expect(result.reference, 'SUP-123');
      expect(result.amount, 12.5);
      expect(result.fee, 0);
      expect(result.recipientPhone, '+2250748805663');
    });

    test('transfer page accepts nested backend envelopes', () {
      final page = TransferPage.fromJson({
        'data': {
          'transfers': [
            {
              'id': 'transfer_1',
              'reference': 'INT-TRANSFER1',
              'type': 'internal',
              'status': 'completed',
              'amount': 8,
              'fee': 0,
              'currency': 'USDC',
              'createdAt': '2026-06-04T12:00:00.000Z',
            },
          ],
          'total': '1',
          'limit': '20',
          'offset': '0',
        },
      });

      expect(page.items, hasLength(1));
      expect(page.total, 1);
      expect(page.page, 1);
      expect(page.totalPages, 1);
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

    test('notification list accepts nested paginated envelopes', () async {
      final dio = MockDio()
        ..queueResponse({
          'success': true,
          'data': {
            'items': [
              {
                'id': 'notif_nested',
                'type': 'security_alert',
                'title': 'New device',
                'body': 'A new device signed in.',
                'createdAt': '2026-06-04T10:00:00.000Z',
                'readAt': null,
              },
            ],
            'total': 1,
          },
        });
      final service = NotificationsService(dio);

      final notifications = await service.getNotifications();

      expect(dio.requestHistory.single.path, '/notifications');
      expect(notifications.single.id, 'notif_nested');
      expect(notifications.single.isRead, isFalse);
    });

    test('notification list accepts loosely typed JSON maps', () async {
      final dio = MockDio()
        ..queueResponse({
          'notifications': <Map<dynamic, dynamic>>[
            {
              'id': 'notif_loose',
              'type': 'transfer_received',
              'title': 'Payment received',
              'body': 'You received USDC.',
              'referenceType': 'transaction',
              'referenceId': 'txn_loose',
              'createdAt': '2026-06-04T10:00:00.000Z',
            },
          ],
        });
      final service = NotificationsService(dio);

      final notifications = await service.getNotifications();

      expect(notifications.single.id, 'notif_loose');
      expect(notifications.single.transactionId, 'txn_loose');
      expect(notifications.single.navigationRoute, '/transactions/txn_loose');
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

    test('notification unread count accepts alias and string counts', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': {'unread_count': '6'},
        });
      final service = NotificationsService(dio);

      final count = await service.getUnreadCount();

      expect(count, 6);
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

    test(
      'home notification badge preserves last known unread count while reloading',
      () async {
        final container = ProviderContainer(
          overrides: [
            notification_feed.lastKnownUnreadNotificationCountProvider
                .overrideWith((ref) => 5),
            notification_feed.unreadNotificationCountProvider.overrideWith((
              ref,
            ) {
              return Future<int>.delayed(const Duration(seconds: 30), () => 9);
            }),
          ],
        );
        addTearDown(container.dispose);

        expect(
          container.read(notification_count.unreadNotificationCountProvider),
          5,
        );
      },
    );

    test('notification permission provider delegates unread count to feed', () {
      final permissionProviderSource = File(
        'lib/features/notifications/providers/notification_permission_provider.dart',
      ).readAsStringSync();

      expect(permissionProviderSource, isNot(contains('sdkProvider')));
      expect(
        permissionProviderSource,
        contains('notifications.unreadNotificationCountProvider.future'),
      );
    });

    test('notifications pull refresh reloads feed and unread count', () {
      final notificationsViewSource = File(
        'lib/features/notifications/views/notifications_view.dart',
      ).readAsStringSync();
      final refreshBody = RegExp(
        r'Future<void> _refreshNotifications\(\) async \{([\s\S]*?)\n  \}',
      ).firstMatch(notificationsViewSource)!.group(1)!;

      expect(
        notificationsViewSource,
        isNot(
          contains(
            'onRefresh: () => ref.refresh(notificationsProvider.future)',
          ),
        ),
        reason:
            'pull refresh should go through the shared refresh helper so unread count stays aligned',
      );
      expect(
        RegExp(
          r'onRefresh: _refreshNotifications',
        ).allMatches(notificationsViewSource),
        hasLength(2),
      );
      expect(refreshBody, contains('refresh(notificationsProvider.future'));
      expect(
        refreshBody,
        contains('refresh(unreadNotificationCountProvider.future'),
      );
    });

    test('push token registration uses live device-token route', () async {
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

    test('runtime push lifecycle delegates through notification service', () {
      final source = File(
        'lib/services/notifications/push_notification_service.dart',
      ).readAsStringSync();

      expect(source, contains('registerFcmToken('));
      expect(source, contains('removeFcmToken('));
      expect(source, isNot(contains("'/notifications/push/token'")));
      expect(source, isNot(contains("'/notifications/push/tokens'")));
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
      'notification facade list and device-token cleanup use live backend shape',
      () async {
        final dio = MockDio()
          ..queueResponse({'notifications': [], 'total': 0})
          ..queueResponse(null, statusCode: 204);
        final api = NotificationsApi(dio);

        await api.list(page: 3, limit: 20);
        await api.unregisterDeviceToken('abc/def:ghi');

        expect(dio.requestHistory[0].method, 'GET');
        expect(dio.requestHistory[0].path, '/notifications');
        expect(dio.requestHistory[0].queryParameters, {
          'limit': 20,
          'offset': 40,
        });
        expect(dio.requestHistory[1].method, 'DELETE');
        expect(
          dio.requestHistory[1].path,
          '/notifications/device-token/abc%2Fdef%3Aghi',
        );
      },
    );

    test('notification preferences full save sends exact backend DTO keys', () {
      final preferences = UserNotificationPreferences.defaults().copyWith(
        pushEnabled: false,
        pushTransactions: false,
        pushMarketing: true,
        emailMarketing: true,
        smsTransactions: true,
        lowBalanceThreshold: 25,
      );

      expect(preferences.toUpdateJson(), {
        'pushEnabled': false,
        'pushTransactions': false,
        'pushSecurity': true,
        'pushMarketing': true,
        'emailEnabled': true,
        'emailTransactions': true,
        'emailMonthlyStatement': true,
        'emailMarketing': true,
        'smsEnabled': true,
        'smsTransactions': true,
        'smsSecurity': true,
        'largeTransactionThreshold': 1000.0,
        'lowBalanceThreshold': 25.0,
      });
    });

    test(
      'notification preference single updates preserve channel-specific intent',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'data': {
              'pushTransactions': false,
              'emailTransactions': true,
              'smsTransactions': true,
            },
          });
        final service = NotificationPreferencesApiService(dio);

        await service.updateSinglePreference(pushTransactions: false);

        expect(dio.requestHistory.single.method, 'PUT');
        expect(dio.requestHistory.single.path, '/notifications/preferences');
        expect(dio.requestHistory.single.data, {'pushTransactions': false});
      },
    );

    test(
      'notification preference threshold updates reach backend DTO',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'data': {
              'largeTransactionThreshold': 750,
              'lowBalanceThreshold': 25,
            },
          });
        final service = NotificationPreferencesApiService(dio);

        await service.updateSinglePreference(
          largeTransactionThreshold: 750,
          lowBalanceThreshold: 25,
        );

        expect(dio.requestHistory.single.method, 'PUT');
        expect(dio.requestHistory.single.path, '/notifications/preferences');
        expect(dio.requestHistory.single.data, {
          'largeTransactionThreshold': 750.0,
          'lowBalanceThreshold': 25.0,
        });
      },
    );

    test('notification newsletter interest is best-effort after save', () {
      final source = File(
        'lib/features/settings/views/notification_settings_view.dart',
      ).readAsStringSync();

      expect(source, contains('updatePreferences(_localPrefs!)'));
      expect(source, contains('unawaited('));
      expect(source, contains('_syncNewsletterInterest('));
      expect(
        source,
        contains("status: emailMarketing ? 'subscribed' : 'unsubscribed'"),
      );
      expect(source, contains("'enabled': emailMarketing"));
      expect(
        source,
        contains('do not roll back'),
        reason:
            'newsletter waitlist sync must not make saved notification settings look failed',
      );
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

    test(
      'authenticator 2FA is subscribed as backend-enforced, not local-only',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'id': 'sub_2',
            'featureKey': 'two_factor_auth',
            'source': 'settings_security',
            'status': 'subscribed',
            'metadata': {
              'requestedFeature': 'backend_enforced_mfa',
              'requiresBackendEnforcement': true,
            },
            'isActive': true,
          });
        final service = FeatureSubscriptionService(dio);

        await service.subscribe(
          const FeatureSubscriptionRequest(
            featureKey: 'two_factor_auth',
            source: 'settings_security',
            phone: '+2250748805663',
            featureName: 'Authenticator app 2FA',
            requestedFeature: 'backend_enforced_mfa',
            countryCode: 'CI',
            locale: 'fr-CI',
            platform: 'ios',
            appVersion: '1.0.0+1',
            metadata: {
              'surface': 'settings_security',
              'currentProtections': [
                'transaction_pin',
                'device_biometrics_optional',
              ],
              'requiresBackendEnforcement': true,
            },
          ),
        );

        final request = dio.requestHistory.single;
        final data = Map<String, dynamic>.from(request.data as Map);
        final metadata = Map<String, dynamic>.from(data['metadata'] as Map);
        expect(request.method, 'POST');
        expect(request.path, '/feature-subscriptions');
        expect(data['featureKey'], 'two_factor_auth');
        expect(data['source'], 'settings_security');
        expect(data['requestedFeature'], 'backend_enforced_mfa');
        expect(metadata, containsPair('requiresBackendEnforcement', true));
        expect(metadata, isNot(contains('totpSecret')));
        expect(metadata, isNot(contains('enabledLocally')));
      },
    );

    test(
      'feature subscription service accepts backend data envelope',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'data': {
              'id': 'sub_1',
              'featureKey': 'virtual_card',
              'source': 'cards_screen',
              'status': 'subscribed',
              'phone': '+2250748805663',
              'metadata': {'surface': 'cards', 'countryCode': 'CI'},
              'isActive': true,
              'createdAt': '2026-06-02T00:00:00.000Z',
              'updatedAt': '2026-06-02T00:00:00.000Z',
            },
          });
        final service = FeatureSubscriptionService(dio);

        final subscription = await service.subscribe(
          const FeatureSubscriptionRequest(
            featureKey: 'virtual_card',
            source: 'cards_screen',
            platform: 'ios',
            appVersion: '1.0.0+1',
          ),
        );

        expect(subscription.id, 'sub_1');
        expect(subscription.featureKey, 'virtual_card');
        expect(subscription.metadata?['countryCode'], 'CI');
      },
    );

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

    test('request money creates shareable backend payment links', () async {
      final dio = MockDio()
        ..queueResponse({
          'id': 'link_1',
          'shortCode': 'ABC123',
          'amount': 12.5,
          'currency': 'USDC',
          'status': 'pending',
          'shareUrl': 'https://pay.joonapay.com/p/ABC123',
          'createdAt': '2026-05-31T00:00:00.000Z',
          'expiresAt': '2026-06-30T00:00:00.000Z',
        });
      final service = PaymentLinksService(dio);

      final link = await service.createPaymentLink(
        amount: 12.5,
        currency: 'USDC',
        description: 'Lunch',
      );

      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/payment-links');
      expect(dio.requestHistory.single.data, {
        'amount': 12.5,
        'currency': 'USDC',
        'description': 'Lunch',
      });
      expect(link.url, 'https://pay.joonapay.com/p/ABC123');
    });

    test(
      'payment link provider pays backend code route with major-unit amount',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'id': 'link_1',
            'code': 'ABC123',
            'shortCode': 'ABC123',
            'creatorName': 'Awa',
            'amount': 12.5,
            'currency': 'USDC',
            'status': 'pending',
            'isExpired': false,
          })
          ..queueResponse({
            'transactionId': 'txn_1',
            'amount': 12.5,
            'status': 'completed',
          });
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(payLinkProvider.notifier);
        await notifier.loadLink('ABC123');
        notifier.state = container
            .read(payLinkProvider)
            .copyWith(
              pinToken: 'pin_token',
              idempotencyKey: 'pay-link-idempotency',
            );
        await notifier.pay();

        expect(dio.requestHistory[0].method, 'GET');
        expect(dio.requestHistory[0].path, '/payment-links/code/ABC123');
        expect(dio.requestHistory[1].method, 'POST');
        expect(dio.requestHistory[1].path, '/payment-links/code/ABC123/pay');
        expect(dio.requestHistory[1].data, {'amount': 12.5});
      },
    );

    test('QR payment link route uses major-unit amount', () async {
      final dio = MockDio()
        ..queueResponse({
          'transactionId': 'txn_qr_1',
          'amount': 12.5,
          'status': 'completed',
        });
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(qrPaymentProvider.notifier);
      notifier.state = const QrPaymentState(
        scannedData: QrPaymentData(
          type: 'paymentLink',
          paymentLinkId: 'ABC123',
        ),
        pinToken: 'pin_token',
        idempotencyKey: 'qr-idempotency',
      );
      await notifier.pay(12.5);

      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/payment-links/code/ABC123/pay');
      expect(dio.requestHistory.single.data, {'amount': 12.5});
    });

    test(
      'QR merchant payment sends raw QR data and major-unit amount',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'paymentId': 'pay_1',
            'amount': 12.5,
            'status': 'completed',
          });
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        const qrData =
            'joonapay://pay?v=1&t=static&m=merchant_1&ts=1781159000&s=sig';
        final notifier = container.read(qrPaymentProvider.notifier);
        notifier.state = const QrPaymentState(
          scannedData: QrPaymentData(
            type: 'merchant',
            merchantId: 'merchant_1',
            merchantMcc: '5812',
            merchantCategory: 'restaurant',
          ),
          rawData: qrData,
          pinToken: 'pin_token',
          idempotencyKey: 'merchant-idempotency',
        );
        await notifier.pay(12.5);

        expect(dio.requestHistory.single.method, 'POST');
        expect(dio.requestHistory.single.path, '/merchants/pay');
        expect(dio.requestHistory.single.data, {
          'qrData': qrData,
          'amount': 12.5,
          'merchantId': 'merchant_1',
          'merchantMcc': '5812',
          'merchantCategory': 'restaurant',
        });
      },
    );

    test(
      'merchant service preserves MCC in profile and receipt contracts',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'merchantId': 'merchant_1',
            'businessName': 'Cafe Abidjan SARL',
            'displayName': 'Cafe Abidjan',
            'category': 'restaurant',
            'mcc': '5812',
            'country': 'CI',
            'walletId': 'wallet_1',
            'qrCode': 'joonapay://pay?v=1&t=static&m=merchant_1',
            'isVerified': true,
            'feePercent': 1.5,
            'dailyLimit': 10000,
            'monthlyLimit': 100000,
            'dailyVolume': 125,
            'monthlyVolume': 900,
            'remainingDailyLimit': 9875,
            'remainingMonthlyLimit': 99100,
            'totalTransactions': 12,
            'status': 'active',
            'createdAt': '2026-06-14T09:00:00.000Z',
            'updatedAt': '2026-06-14T09:00:00.000Z',
          })
          ..queueResponse({
            'paymentId': 'pay_1',
            'reference': 'MP-1',
            'merchantId': 'merchant_1',
            'merchantName': 'Cafe Abidjan',
            'amount': 12.5,
            'fee': 0.19,
            'netAmount': 12.31,
            'currency': 'USDC',
            'status': 'completed',
            'createdAt': '2026-06-14T09:05:00.000Z',
            'receipt': {
              'transactionId': 'pay_1',
              'merchantName': 'Cafe Abidjan',
              'merchantCategory': 'restaurant',
              'merchantMcc': '5812',
              'amount': 12.5,
              'fee': 0.19,
              'total': 12.5,
              'timestamp': '2026-06-14T09:05:00.000Z',
              'reference': 'MP-1',
            },
          });

        final service = MerchantService(dio);
        final merchant = await service.getMyMerchant();
        final payment = await service.processPayment(
          qrData: merchant.qrCode,
          pinToken: 'pin_token',
          idempotencyKey: 'idem_merchant',
          amount: 12.5,
          merchantId: merchant.merchantId,
          merchantMcc: merchant.mcc,
          merchantCategory: merchant.category,
        );

        expect(merchant.mcc, '5812');
        expect(payment.receipt.merchantMcc, '5812');
        expect(dio.requestHistory[1].path, '/merchants/pay');
        expect(dio.requestHistory[1].data, {
          'qrData': merchant.qrCode,
          'amount': 12.5,
          'merchantId': 'merchant_1',
          'merchantMcc': '5812',
          'merchantCategory': 'restaurant',
        });
      },
    );

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

    test('auth client contract has one phone-normalizing boundary', () {
      final authServiceSource = File(
        'lib/services/auth/auth_service.dart',
      ).readAsStringSync();
      final apiProviderSource = File(
        'lib/services/api/providers/api_provider.dart',
      ).readAsStringSync();

      expect(
        File('lib/services/api/providers/auth_api.dart').existsSync(),
        isFalse,
        reason:
            'AuthService is the canonical auth API boundary; a second AuthApi can send raw phone state.',
      );
      expect(authServiceSource, contains('PhoneNormalizer.toE164'));
      expect(authServiceSource, contains("'/auth/login'"));
      expect(authServiceSource, contains("'/auth/register'"));
      expect(authServiceSource, contains("'/auth/verify-otp'"));
      expect(apiProviderSource, isNot(contains('AuthApi')));
      expect(apiProviderSource, isNot(contains('auth =')));
    });

    test('cards API uses backend verbs for freeze and unfreeze', () {
      final cardsApiSource = File(
        'lib/services/api/providers/cards_api.dart',
      ).readAsStringSync();

      expect(cardsApiSource, contains(r"_dio.put('/cards/$id/freeze'"));
      expect(cardsApiSource, contains(r"_dio.put('/cards/$id/unfreeze'"));
      expect(cardsApiSource, isNot(contains(r"_dio.post('/cards/$id/freeze'")));
      expect(
        cardsApiSource,
        isNot(contains(r"_dio.post('/cards/$id/unfreeze'")),
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

    test('transaction parsers prefer backend decimal money fields', () {
      final transaction = wallet_tx.Transaction.fromJson({
        'id': 'tx_decimal',
        'walletId': 'wallet_1',
        'type': 'deposit',
        'status': 'completed',
        'amount': 42500000,
        'amountDecimal': '42.500000',
        'fee': 1000000,
        'feeDecimal': '1.000000',
        'currency': 'USDC',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });
      final item = TransactionItem.fromJson({
        'id': 'tx_item_decimal',
        'type': 'deposit',
        'status': 'completed',
        'amount': 42500000,
        'amountDecimal': '42.500000',
        'currency': 'USDC',
        'createdAt': '2026-06-04T12:00:00.000Z',
      });

      expect(transaction.amount, 42.5);
      expect(transaction.fee, 1);
      expect(item.amount, 42.5);
    });

    test(
      'transaction parser preserves backend support and provider references',
      () {
        final transaction = wallet_tx.Transaction.fromJson({
          'id': 'tx_refs',
          'walletId': 'wallet_1',
          'type': 'deposit',
          'status': 'completed',
          'amountDecimal': '42.500000',
          'currency': 'USDC',
          'externalReference': 'yc_dep_123',
          'supportReference': 'SUP-123',
          'ledgerReference': 'blnk_tx_456',
          'providerReference': 'yc_ref_789',
          'createdAt': '2026-06-04T12:00:00.000Z',
        });

        expect(transaction.reference, 'yc_dep_123');
        expect(transaction.supportReference, 'SUP-123');
        expect(transaction.ledgerReference, 'blnk_tx_456');
        expect(transaction.providerReference, 'yc_ref_789');
      },
    );

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
          'counterpartyName': 'Awa Korido',
          'counterpartyPhone': '+2250748805663',
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
        expect(settledTransfer.counterpartyName, 'Awa Korido');
        expect(settledTransfer.counterpartyPhone, '+2250748805663');
        expect(settledTransfer.displayCounterpartyName, 'Awa Korido');
        expect(settledTransfer.displayCounterpartyPhone, '+2250748805663');
        expect(settledTransfer.recipientPhone, '+2250748805663');
        expect(failedTransfer.type, TransactionType.transferInternal);
        expect(failedTransfer.status, TransactionStatus.failed);
        expect(failedTransfer.failureReason, 'Recipient unavailable');
      },
    );

    test('transaction page parser accepts nested backend envelopes', () {
      final page = wallet_tx.TransactionPage.fromJson({
        'data': {
          'items': [
            {
              'transactionId': 'tx_nested',
              'wallet_id': 'wallet_1',
              'kind': 'internal',
              'status': 'settled',
              'amount': '42.50',
              'currency': 'USDC',
              'direction': 'credit',
              'created_at': '2026-06-04T12:00:00.000Z',
            },
          ],
          'meta': {'total': '1', 'limit': '20', 'offset': '0'},
        },
      });

      expect(page.transactions, hasLength(1));
      expect(page.total, 1);
      expect(page.page, 1);
      expect(page.pageSize, 20);
      expect(page.hasMore, isFalse);
      expect(page.transactions.single.id, 'tx_nested');
      expect(page.transactions.single.walletId, 'wallet_1');
      expect(page.transactions.single.amount, 42.5);
      expect(page.transactions.single.isCredit, isTrue);
    });

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
          ..queueResponse({
            'data': {
              'devices': [
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
                  'isActive': false,
                  'isBlocked': true,
                  'blockedReason': 'Lost phone',
                  'lastLoginAt': '2026-06-04T10:00:00.000Z',
                  'lastIpAddress': '127.0.0.1',
                  'loginCount': 4,
                  'createdAt': '2026-06-03T10:00:00.000Z',
                },
              ],
            },
          });
        final repository = DevicesRepository(dio);

        final devices = await repository.getDevices();

        expect(dio.requestHistory.single.path, '/devices');
        expect(devices.single.id, 'device_1');
        expect(devices.single.userId, 'user_1');
        expect(devices.single.deviceIdentifier, 'ios-vendor-id');
        expect(devices.single.deviceName, 'iPhone 17');
        expect(devices.single.appVersion, '1.2.3');
        expect(devices.single.isTrusted, isTrue);
        expect(devices.single.isBlocked, isTrue);
        expect(devices.single.cannotAccess, isTrue);
        expect(devices.single.blockedReason, 'Lost phone');
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
      await repository.updateFcmToken(
        deviceIdentifier: 'ios-vendor-id',
        fcmToken: 'fcm-token-2',
      );
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
      expect(dio.requestHistory[3].path, '/devices/fcm-token');
      expect(dio.requestHistory[3].data, {
        'deviceIdentifier': 'ios-vendor-id',
        'fcmToken': 'fcm-token-2',
      });
      expect(dio.requestHistory[4].method, 'POST');
      expect(dio.requestHistory[4].path, '/devices/device_1/rename');
      expect(dio.requestHistory[4].data, {'name': 'Travel iPhone'});
      expect(dio.requestHistory[5].method, 'DELETE');
      expect(dio.requestHistory[5].path, '/devices/device_1');
    });

    test(
      'session repository uses session routes and parses active sessions',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'data': {
              'sessions': [
                {
                  'id': 'session_1',
                  'userId': 'user_1',
                  'deviceId': 'device_1',
                  'ipAddress': '::ffff:10.42.0.248',
                  'userAgent': 'Korido/1.0 (iOS; iPhone17,2; 26.2)',
                  'isActive': true,
                  'lastActivityAt': '2026-06-04T10:00:00.000Z',
                  'expiresAt': '2026-07-04T10:00:00.000Z',
                  'createdAt': '2026-06-04T09:00:00.000Z',
                },
              ],
              'items': [],
              'total': 1,
            },
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
      },
    );

    test(
      'session repository accepts backend session aliases without failing screen',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'items': [
              {
                'id': 'session_alias_1',
                'device_id': 'device_alias_1',
                'user_agent': 'Korido/1.0 (Android; Pixel 9; 16)',
                'ip_address': '192.168.1.24',
                'is_active': 'true',
                'last_activity_at': '2026-06-04T11:30:00.000Z',
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

    test(
      'session repository delegates logout-all to auth token invalidation API',
      () async {
        final dio = MockDio()..queueResponse({'success': true});
        final repository = SessionsRepository(dio);

        await repository.logoutAllDevices();

        expect(dio.requestHistory, hasLength(1));
        expect(dio.requestHistory.single.method, 'POST');
        expect(dio.requestHistory.single.path, '/auth/logout-all');
        expect(dio.requestHistory.single.data, const <String, dynamic>{});
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
      'contact sync checks every saved phone number for one contact',
      () async {
        final service = ContactsService(MockSecureStorage());
        final primaryHash = service.hashPhone('+2250101010101');
        final koridoHash = service.hashPhone('+2250748805663');
        final contact = SyncedContact(
          id: 'local_1',
          name: 'Awa Local',
          phone: '+2250101010101',
          lookupPhones: const ['+2250101010101', '+2250748805663'],
        );
        final dio = MockDio()
          ..queueResponse({
            'matches': [
              {
                'phoneHash': koridoHash,
                'userId': 'user_1',
                'displayName': 'Awa Korido',
              },
            ],
          });

        final contacts = await service.getKoridoContacts(dio, [contact]);

        expect(dio.requestHistory.single.path, '/contacts/sync');
        final body = dio.requestHistory.single.data as Map<String, dynamic>;
        expect(body.keys, contains('phoneHashes'));
        expect(body['phoneHashes'], unorderedEquals([primaryHash, koridoHash]));
        expect(contacts.single.phone, '+2250101010101');
        expect(contacts.single.isKoridoUser, isTrue);
        expect(contacts.single.joonaPayUserId, 'user_1');
        expect(contacts.single.name, 'Awa Korido');
      },
    );

    test('contact sync accepts split backend contact names', () async {
      final service = ContactsService(MockSecureStorage());
      final contact = SyncedContact(
        id: 'local_1',
        name: 'Local Alias',
        phone: '+2250748805663',
      );
      final phoneHash = service.hashPhone(contact.phone);
      final dio = MockDio()
        ..queueResponse({
          'matches': [
            {
              'phoneHash': phoneHash,
              'userId': 'user_1',
              'firstName': 'Awa',
              'lastName': 'Korido',
              'username': 'awa',
            },
          ],
        });

      final contacts = await service.getKoridoContacts(dio, [contact]);

      expect(contacts.single.isKoridoUser, isTrue);
      expect(contacts.single.joonaPayUserId, 'user_1');
      expect(contacts.single.name, 'Awa Korido');
      expect(contacts.single.username, 'awa');
    });

    test('contact list sync uses the active market phone prefix', () async {
      final service = ContactsService(MockSecureStorage());
      final phoneHash = service.hashPhone(
        '(415) 555-0101',
        defaultCountryPrefix: '1',
      );
      final contact = SyncedContact(
        id: 'local_us',
        name: 'Awa US',
        phone: '(415) 555-0101',
      );
      final dio = MockDio()
        ..queueResponse({
          'matches': [
            {
              'phoneHash': phoneHash,
              'userId': 'user_us',
              'displayName': 'Awa US',
            },
          ],
        });

      final contacts = await service.getKoridoContacts(dio, [
        contact,
      ], defaultCountryPrefix: '1');

      expect(dio.requestHistory.single.path, '/contacts/sync');
      expect(dio.requestHistory.single.data, {
        'phoneHashes': [phoneHash],
      });
      expect(contacts.single.isKoridoUser, isTrue);
      expect(contacts.single.joonaPayUserId, 'user_us');
    });

    test('contact sync summary checks secondary saved phone numbers', () async {
      final service = ContactsService(MockSecureStorage());
      final primaryHash = service.hashPhone('+2250101010101');
      final koridoHash = service.hashPhone('+2250748805663');
      final contact = SyncedContact(
        id: 'local_1',
        name: 'Awa Local',
        phone: '+2250101010101',
        lookupPhones: const ['+2250101010101', '+2250748805663'],
      );
      final dio = MockDio()
        ..queueResponse({
          'matches': [
            {'phoneHash': koridoHash, 'userId': 'user_1'},
          ],
        });

      final result = await service.syncContactsWithKorido(dio, [contact]);

      expect(result.success, isTrue);
      expect(result.joonaPayUsersFound, 1);
      expect(dio.requestHistory.single.path, '/contacts/sync');
      final body = dio.requestHistory.single.data as Map<String, dynamic>;
      expect(body['phoneHashes'], unorderedEquals([primaryHash, koridoHash]));
    });

    test(
      'contact sync batches large phone books for backend max size',
      () async {
        final service = ContactsService(MockSecureStorage());
        final hashes = List.generate(
          501,
          (index) => index.toRadixString(16).padLeft(64, '0'),
        );
        final dio = MockDio()
          ..queueResponse({
            'data': {'matchesFound': 2},
          })
          ..queueResponse({
            'matches': [
              {'phoneHash': hashes.last, 'userId': 'user_last'},
            ],
          });

        final matches = await service.syncPhoneHashes(dio, hashes);

        expect(matches, 3);
        expect(dio.requestHistory, hasLength(2));
        expect(dio.requestHistory[0].path, '/contacts/sync');
        expect(
          (dio.requestHistory[0].data as Map<String, dynamic>)['phoneHashes'],
          hasLength(500),
        );
        expect(
          (dio.requestHistory[1].data as Map<String, dynamic>)['phoneHashes'],
          hasLength(1),
        );
      },
    );

    test('contacts API wrapper batches sync requests', () async {
      final hashes = List.generate(
        501,
        (index) => index.toRadixString(16).padLeft(64, '0'),
      );
      final dio = MockDio()
        ..queueResponse({'matchesFound': 0})
        ..queueResponse({'matchesFound': 0});
      final api = ContactsApi(dio);

      final responses = await api.sync(hashes);

      expect(responses, hasLength(2));
      expect(dio.requestHistory, hasLength(2));
      expect(dio.requestHistory[0].path, '/contacts/sync');
      expect(
        (dio.requestHistory[0].data as Map<String, dynamic>)['phoneHashes'],
        hasLength(500),
      );
      expect(
        (dio.requestHistory[1].data as Map<String, dynamic>)['phoneHashes'],
        hasLength(1),
      );
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
                  'koridoUserId': 'user_123',
                  'firstName': 'Awa',
                  'lastName': 'Korido',
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
      'send recipient validation uses the user market phone prefix',
      () async {
        final contactsService = ContactsService(MockSecureStorage());
        final phoneHash = contactsService.hashPhone(
          '(415) 555-0101',
          defaultCountryPrefix: '1',
        );
        final dio = MockDio()
          ..queueResponse({
            'matches': [
              {
                'phoneHash': phoneHash,
                'userId': 'user_us',
                'displayName': 'Awa US',
              },
            ],
          });
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            contactsServiceProvider.overrideWithValue(contactsService),
            userStateMachineProvider.overrideWith(
              () => _CountryUserStateMachine('US'),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(sendMoneyProvider.notifier)
            .setRecipient('(415) 555-0101');

        final body = dio.requestHistory.single.data as Map<String, dynamic>;
        expect(body['phoneHashes'], [phoneHash]);
        expect(container.read(sendMoneyProvider).recipient?.isKoridoUser, true);
        expect(container.read(sendMoneyProvider).recipient?.userId, 'user_us');
      },
    );

    test(
      'send recipient validation rejects current user before lookup',
      () async {
        final contactsService = ContactsService(MockSecureStorage());
        final dio = MockDio();
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            contactsServiceProvider.overrideWithValue(contactsService),
            userStateMachineProvider.overrideWith(
              () => _IdentityUserStateMachine(
                userId: 'user_self',
                phone: '+2250748805663',
              ),
            ),
            auth.authProvider.overrideWith(_QuietAuthNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(sendMoneyProvider.notifier)
            .setRecipient('+2250748805663');

        final state = container.read(sendMoneyProvider);
        expect(dio.requestHistory, isEmpty);
        expect(state.recipient, isNull);
        expect(state.error, 'recipient_is_current_user');
      },
    );

    test('known Korido recipient rejects current user identity', () async {
      final container = ProviderContainer(
        overrides: [
          userStateMachineProvider.overrideWith(
            () => _IdentityUserStateMachine(
              userId: 'user_self',
              phone: '+2250748805663',
            ),
          ),
          auth.authProvider.overrideWith(_QuietAuthNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(sendMoneyProvider.notifier)
          .setKnownKoridoRecipient(
            phoneNumber: '+2250700000000',
            userId: 'user_self',
            username: 'self',
            name: 'My account',
          );

      final state = container.read(sendMoneyProvider);
      expect(state.recipient, isNull);
      expect(state.error, 'recipient_is_current_user');
    });

    test(
      'known Korido recipient rejects current username case-insensitively',
      () async {
        final container = ProviderContainer(
          overrides: [
            auth.authProvider.overrideWith(_AuthWithUserNotifier.new),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(sendMoneyProvider.notifier)
            .setKnownKoridoRecipient(
              username: '@selfhandle',
              name: 'My account',
            );

        final state = container.read(sendMoneyProvider);
        expect(state.recipient, isNull);
        expect(state.error, 'recipient_is_current_user');
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
      final requestPermissionBody = RegExp(
        r'Future<bool> requestPermission\(\) async \{([\s\S]*?)\n  /// Sync device contacts',
      ).firstMatch(contactSyncProviderSource)!.group(1)!;

      expect(getDeviceContactsBody, contains('Permission.contacts.status'));
      expect(getDeviceContactsBody, isNot(contains('requestPermission')));
      expect(
        getDeviceContactsBody,
        isNot(contains('Permission.contacts.request')),
      );
      expect(
        syncContactsBody,
        contains('contactsService.hasContactsPermission'),
      );
      expect(syncContactsBody, contains('defaultCountryPrefix'));
      expect(syncContactsBody, contains('syncPhoneHashes'));
      expect(syncContactsBody, isNot(contains('await requestPermission')));
      expect(syncContactsBody, isNot(contains('Permission.contacts.request')));
      expect(syncContactsBody, isNot(contains('Permission.contacts.status')));
      expect(
        requestPermissionBody,
        contains('contactsService.requestContactsPermission'),
      );
      expect(
        requestPermissionBody,
        contains('contactsPermissionRequiresSettings'),
      );
      expect(
        requestPermissionBody,
        isNot(contains('Permission.contacts.request')),
      );
      expect(contactSyncProviderSource, isNot(contains('permission_handler')));

      final contactActionsSource = File(
        'lib/features/contacts/providers/contacts_provider.dart',
      ).readAsStringSync();
      expect(
        contactActionsSource,
        contains('defaultCountryPrefix: _defaultCountryPrefix'),
        reason:
            'manual contact sync must hash local numbers with the active market prefix',
      );

      final contactsListSource = File(
        'lib/features/contacts/views/contacts_list_screen.dart',
      ).readAsStringSync();
      expect(contactsListSource, contains('syncContacts()'));
      expect(
        contactsListSource,
        isNot(contains('_requestPermissionAndSync(showSettingsDialog: false)')),
        reason:
            'screen entry should show the permission card; the OS prompt belongs to the explicit Allow action',
      );
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

    test(
      'contact lookup keeps masked backend users selectable by id',
      () async {
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
        expect(users.single.maskedPhone, '+22507****63');
        expect(users.single.displayIdentifier, '+22507****63');
        expect(users.single.canSendInKorido, isTrue);
        expect(users.single.isKoridoUser, isTrue);
      },
    );

    test('post-transaction refresh invalidates recipient lists', () {
      final realtimeSource = File(
        'lib/services/realtime/realtime_service.dart',
      ).readAsStringSync();
      final refreshAfterTransactionBody = RegExp(
        r'void refreshAfterTransaction\(\) \{([\s\S]*?)\n  // ── WebSocket ──',
      ).firstMatch(realtimeSource)!.group(1)!;
      final invalidateRecipientProvidersBody = RegExp(
        r'void _invalidateRecipientProviders\(\) \{([\s\S]*?)\n  \}',
      ).firstMatch(realtimeSource)!.group(1)!;

      expect(
        refreshAfterTransactionBody,
        contains('_invalidateRecipientProviders'),
      );
      expect(
        invalidateRecipientProvidersBody,
        contains('wallet_recipients.savedRecipientsProvider'),
      );
      expect(
        invalidateRecipientProvidersBody,
        contains('wallet_recipients.favoriteRecipientsProvider'),
      );
      expect(
        invalidateRecipientProvidersBody,
        contains('wallet_recipients.recentRecipientsProvider'),
      );
    });
  });
}
