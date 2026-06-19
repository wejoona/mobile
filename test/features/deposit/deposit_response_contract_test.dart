import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/domain/entities/wallet.dart';
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
        'phoneNumber': '+2250748805663',
      });
      expect(request.toWalletDepositJson(), isNot(contains('providerCode')));
    });

    test('deposit request normalizes duplicated country prefixes', () {
      const request = InitiateDepositRequest(
        amount: 5000,
        provider: 'OMCI',
        phoneNumber: '+225+2250748805663',
        currency: 'XOF',
      );

      expect(request.toWalletDepositJson()['phoneNumber'], '+2250748805663');
    });

    test(
      'deposit request uses country for phone normalization without posting it',
      () {
        const request = InitiateDepositRequest(
          amount: 5000,
          provider: 'orange_money_sn',
          phoneNumber: '77 123 45 67',
          currency: 'XOF',
          countryCode: 'SN',
        );

        expect(request.toWalletDepositJson(), {
          'amount': 5000,
          'sourceCurrency': 'XOF',
          'channelId': 'orange_money_sn',
          'phoneNumber': '+221771234567',
        });
      },
    );

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
      expect(normalizeDepositChannelId('mobile_money'), 'mobile_money');
      expect(
        depositChannelIdFromJson({'id': 'us_ach', 'code': 'ACH'}),
        'us_ach',
      );
      expect(depositChannelIdFromJson({'code': 'OMCI'}), 'orange_money_ci');
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
          countryCode: 'CI',
        ),
      );

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/deposit');
      expect(request.data, {
        'amount': 5000,
        'sourceCurrency': 'XOF',
        'channelId': 'orange_money_ci',
        'phoneNumber': '+2250748805663',
      });
    });

    test('preserves unavailable deposit capability metadata', () async {
      final dio = MockDio()
        ..queueResponse({
          'country': 'CI',
          'currency': null,
          'status': 'unavailable',
          'reason': 'no_deposit_channels_available',
          'retryable': false,
          'supportReviewRequired': true,
          'channels': <Map<String, dynamic>>[],
        });
      final service = DepositService(dio);

      final availability = await service.getProvidersAvailability();

      final request = dio.requestHistory.single;
      expect(request.path, '/wallet/deposit/channels');
      expect(availability.providers, isEmpty);
      expect(availability.country, 'CI');
      expect(availability.status, 'unavailable');
      expect(availability.reason, 'no_deposit_channels_available');
      expect(availability.retryable, isFalse);
      expect(availability.supportReviewRequired, isTrue);
    });

    test(
      'parses available deposit channels from capability response',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'country': 'US',
            'currency': 'USD',
            'status': 'available',
            'channels': [
              {
                'id': 'us_ach',
                'name': 'ACH transfer',
                'paymentMethodType': 'ACH',
              },
            ],
          });
        final service = DepositService(dio);

        final availability = await service.getProvidersAvailability();

        expect(availability.country, 'US');
        expect(availability.status, 'available');
        expect(availability.providers.single['id'], 'us_ach');
      },
    );

    test('formats deposit channel fees using backend fee type', () {
      final percentage = DepositChannel.fromJson({
        'id': 'orange_money_ci',
        'name': 'Orange Money',
        'fee': 1.5,
        'feeType': 'percentage',
        'currency': 'XOF',
      });
      final fixed = DepositChannel.fromJson({
        'id': 'ach',
        'name': 'ACH',
        'fee': 250,
        'feeType': 'fixed',
        'currency': 'XOF',
      });
      final free = DepositChannel.fromJson({
        'id': 'bank',
        'name': 'Bank',
        'fee': 0,
        'feeType': 'fixed',
        'currency': 'USD',
      });

      expect(percentage.feeLabel, '1.5% fee');
      expect(fixed.feeLabel, '250 XOF fee');
      expect(free.feeLabel, 'Free');
    });

    test(
      'requests deposit channels with region and currency context',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'country': 'US',
            'currency': 'USD',
            'status': 'available',
            'channels': <Map<String, dynamic>>[],
          });
        final service = DepositService(dio);

        await service.getProvidersAvailability(
          countryCode: 'US',
          currency: 'USD',
        );

        final request = dio.requestHistory.single;
        expect(request.path, '/wallet/deposit/channels');
        expect(request.queryParameters, {'country': 'US', 'currency': 'USD'});
      },
    );

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
