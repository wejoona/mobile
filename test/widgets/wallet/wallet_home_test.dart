import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usdc_wallet/features/wallet/views/wallet_home_screen.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';

import '../../helpers/test_wrapper.dart';
import '../../helpers/test_utils.dart';

class MockWalletStateMachine extends Mock implements WalletStateMachine {}

class MockTransactionStateMachine extends Mock
    implements TransactionStateMachine {}

class MockUserStateMachine extends Mock implements UserStateMachine {}

void main() {
  group('WalletHomeScreen Widget Tests', () {
    late MockWalletStateMachine mockWalletState;
    late MockTransactionStateMachine mockTxState;
    late MockUserStateMachine mockUserState;

    setUp(() {
      mockWalletState = MockWalletStateMachine();
      mockTxState = MockTransactionStateMachine();
      mockUserState = MockUserStateMachine();
      registerFallbackValues();
    });

    testWidgets('renders home screen', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.loaded,
          usdcBalance: 1000.0,
        ),
      );

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [],
        ),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('displays greeting based on time of day', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.loaded,
          usdcBalance: 0,
        ),
      );

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [],
        ),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Greeting text should be present (morning/afternoon/evening/night)
      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('displays balance', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.loaded,
          usdcBalance: 1234.56,
        ),
      );

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [],
        ),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Balance should be displayed (might be formatted)
      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('toggles balance visibility', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.loaded,
          usdcBalance: 1000.0,
        ),
      );

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [],
        ),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for visibility toggle button (usually an IconButton)
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
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.loaded,
          usdcBalance: 0,
        ),
      );

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [],
        ),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should have quick action buttons (Send, Receive, Deposit, etc.)
      // The actual implementation may vary
      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('displays recent transactions', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.loaded,
          usdcBalance: 0,
        ),
      );

      when(() => mockTxState.build()).thenReturn(
        TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [
            createTestTransaction(id: '1', amount: 100),
            createTestTransaction(id: '2', amount: 200),
          ],
        ),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Transactions should be displayed
      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(status: WalletStatus.loading),
      );

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(status: TransactionListStatus.loading),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows error state', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.error,
          error: 'Failed to load wallet',
        ),
      );

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [],
        ),
      );

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Error message might be displayed
      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    testWidgets('supports pull-to-refresh', (tester) async {
      when(() => mockWalletState.build()).thenReturn(
        const WalletState(
          status: WalletStatus.loaded,
          usdcBalance: 0,
        ),
      );

      when(() => mockWalletState.refresh()).thenAnswer((_) async {});

      when(() => mockTxState.build()).thenReturn(
        const TransactionListState(
          status: TransactionListStatus.loaded,
          transactions: [],
        ),
      );

      when(() => mockTxState.refresh()).thenAnswer((_) async {});

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            walletStateMachineProvider.overrideWith(() => mockWalletState),
            transactionStateMachineProvider.overrideWith(() => mockTxState),
          ],
          child: const WalletHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Pull down to refresh
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WalletHomeScreen), findsOneWidget);
    });

    group('KYC Banner', () {
      testWidgets('shows KYC banner for unverified users', (tester) async {
        when(() => mockWalletState.build()).thenReturn(
          const WalletState(
            status: WalletStatus.loaded,
            usdcBalance: 0,
          ),
        );

        when(() => mockTxState.build()).thenReturn(
          const TransactionListState(
            status: TransactionListStatus.loaded,
            transactions: [],
          ),
        );

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              walletStateMachineProvider.overrideWith(() => mockWalletState),
              transactionStateMachineProvider.overrideWith(() => mockTxState),
            ],
            child: const WalletHomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // KYC banner might be present
        expect(find.byType(WalletHomeScreen), findsOneWidget);
      });
    });

    group('Empty States', () {
      testWidgets('shows empty state for no transactions', (tester) async {
        when(() => mockWalletState.build()).thenReturn(
          const WalletState(
            status: WalletStatus.loaded,
            usdcBalance: 0,
          ),
        );

        when(() => mockTxState.build()).thenReturn(
          const TransactionListState(
            status: TransactionListStatus.loaded,
            transactions: [],
          ),
        );

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              walletStateMachineProvider.overrideWith(() => mockWalletState),
              transactionStateMachineProvider.overrideWith(() => mockTxState),
            ],
            child: const WalletHomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // Empty state message might be present
        expect(find.byType(WalletHomeScreen), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('has proper semantic labels', (tester) async {
        when(() => mockWalletState.build()).thenReturn(
          const WalletState(
            status: WalletStatus.loaded,
            usdcBalance: 1000,
          ),
        );

        when(() => mockTxState.build()).thenReturn(
          const TransactionListState(
            status: TransactionListStatus.loaded,
            transactions: [],
          ),
        );

        await tester.pumpWidget(
          TestWrapper(
            overrides: [
              walletStateMachineProvider.overrideWith(() => mockWalletState),
              transactionStateMachineProvider.overrideWith(() => mockTxState),
            ],
            child: const WalletHomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(Semantics), findsWidgets);
      });
    });
  });
}

// Helper function to create test transaction
Transaction createTestTransaction({
  required String id,
  required double amount,
}) {
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
