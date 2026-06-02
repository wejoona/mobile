import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/wallet/views/wallet_home_screen.dart';
import 'package:usdc_wallet/state/index.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Wallet Home Screen
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/wallet/views/wallet_home_screen.dart
/// Route: /home
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/wallet/wallet_home_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  Future<void> pumpWalletHomeGolden(
    WidgetTester tester, {
    required bool isDarkMode,
  }) async {
    await tester.pumpWidget(
      GoldenTestWrapper(
        isDarkMode: isDarkMode,
        overrides: [
          userStateMachineProvider.overrideWith(_GoldenUserStateMachine.new),
          walletStateMachineProvider.overrideWith(
            _GoldenWalletStateMachine.new,
          ),
          transactionStateMachineProvider.overrideWith(
            _GoldenTransactionStateMachine.new,
          ),
        ],
        child: const WalletHomeScreen(),
      ),
    );

    // WalletHomeScreen has staggered entrance animations that start from
    // delayed timers. Pump bounded frames so timers and controllers both paint.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  goldenGroup('WalletHomeScreen Golden Tests', () {
    goldenGroup('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await pumpWalletHomeGolden(tester, isDarkMode: false);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/wallet/wallet_home/initial_light.png'),
        );
      });
    });

    goldenGroup('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await pumpWalletHomeGolden(tester, isDarkMode: true);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/wallet/wallet_home/initial_dark.png'),
        );
      });
    });
  });
}

class _GoldenUserStateMachine extends UserStateMachine {
  @override
  UserState build() => const UserState(
    status: AuthStatus.authenticated,
    userId: 'user_001',
    phone: '+2250748805663',
    firstName: 'Josue',
    lastName: 'Kouakou',
    countryCode: 'CI',
    kycStatus: KycStatus.verified,
    canTransact: true,
    canWithdraw: true,
    accessToken: 'golden-token',
  );
}

class _GoldenWalletStateMachine extends WalletStateMachine {
  @override
  WalletState build() => WalletState(
    status: WalletStatus.loaded,
    walletId: 'wallet_001',
    walletAddress: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
    blockchain: 'polygon',
    usdcBalance: 2240.75,
    pendingBalance: 86.4,
    lastUpdated: DateTime(2026, 5, 27, 19, 20),
  );
}

class _GoldenTransactionStateMachine extends TransactionStateMachine {
  @override
  TransactionListState build() => TransactionListState(
    status: TransactionListStatus.loaded,
    total: 3,
    transactions: [
      Transaction(
        id: 'tx_001',
        walletId: 'wallet_001',
        type: TransactionType.deposit,
        status: TransactionStatus.completed,
        amount: 250,
        currency: 'USDC',
        description: 'Mobile Money Deposit',
        createdAt: DateTime(2026, 5, 27, 19, 11),
        completedAt: DateTime(2026, 5, 27, 19, 12),
      ),
      Transaction(
        id: 'tx_002',
        walletId: 'wallet_001',
        type: TransactionType.transferInternal,
        status: TransactionStatus.completed,
        amount: -42.5,
        currency: 'USDC',
        description: 'Dinner and transport',
        recipientPhone: '+2250711223344',
        createdAt: DateTime(2026, 5, 26, 20, 4),
        completedAt: DateTime(2026, 5, 26, 20, 5),
      ),
      Transaction(
        id: 'tx_003',
        walletId: 'wallet_001',
        type: TransactionType.transferInternal,
        status: TransactionStatus.pending,
        amount: 18,
        currency: 'USDC',
        description: 'Refund',
        createdAt: DateTime(2026, 5, 26, 9, 30),
      ),
    ],
  );
}
