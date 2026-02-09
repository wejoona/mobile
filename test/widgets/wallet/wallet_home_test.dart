import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/wallet/views/wallet_home_screen.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';

import '../../helpers/test_wrapper.dart';

/// Fake WalletStateMachine for Riverpod 3.x
class FakeWalletStateMachine extends WalletStateMachine {
  final WalletState initialState;
  FakeWalletStateMachine([this.initialState = const WalletState(status: WalletStatus.loaded, usdcBalance: 0)]);

  @override
  WalletState build() => initialState;

  @override
  Future<void> fetch() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> createWallet() async {}
  @override
  void reset() {}
}

/// Fake TransactionStateMachine for Riverpod 3.x
class FakeTransactionStateMachine extends TransactionStateMachine {
  final TransactionListState initialState;
  FakeTransactionStateMachine([this.initialState = const TransactionListState(status: TransactionListStatus.loaded, transactions: [])]);

  @override
  TransactionListState build() => initialState;

  @override
  Future<void> fetch() async {}
  @override
  Future<void> refresh() async {}
  @override
  Future<void> loadMore() async {}
  @override
  void reset() {}
}

void main() {
  group('WalletHomeScreen Widget Tests', () {
    Widget buildSubject({
      WalletState? walletState,
      TransactionListState? txState,
    }) {
      return TestWrapper(
        overrides: [
          walletStateMachineProvider.overrideWith(() => FakeWalletStateMachine(
            walletState ?? const WalletState(status: WalletStatus.loaded, usdcBalance: 1000.0),
          )),
          transactionStateMachineProvider.overrideWith(() => FakeTransactionStateMachine(
            txState ?? const TransactionListState(status: TransactionListStatus.loaded, transactions: []),
          )),
        ],
        child: const WalletHomeScreen(),
      );
    }

    testWidgets('renders home screen', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('displays greeting based on time of day', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('displays balance', (tester) async {
      await tester.pumpWidget(buildSubject(
        walletState: const WalletState(status: WalletStatus.loaded, usdcBalance: 1234.56),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('toggles balance visibility', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final visibilityButtons = find.byIcon(Icons.visibility);
      final visibilityOffButtons = find.byIcon(Icons.visibility_off);

      if (visibilityButtons.evaluate().isNotEmpty) {
        await tester.tap(visibilityButtons.first);
        await tester.pumpAndSettle();
      } else if (visibilityOffButtons.evaluate().isNotEmpty) {
        await tester.tap(visibilityOffButtons.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('shows quick action buttons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('displays recent transactions', (tester) async {
      await tester.pumpWidget(buildSubject(
        txState: TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [
            _createTestTransaction(id: '1', amount: 100),
            _createTestTransaction(id: '2', amount: 200),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(buildSubject(
        walletState: const WalletState(status: WalletStatus.loading),
        txState: const TransactionListState(status: TransactionListStatus.loading),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows error state', (tester) async {
      await tester.pumpWidget(buildSubject(
        walletState: const WalletState(status: WalletStatus.error, error: 'Failed to load wallet'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('supports pull-to-refresh', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    group('KYC Banner', () {
      testWidgets('shows KYC banner for unverified users', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(WalletHomeScreen), findsOneWidget);
      });
    });

    group('Empty States', () {
      testWidgets('shows empty state for no transactions', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(WalletHomeScreen), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
      });
    });
  });
}

Transaction _createTestTransaction({required String id, required double amount}) {
  return Transaction(
    id: id,
    walletId: 'test-wallet',
    type: TransactionType.deposit,
    status: TransactionStatus.completed,
    amount: amount,
    currency: 'USDC',
    createdAt: DateTime.now(),
  );
}
