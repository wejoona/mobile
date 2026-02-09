import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/composed/balance_card.dart';

import '../helpers/test_wrapper.dart';

/// Golden/Snapshot tests for BalanceCard component
/// Ensures visual consistency for wallet balance display
///
/// To update goldens: flutter test --update-goldens test/snapshots/balance_card_snapshot_test.dart
void main() {
  setUpAll(() { GoogleFonts.config.allowRuntimeFetching = false; });
  group('BalanceCard Snapshot Tests', () {
    group('Basic States', () {
      testWidgets('default balance card', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1234.56,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/default.png'),
        );
      });

      testWidgets('loading state', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BalanceCard(
                balance: 0,
                currency: 'USD',
                isLoading: true,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/loading.png'),
        );
      });

      testWidgets('zero balance', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 0.00,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/zero_balance.png'),
        );
      });
    });

    group('Balance Amounts', () {
      testWidgets('small balance', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 25.99,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/small_balance.png'),
        );
      });

      testWidgets('medium balance', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 5432.10,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/medium_balance.png'),
        );
      });

      testWidgets('large balance', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 123456.78,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/large_balance.png'),
        );
      });

      testWidgets('very large balance', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 9876543.21,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/very_large_balance.png'),
        );
      });
    });

    group('Change Indicators', () {
      testWidgets('positive change', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1500.00,
                currency: 'USD',
                changePercent: 12.5,
                changeAmount: 166.67,
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/positive_change.png'),
        );
      });

      testWidgets('negative change', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1200.00,
                currency: 'USD',
                changePercent: -8.3,
                changeAmount: -108.70,
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/negative_change.png'),
        );
      });

      testWidgets('zero change', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1000.00,
                currency: 'USD',
                changePercent: 0.0,
                changeAmount: 0.0,
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/zero_change.png'),
        );
      });

      testWidgets('large positive change', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 5000.00,
                currency: 'USD',
                changePercent: 45.2,
                changeAmount: 1555.56,
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/large_positive_change.png'),
        );
      });

      testWidgets('small percentage change', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1000.00,
                currency: 'USD',
                changePercent: 0.5,
                changeAmount: 5.00,
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/small_change.png'),
        );
      });
    });

    group('Different Currencies', () {
      testWidgets('XOF currency', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 650000.00,
                currency: 'XOF',
                changePercent: 5.0,
                changeAmount: 30952.38,
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/xof_currency.png'),
        );
      });

      testWidgets('EUR currency', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 950.50,
                currency: 'EUR',
                changePercent: 3.2,
                changeAmount: 29.50,
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/eur_currency.png'),
        );
      });
    });

    group('Action Buttons', () {
      testWidgets('with deposit button', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1234.56,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/with_deposit_button.png'),
        );
      });

      testWidgets('without action button', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1234.56,
                currency: 'USD',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/no_button.png'),
        );
      });

      testWidgets('with deposit and withdraw buttons', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1234.56,
                currency: 'USD',
                onDepositTap: () {},
                onWithdrawTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/with_both_buttons.png'),
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('balance with many decimals', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1234.999999,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/many_decimals.png'),
        );
      });

      testWidgets('very small balance', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 0.01,
                currency: 'USD',
                onDepositTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/very_small_balance.png'),
        );
      });

      testWidgets('balance with loading and change indicators', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: 1234.56,
                currency: 'USD',
                changePercent: 5.0,
                changeAmount: 60.00,
                isLoading: true,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/loading_with_change.png'),
        );
      });
    });

    group('Responsive Layout', () {
      testWidgets('full width on mobile', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: SizedBox(
              width: 375, // iPhone width
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BalanceCard(
                  balance: 1234.56,
                  currency: 'USD',
                  changePercent: 5.0,
                  changeAmount: 60.00,
                  onDepositTap: () {},
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/mobile_width.png'),
        );
      });

      testWidgets('constrained width', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceCard(
                    balance: 1234.56,
                    currency: 'USD',
                    changePercent: 5.0,
                    changeAmount: 60.00,
                    onDepositTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(BalanceCard),
          matchesGoldenFile('goldens/balance_card/constrained_width.png'),
        );
      });
    });
  });
}
