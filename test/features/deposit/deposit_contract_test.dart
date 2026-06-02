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
    test(
      'initiateDeposit posts to /deposits/initiate with idempotency header',
      () async {
        final dio = MockDio();
        dio.queueResponse(
          _initiateResponse(paymentMethodType: 'OTP'),
          statusCode: 201,
        );
        final service = DepositService(dio);

        await service.initiateDeposit(
          const InitiateDepositRequest(amount: 10000, providerCode: 'OMCI'),
        );

        final request = dio.requestHistory.single;
        expect(request.method, 'POST');
        expect(request.path, '/deposits/initiate');
        expect(
          request.headers['X-Idempotency-Key'],
          startsWith('deposit-initiate-'),
        );
        expect(request.data, {
          'amount': 10000,
          'currency': 'XOF',
          'providerCode': 'OMCI',
        });
      },
    );

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
      'initiateDeposit stores instruction response for the screen',
      () async {
        final dio = MockDio();
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
        notifier.selectProviderData(
          const ProviderData(
            id: 'OMCI',
            name: 'Orange Money',
            paymentMethodType: 'OTP',
          ),
        );

        await notifier.initiateDeposit();

        final state = container.read(depositProvider);
        expect(state.step, DepositFlowStep.instructions);
        expect(state.response?['paymentMethodType'], PaymentMethodType.otp);
        expect(state.response?['token'], 'tok_dep_123');
        expect(state.result?.id, 'dep_123');
        expect(
          dio.requestHistory.single.headers['X-Idempotency-Key'],
          startsWith('deposit-initiate-'),
        );
      },
    );

    test('confirmDeposit posts OTP to /deposits/confirm', () async {
      final dio = MockDio();
      dio
        ..queueResponse(
          _initiateResponse(paymentMethodType: 'OTP'),
          statusCode: 201,
        )
        ..queueResponse({
          'id': 'dep_123',
          'status': 'completed',
          'amount': 10000,
          'currency': 'XOF',
          'providerCode': 'OMCI',
          'paymentMethodType': 'OTP',
          'createdAt': DateTime.utc(2026, 6, 2).toIso8601String(),
          'completedAt': DateTime.utc(2026, 6, 2, 0, 1).toIso8601String(),
        });
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
      await notifier.initiateDeposit();
      notifier.setOtp('123456');
      await notifier.confirmDeposit();

      final confirmRequest = dio.requestHistory.last;
      expect(confirmRequest.method, 'POST');
      expect(confirmRequest.path, '/deposits/confirm');
      expect(confirmRequest.data, {'token': 'tok_dep_123', 'otp': '123456'});
      expect(container.read(depositProvider).step, DepositFlowStep.completed);
    });
  });
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
