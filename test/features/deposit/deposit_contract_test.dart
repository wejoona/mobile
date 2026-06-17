import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
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
        expect(dio.requestHistory.first.path, '/user/limits');
        expect(
          dio.requestHistory.last.headers['X-Idempotency-Key'],
          isNotEmpty,
        );
      },
    );

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
  };
}

Map<String, dynamic> _initiateResponse({required String paymentMethodType}) {
  return {
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
