import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('DepositResponse contract', () {
    test('serializes legacy initiate request using backend DTO keys', () {
      const request = InitiateDepositRequest(
        amount: 5000,
        provider: 'OMCI',
        phoneNumber: '0748805663',
        currency: 'XOF',
      );

      expect(request.toJson(), {
        'amount': 5000,
        'currency': 'XOF',
        'providerCode': 'OMCI',
        'phoneNumber': '+2250748805663',
      });
      expect(request.toJson(), isNot(contains('provider')));
    });

    test('serializes wallet initiate request using backend DTO keys', () {
      const request = InitiateDepositRequest(
        amount: 5000,
        provider: 'OMCI',
        phoneNumber: '0748805663',
        currency: 'XOF',
      );

      expect(request.toWalletDepositJson(), {
        'amount': 5000,
        'sourceCurrency': 'XOF',
        'channelId': 'orange_money_ci',
      });
      expect(request.toWalletDepositJson(), isNot(contains('providerCode')));
      expect(request.toWalletDepositJson(), isNot(contains('phoneNumber')));
    });

    test('normalizes marketing provider names to backend enum codes', () {
      const request = InitiateDepositRequest(
        amount: 5000,
        provider: 'orange_money_ci',
        phoneNumber: '0748805663',
        currency: 'XOF',
      );

      expect(request.toJson()['providerCode'], 'OMCI');
      expect(normalizeDepositChannelId('OMCI'), 'orange_money_ci');
      expect(normalizeDepositChannelId('orange-money-ci'), 'orange_money_ci');
      expect(normalizeDepositProviderCode('mtn_momo'), 'MTNCI');
      expect(normalizeDepositChannelId('mtn_momo'), 'mtn_momo_ci');
      expect(normalizeDepositProviderCode('moov-money'), 'MOOVCI');
      expect(normalizeDepositChannelId('moov-money'), 'moov_money_ci');
      expect(normalizeDepositProviderCode('wave_ci'), 'WAVECI');
      expect(normalizeDepositChannelId('wave_ci'), 'wave_ci');
    });

    test('deposit service sends canonical backend initiate payload', () async {
      final dio = MockDio()
        ..queueResponse({
          'id': 'dep_123',
          'amount': 5000,
          'paymentMethodType': 'OTP',
          'status': 'INITIATED',
        }, statusCode: 201);
      final service = DepositService(dio);

      await service.initiateDeposit(
        const InitiateDepositRequest(
          amount: 5000,
          provider: 'orange_money',
          phoneNumber: '07 48 80 56 63',
          currency: 'XOF',
        ),
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/deposit');
      expect(request.data, {
        'amount': 5000,
        'sourceCurrency': 'XOF',
        'channelId': 'orange_money_ci',
      });
    });

    test('parses canonical /wallet/deposit response', () {
      final response = DepositResponse.fromJson({
        'depositId': 'dep_123',
        'transactionId': 'txn_123',
        'amount': 12000,
        'estimatedAmount': 20,
        'rate': 600,
        'sourceCurrency': 'XOF',
        'targetCurrency': 'USDC',
        'status': 'INITIATED',
        'paymentInstructions': {
          'type': 'mobile_money',
          'provider': 'orange',
          'reference': 'DEP-123',
          'instructions': 'Send 12000 XOF to the number above.',
        },
        'expiresAt': '2026-05-25T12:15:00.000Z',
      });

      expect(response.depositId, 'dep_123');
      expect(response.transactionId, 'txn_123');
      expect(response.amount, 12000);
      expect(response.convertedAmount, 20);
      expect(response.convertedCurrency, 'USDC');
      expect(response.exchangeRate, 600);
      expect(response.providerCode, 'orange');
      expect(response.paymentMethodType, PaymentMethodType.push);
      expect(response.status, DepositStatus.initiated);
      expect(response.instructions, 'Send 12000 XOF to the number above.');
    });

    test('normalizes settled and timeout statuses', () {
      expect(
        DepositResponse.fromJson({
          'id': 'dep_done',
          'amount': 1000,
          'paymentMethodType': 'PUSH',
          'status': 'settled',
        }).status,
        DepositStatus.completed,
      );

      expect(
        DepositResponse.fromJson({
          'id': 'dep_timeout',
          'amount': 1000,
          'paymentMethodType': 'PUSH',
          'status': 'TIMEOUT',
        }).status,
        DepositStatus.expired,
      );
    });
  });
}
