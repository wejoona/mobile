import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/exchange_rate.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/features/deposit/models/provider_data.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('DepositService contract', () {
    test('initiateDeposit posts wallet deposit channel payload with '
        'idempotency header', () async {
      final dio = MockDio();
      dio.queueResponse(
        _initiateResponse(paymentMethodType: 'OTP'),
        statusCode: 201,
      );
      final service = DepositService(dio);

      await service.initiateDeposit(
        const InitiateDepositRequest(
          amount: 10000,
          provider: 'OMCI',
          phoneNumber: '+2250748805663',
          currency: 'XOF',
        ),
      );

      final request = dio.requestHistory.single;
      expect(request.method, 'POST');
      expect(request.path, '/wallet/deposit');
      expect(request.headers['X-Idempotency-Key'], isNotEmpty);
      expect(request.data, {
        'amount': 10000,
        'sourceCurrency': 'XOF',
        'channelId': 'orange_money_ci',
        'phoneNumber': '+2250748805663',
      });
    });

    test('initiateDeposit preserves decimal source amounts', () async {
      final dio = MockDio();
      dio.queueResponse(
        _initiateResponse(paymentMethodType: 'ACH'),
        statusCode: 201,
      );
      final service = DepositService(dio);

      await service.initiateDeposit(
        const InitiateDepositRequest(
          amount: 5.49,
          provider: 'us_ach',
          phoneNumber: '',
          currency: 'USD',
          countryCode: 'US',
        ),
        idempotencyKey: 'deposit-attempt-1',
      );

      final request = dio.requestHistory.single;
      expect(request.headers['X-Idempotency-Key'], 'deposit-attempt-1');
      expect(request.data, {
        'amount': 5.49,
        'sourceCurrency': 'USD',
        'channelId': 'us_ach',
        'countryCode': 'US',
      });
    });

    test('getExchangeRate uses wallet exchange-rate mobile alias', () async {
      final dio = MockDio();
      dio.queueResponse({
        'fromCurrency': 'XOF',
        'toCurrency': 'USD',
        'rate': 655.957,
        'timestamp': DateTime.utc(2026, 6, 2).toIso8601String(),
      });
      final service = DepositService(dio);

      await service.getExchangeRate(from: 'XOF', to: 'USD');

      final request = dio.requestHistory.single;
      expect(request.method, 'GET');
      expect(request.path, '/wallet/exchange-rate');
      expect(request.queryParameters, {
        'sourceCurrency': 'XOF',
        'targetCurrency': 'USD',
        'amount': 10000.0,
        'direction': 'buy',
      });
    });

    test(
      'listDeposits sends offset instead of unsupported page query',
      () async {
        final dio = MockDio();
        dio.queueResponse({'deposits': [], 'total': 0, 'hasMore': false});
        final service = DepositService(dio);

        await service.listDeposits(page: 3, limit: 10);

        expect(dio.requestHistory.single.queryParameters, {
          'offset': 20,
          'limit': 10,
        });
      },
    );
  });

  group('DepositNotifier flow contract', () {
    test(
      'initiate stores the typed deposit response and enters processing',
      () async {
        final dio = MockDio();
        dio.queueResponse(_limitsResponse());
        dio.queueResponse(
          _initiateResponse(paymentMethodType: 'OTP'),
          statusCode: 201,
        );
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(depositProvider.notifier);
        notifier.setAmountXOF(
          10000,
          ExchangeRate(
            fromCurrency: 'XOF',
            toCurrency: 'USD',
            rate: 655.957,
            timestamp: DateTime.utc(2026, 6, 2),
          ),
        );
        // Bank transfers do not require a phone number, so the flow can be
        // exercised without an authenticated user in the container.
        notifier.selectProviderData(
          const ProviderData(
            id: 'BANK',
            name: 'Korido Bank Rail',
            paymentMethodType: 'BANK_TRANSFER',
          ),
        );

        await notifier.initiate();

        final state = container.read(depositProvider);
        expect(state.step, DepositFlowStep.processing);
        expect(state.response?.paymentMethodType, PaymentMethodType.otp);
        expect(state.response?.token, 'tok_dep_123');
        expect(state.result?.id, 'dep_123');
        expect(state.activeDepositId, 'txn_123');
        expect(dio.requestHistory.first.path, '/user/limits');
        expect(
          dio.requestHistory.last.headers['X-Idempotency-Key'],
          isNotEmpty,
        );
      },
    );

    test(
      'back keeps unresolved deposit status instead of rewinding amount',
      () async {
        final dio = MockDio()
          ..queueResponse(_limitsResponse())
          ..queueResponse(
            _initiateResponse(paymentMethodType: 'OTP'),
            statusCode: 201,
          );
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(depositProvider.notifier)
          ..setAmountXOF(
            10000,
            ExchangeRate(
              fromCurrency: 'XOF',
              toCurrency: 'USD',
              rate: 655.957,
              timestamp: DateTime.utc(2026, 6, 2),
            ),
          )
          ..selectProviderData(
            const ProviderData(
              id: 'BANK',
              name: 'Korido Bank Rail',
              paymentMethodType: 'BANK_TRANSFER',
            ),
          );

        await notifier.initiate();
        notifier.goBack();

        final state = container.read(depositProvider);
        expect(state.step, DepositFlowStep.processing);
        expect(state.hasUnresolvedDeposit, isTrue);
        expect(state.activeDepositId, 'txn_123');
      },
    );

    test('polling session expiry surfaces unknown status', () async {
      final dio = MockDio()
        ..queueErrorResponse(statusCode: 401, message: 'Unauthorized');
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(depositProvider.notifier);
      notifier.hydrateFromResponse(
        DepositResponse.fromJson(_initiateResponse(paymentMethodType: 'PUSH')),
      );

      await notifier.checkStatus();

      final state = container.read(depositProvider);
      expect(state.step, DepositFlowStep.statusUnknown);
      expect(state.error, contains('session expired'));
      expect(state.activeDepositId, 'txn_123');
    });

    test('instructions back sends unresolved deposits to status route', () {
      final source = File(
        'lib/features/deposit/views/payment_instructions_screen.dart',
      ).readAsStringSync();

      expect(source, contains('state.hasUnresolvedDeposit'));
      expect(source, contains("context.fsmGo('/deposit/status')"));
      expect(
        source,
        contains("context.fsmSafePop(fallbackRoute: '/deposit/provider')"),
      );
    });

    test(
      'initiate blocks mobile-money deposits without a phone number',
      () async {
        final dio = MockDio();
        final container = ProviderContainer(
          overrides: [dioProvider.overrideWithValue(dio)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(depositProvider.notifier);
        notifier.setAmountXOF(10000);
        notifier.selectProviderData(
          const ProviderData(
            id: 'OMCI',
            name: 'Orange Money',
            paymentMethodType: 'OTP',
          ),
        );

        await notifier.initiate();

        final state = container.read(depositProvider);
        expect(state.step, DepositFlowStep.failed);
        expect(state.error, contains('Phone number'));
        expect(dio.requestHistory, isEmpty);
      },
    );

    test('initiate blocks when backend limits disallow deposits', () async {
      final dio = MockDio();
      dio.queueResponse({
        ..._limitsResponse(),
        'permissions': {
          'can_deposit': false,
          'review_required': true,
          'block_reason': 'Manual review required',
        },
      });
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(depositProvider.notifier);
      notifier.setAmountXOF(
        10000,
        ExchangeRate(
          fromCurrency: 'XOF',
          toCurrency: 'USD',
          rate: 655.957,
          timestamp: DateTime.utc(2026, 6, 2),
        ),
      );
      notifier.selectProviderData(
        const ProviderData(
          id: 'BANK',
          name: 'Korido Bank Rail',
          paymentMethodType: 'BANK_TRANSFER',
        ),
      );

      await notifier.initiate();

      final state = container.read(depositProvider);
      expect(state.step, DepositFlowStep.failed);
      expect(state.error, 'Manual review required');
      expect(dio.requestHistory, hasLength(1));
      expect(dio.requestHistory.single.path, '/user/limits');
    });

    test('retries the same deposit attempt with one idempotency key', () async {
      final dio = MockDio();
      dio.queueResponse(_limitsResponse());
      dio.queueErrorResponse(statusCode: 504, message: 'Gateway timeout');
      dio.queueResponse(_limitsResponse());
      dio.queueResponse(
        _initiateResponse(paymentMethodType: 'ACH'),
        statusCode: 201,
      );
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(depositProvider.notifier);
      notifier.setAmountUSD(
        5.49,
        ExchangeRate(
          fromCurrency: 'XOF',
          toCurrency: 'USD',
          rate: 655.957,
          timestamp: DateTime.utc(2026, 6, 2),
        ),
        'US',
      );
      notifier.selectProviderData(
        const ProviderData(
          id: 'us_ach',
          name: 'ACH transfer',
          paymentMethodType: 'ACH',
        ),
      );

      await notifier.initiate();
      await notifier.initiate();

      final postRequests = dio.requestHistory
          .where((request) => request.method == 'POST')
          .toList();
      expect(postRequests, hasLength(2));
      expect(
        postRequests.first.headers['X-Idempotency-Key'],
        postRequests.last.headers['X-Idempotency-Key'],
      );
      expect(postRequests.last.data, {
        'amount': 5.49,
        'sourceCurrency': 'USD',
        'channelId': 'us_ach',
        'countryCode': 'US',
      });
    });
  });
}

Map<String, dynamic> _limitsResponse() {
  return {
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
    'tier': 'verified',
    'permissions': {
      'can_send': true,
      'can_deposit': true,
      'can_withdraw': true,
      'can_receive': true,
      'review_required': false,
      'block_reason': null,
    },
  };
}

Map<String, dynamic> _initiateResponse({required String paymentMethodType}) {
  return {
    'transactionId': 'txn_123',
    'depositId': 'dep_123',
    'token': 'tok_dep_123',
    'paymentMethodType': paymentMethodType,
    'instructions': 'Dial #144*82# and enter the OTP in Korido.',
    'expiresAt': DateTime.utc(2026, 6, 2, 0, 15).toIso8601String(),
    'amount': 10000,
    'currency': 'XOF',
    'providerCode': 'OMCI',
    'status': 'pending_otp',
  };
}
