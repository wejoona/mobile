import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_request.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';

void main() {
  group('DepositResponse contract', () {
    test('serializes initiate request using backend DTO keys', () {
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

    test('parses canonical /deposits/initiate response', () {
      final response = DepositResponse.fromJson({
        'id': 'dep_123',
        'amount': 12000,
        'usdcAmount': 20,
        'exchangeRate': 600,
        'provider': 'OMCI',
        'paymentMethodType': 'OTP',
        'status': 'INITIATED',
        'token': 'deposit-token',
        'instructions': 'Dial #144# and confirm the payment.',
        'createdAt': '2026-05-25T12:00:00.000Z',
      });

      expect(response.depositId, 'dep_123');
      expect(response.amount, 12000);
      expect(response.convertedAmount, 20);
      expect(response.convertedCurrency, 'USDC');
      expect(response.exchangeRate, 600);
      expect(response.providerCode, 'OMCI');
      expect(response.paymentMethodType, PaymentMethodType.otp);
      expect(response.status, DepositStatus.initiated);
      expect(response.token, 'deposit-token');
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
