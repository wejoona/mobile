import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/transactions/views/transaction_detail_view.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Transaction Detail View
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/transactions/views/transaction_detail_view.dart
/// Route: /transactions/:id
///
/// To update goldens:
/// flutter test --update-goldens test/golden/transactions/transaction_detail_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  // Sample transactions for testing
  final completedDeposit = Transaction(
    id: 'tx_001',
    walletId: 'wallet_123',
    type: TransactionType.deposit,
    status: TransactionStatus.completed,
    amount: 100.00,
    currency: 'USD',
    fee: 2.50,
    description: 'Mobile Money Deposit',
    externalReference: 'MM-2024-001',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    completedAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  final pendingTransfer = Transaction(
    id: 'tx_003',
    walletId: 'wallet_123',
    type: TransactionType.transferInternal,
    status: TransactionStatus.pending,
    amount: 200.00,
    currency: 'USD',
    fee: 2.00,
    description: 'Transfer from Bob',
    recipientPhone: '+2250712345678',
    createdAt: DateTime.now().subtract(const Duration(hours: 30)),
  );

  final failedWithdrawal = Transaction(
    id: 'tx_004',
    walletId: 'wallet_123',
    type: TransactionType.withdrawal,
    status: TransactionStatus.failed,
    amount: -75.00,
    currency: 'USD',
    fee: 1.50,
    description: 'Withdrawal to bank',
    failureReason: 'Insufficient balance',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  );

  group('TransactionDetailView Golden Tests', () {
    group('Light Mode', () {
      testWidgets('completed deposit', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await pumpGoldenTolerant(
          tester,
          GoldenTestWrapper(
            isDarkMode: false,
            child: TransactionDetailView(transaction: completedDeposit),
          ),
          pumpDuration: const Duration(milliseconds: 500),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/transactions/transaction_detail/deposit_light.png'),
        );
      });

      testWidgets('pending transfer', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await pumpGoldenTolerant(
          tester,
          GoldenTestWrapper(
            isDarkMode: false,
            child: TransactionDetailView(transaction: pendingTransfer),
          ),
          pumpDuration: const Duration(milliseconds: 500),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/transactions/transaction_detail/pending_light.png'),
        );
      });

      testWidgets('failed withdrawal', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await pumpGoldenTolerant(
          tester,
          GoldenTestWrapper(
            isDarkMode: false,
            child: TransactionDetailView(transaction: failedWithdrawal),
          ),
          pumpDuration: const Duration(milliseconds: 500),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/transactions/transaction_detail/failed_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('completed deposit', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await pumpGoldenTolerant(
          tester,
          GoldenTestWrapper(
            isDarkMode: true,
            child: TransactionDetailView(transaction: completedDeposit),
          ),
          pumpDuration: const Duration(milliseconds: 500),
        );

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/transactions/transaction_detail/deposit_dark.png'),
        );
      });
    });
  });
}
