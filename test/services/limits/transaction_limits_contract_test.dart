import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/limits/utils/money_flow_limit_errors.dart';
import 'package:usdc_wallet/services/limits/limits_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('TransactionLimits contract', () {
    test('send validation uses backend limits instead of hard-coded caps', () {
      final source = File(
        'lib/features/send/providers/send_validation_provider.dart',
      ).readAsStringSync();

      expect(source, contains('limitHitByFor'));
      expect(source, contains('TransactionLimitOperation.send'));
      expect(source, isNot(contains('data.amount! > 10000')));
      expect(source, contains(r"RegExp(r'^\+?1\d{10}$')"));
    });

    test('send submission verifies live limits before transfer API call', () {
      final source = File(
        'lib/features/send/providers/send_provider.dart',
      ).readAsStringSync();

      expect(source, contains('limitsServiceProvider'));
      expect(source, contains('_verifySendLimitsBeforeSubmission'));
      expect(
        source.indexOf('_verifySendLimitsBeforeSubmission()'),
        lessThan(source.indexOf('createInternalTransfer(')),
      );
      expect(source, contains('limitHitByFor('));
      expect(source, contains('TransactionLimitOperation.send'));
    });

    test('deposit submission verifies live limits before deposit API call', () {
      final source = File(
        'lib/features/deposit/providers/deposit_provider.dart',
      ).readAsStringSync();

      expect(source, contains('limitsServiceProvider'));
      expect(source, contains('_verifyDepositLimitsBeforeSubmission'));
      expect(
        source.indexOf('_verifyDepositLimitsBeforeSubmission('),
        lessThan(source.indexOf('service.initiateDeposit(')),
      );
      expect(source, contains('TransactionLimitOperation.deposit'));
      expect(source, contains('moneyFlowLimitErrorFor('));
    });

    test(
      'withdraw submissions verify live limits before cash-out API call',
      () {
        final withdrawSource = File(
          'lib/features/wallet/providers/withdraw_provider.dart',
        ).readAsStringSync();
        final actionsSource = File(
          'lib/features/wallet/providers/wallet_actions_provider.dart',
        ).readAsStringSync();

        expect(withdrawSource, contains('limitsServiceProvider'));
        expect(
          withdrawSource,
          contains('_verifyWithdrawalLimitsBeforeSubmission'),
        );
        expect(
          withdrawSource.indexOf('_verifyWithdrawalLimitsBeforeSubmission('),
          lessThan(withdrawSource.indexOf('ApiEndpoints.mobileMoneyCashOut')),
        );
        expect(withdrawSource, contains('TransactionLimitOperation.withdraw'));

        expect(actionsSource, contains('limitsServiceProvider'));
        expect(actionsSource, contains('_verifyWithdrawalLimits('));
        expect(
          actionsSource.indexOf('_verifyWithdrawalLimits(amount)'),
          lessThan(actionsSource.indexOf('ApiEndpoints.mobileMoneyCashOut')),
        );
        expect(actionsSource, contains('TransactionLimitOperation.withdraw'));
      },
    );

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

    test('checks operation-specific daily caps', () {
      final limits = TransactionLimits.fromJson({
        'daily': {
          'send': {'limit': 5000, 'used': 100, 'remaining': 4900},
          'withdraw': {'limit': 1000, 'used': 900, 'remaining': 100},
          'deposit': {'limit': 2500, 'used': 2300, 'remaining': 200},
        },
        'monthly': {
          'total': {'limit': 50000, 'used': 1000, 'remaining': 49000},
        },
        'perTransaction': {'send': 2000, 'withdraw': 500},
      });

      expect(limits.limitHitByFor(TransactionLimitOperation.send, 150), isNull);
      expect(
        limits.limitHitByFor(TransactionLimitOperation.deposit, 250),
        'daily',
      );
      expect(
        limits.limitHitByFor(TransactionLimitOperation.withdraw, 600),
        'single_transaction',
      );
      expect(limits.effectiveMaxFor(TransactionLimitOperation.deposit), 200);
      expect(limits.effectiveMaxFor(TransactionLimitOperation.withdraw), 100);
    });

    test('preserves backend money-flow blocks from alias payloads', () {
      final limits = TransactionLimits.fromJson({
        'dailyLimit': 1000,
        'dailyUsed': 0,
        'monthlyLimit': 10000,
        'monthlyUsed': 0,
        'singleTransactionLimit': 500,
        'withdrawalLimit': 500,
        'permissions': {
          'can_send': 'false',
          'can_deposit': 0,
          'can_withdraw': false,
          'can_receive': 'true',
          'block_reason': 'Manual review required',
          'review_required': 'true',
        },
      });

      expect(limits.permissions.canSend, isFalse);
      expect(limits.permissions.canDeposit, isFalse);
      expect(limits.permissions.canWithdraw, isFalse);
      expect(limits.permissions.canReceive, isTrue);
      expect(limits.permissions.blockReason, 'Manual review required');
      expect(limits.permissions.reviewRequired, isTrue);
      expect(limits.effectiveMaxFor(TransactionLimitOperation.send), 0);
      expect(
        limits.limitHitByFor(TransactionLimitOperation.send, 10),
        'manual_review_required',
      );
      expect(
        limits.limitHitByFor(TransactionLimitOperation.deposit, 10),
        'manual_review_required',
      );
      expect(
        limits.limitHitByFor(TransactionLimitOperation.withdraw, 10),
        'manual_review_required',
      );
      expect(
        moneyFlowLimitErrorFor(
          'manual_review_required',
          limits,
          TransactionLimitOperation.send,
        ),
        'Manual review required',
      );
    });

    test(
      'formats operation-specific limit errors from one canonical helper',
      () {
        final limits = TransactionLimits.fromJson({
          'currency': 'USDC',
          'daily': {
            'deposit': {'limit': 100, 'used': 80},
            'withdraw': {'limit': 100, 'used': 90},
            'send': {'limit': 100, 'used': 10},
          },
          'monthly': {
            'total': {'limit': 1000, 'used': 250},
          },
          'perTransaction': {'send': 50, 'withdraw': 25},
        });

        expect(
          moneyFlowLimitErrorFor(
            'daily',
            limits,
            TransactionLimitOperation.deposit,
          ),
          'Daily remaining: 20.00 USDC',
        );
        expect(
          moneyFlowLimitErrorFor(
            'single_transaction',
            limits,
            TransactionLimitOperation.withdraw,
          ),
          'Maximum withdrawal: 25.00 USDC',
        );
      },
    );

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

  group('LimitsService contract', () {
    test('unwraps standard response envelopes for limits and usage', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'dailyLimit': 1000,
            'dailyUsed': 100,
            'monthlyLimit': 10000,
            'monthlyUsed': 750,
            'singleTransactionLimit': 500,
            'withdrawalLimit': 800,
            'kycTier': 1,
            'tierName': 'Basic',
          },
        })
        ..queueResponse({
          'data': {
            'dailyUsed': 100,
            'weeklyUsed': 200,
            'monthlyUsed': 750,
            'resetAt': '2026-06-15T00:00:00.000Z',
          },
        });
      final service = LimitsService(dio);

      final limits = await service.getLimits();
      final usage = await service.getUsage();

      expect(dio.requestHistory[0].path, '/user/limits');
      expect(dio.requestHistory[1].path, '/user/limits/usage');
      expect(limits.singleTransactionLimit, 500);
      expect(limits.dailyUsed, 100);
      expect(usage.weeklyUsed, 200);
      expect(usage.resetAt, DateTime.utc(2026, 6, 15));
    });
  });
}
