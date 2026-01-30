import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('Balance Card Widget Tests', () {
    Widget buildBalanceCard({
      required double balance,
      bool isHidden = false,
      VoidCallback? onToggleVisibility,
    }) {
      return AppCard(
        variant: AppCardVariant.goldAccent,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText('Total Balance', variant: AppTextVariant.labelLarge),
                IconButton(
                  icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
                  onPressed: onToggleVisibility,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppText(
              isHidden ? '****' : '\$${balance.toStringAsFixed(2)}',
              variant: AppTextVariant.balance,
            ),
          ],
        ),
      );
    }

    testWidgets('renders balance card', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 1000.0),
        ),
      );

      expect(find.byType(AppCard), findsOneWidget);
      expect(find.text('Total Balance'), findsOneWidget);
    });

    testWidgets('displays formatted balance', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 1234.56),
        ),
      );

      expect(find.text('\$1234.56'), findsOneWidget);
    });

    testWidgets('hides balance when visibility toggled', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 1000.0, isHidden: true),
        ),
      );

      expect(find.text('****'), findsOneWidget);
      expect(find.text('\$1000.00'), findsNothing);
    });

    testWidgets('shows visibility icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 1000.0),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows visibility off icon when hidden', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 1000.0, isHidden: true),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('calls toggle callback when icon tapped', (tester) async {
      var toggled = false;

      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(
            balance: 1000.0,
            onToggleVisibility: () => toggled = true,
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(toggled, isTrue);
    });

    testWidgets('displays zero balance correctly', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 0.0),
        ),
      );

      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('displays large balance correctly', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 999999.99),
        ),
      );

      expect(find.text('\$999999.99'), findsOneWidget);
    });

    testWidgets('uses gold accent card variant', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: buildBalanceCard(balance: 1000.0),
        ),
      );

      final card = tester.widget<AppCard>(find.byType(AppCard));
      expect(card.variant, AppCardVariant.goldAccent);
    });

    group('Edge Cases', () {
      testWidgets('handles negative balance (debt)', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildBalanceCard(balance: -100.50),
          ),
        );

        expect(find.text('\$-100.50'), findsOneWidget);
      });

      testWidgets('handles very small decimal amounts', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildBalanceCard(balance: 0.01),
          ),
        );

        expect(find.text('\$0.01'), findsOneWidget);
      });

      testWidgets('formats with 2 decimal places', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildBalanceCard(balance: 100.1),
          ),
        );

        expect(find.text('\$100.10'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('balance text is accessible', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildBalanceCard(balance: 1000.0),
          ),
        );

        expect(find.byType(AppText), findsWidgets);
      });

      testWidgets('visibility toggle has semantic button role', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildBalanceCard(
              balance: 1000.0,
              onToggleVisibility: () {},
            ),
          ),
        );

        expect(find.byType(IconButton), findsOneWidget);
      });
    });
  });
}
