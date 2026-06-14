import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';

void main() {
  group('TransactionLimits contract', () {
    test('parses live nested /user/limits response', () {
      final limits = TransactionLimits.fromJson({
        'tier': 'verified',
        'kycStatus': 'manual_review',
        'daily': {
          'send': {'limit': 5000, 'used': 1250, 'remaining': 3750},
          'withdraw': {'limit': 5000, 'used': 200, 'remaining': 4800},
          'deposit': {'limit': 5000, 'used': 300, 'remaining': 4700},
        },
        'monthly': {
          'total': {'limit': 50000, 'used': 6200, 'remaining': 43800},
          'international': {'limit': 50000, 'used': 0, 'remaining': 50000},
        },
        'perTransaction': {'send': 2500, 'withdraw': 2500},
        'upgradeMessage': 'Manual review in progress',
        'overrideActive': true,
        'overrideReason': 'Pilot approval',
        'overrideExpiresAt': '2026-07-01T00:00:00.000Z',
      });

      expect(limits.kycTier, 2);
      expect(limits.tierName, 'Verified');
      expect(limits.kycStatus, 'manual_review');
      expect(limits.dailyLimit, 5000);
      expect(limits.dailyUsed, 1250);
      expect(limits.monthlyLimit, 50000);
      expect(limits.monthlyUsed, 6200);
      expect(limits.singleTransactionLimit, 2500);
      expect(limits.singleTransactionMax, 2500);
      expect(limits.withdrawalLimit, 2500);
      expect(limits.dailyRemaining, 3750);
      expect(limits.monthlyRemaining, 43800);
      expect(limits.overrideActive, isTrue);
      expect(limits.overrideReason, 'Pilot approval');
      expect(limits.overrideExpiresAt, DateTime.utc(2026, 7));
    });

    test('keeps flat /wallet/limits and mock payload compatibility', () {
      final limits = TransactionLimits.fromJson({
        'dailyLimit': 1000,
        'dailyUsed': 100,
        'monthlyLimit': 10000,
        'monthlyUsed': 750,
        'singleTransactionLimit': 500,
        'withdrawalLimit': 800,
        'kycTier': 1,
        'tierName': 'Basic',
      });

      expect(limits.dailyLimit, 1000);
      expect(limits.dailyUsed, 100);
      expect(limits.monthlyLimit, 10000);
      expect(limits.monthlyUsed, 750);
      expect(limits.singleTransactionLimit, 500);
      expect(limits.singleTransactionMax, 500);
      expect(limits.withdrawalLimit, 800);
      expect(limits.kycTier, 1);
      expect(limits.tierName, 'Basic');
    });
  });
}
