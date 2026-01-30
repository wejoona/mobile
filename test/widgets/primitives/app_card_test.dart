import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('AppCard Widget Tests', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppCard(
            child: Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      const customPadding = EdgeInsets.all(32);

      await tester.pumpWidget(
        const TestWrapper(
          child: AppCard(
            padding: customPadding,
            child: Text('Padded'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Padding),
        ),
      );

      expect(padding.padding, customPadding);
    });

    testWidgets('applies custom margin', (tester) async {
      const customMargin = EdgeInsets.all(16);

      await tester.pumpWidget(
        const TestWrapper(
          child: AppCard(
            margin: customMargin,
            child: Text('Margin'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.margin, customMargin);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        TestWrapper(
          child: AppCard(
            onTap: () => tapped = true,
            child: const Text('Tappable'),
          ),
        ),
      );

      await tester.tap(find.byType(AppCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('applies custom border radius', (tester) async {
      const customRadius = 8.0;

      await tester.pumpWidget(
        const TestWrapper(
          child: AppCard(
            borderRadius: customRadius,
            child: Text('Radius'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(
        decoration.borderRadius,
        BorderRadius.circular(customRadius),
      );
    });

    group('Card Variants', () {
      testWidgets('renders elevated variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              variant: AppCardVariant.elevated,
              child: Text('Elevated'),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow, isNotEmpty);
      });

      testWidgets('renders goldAccent variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              variant: AppCardVariant.goldAccent,
              child: Text('Gold'),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.border, isNotNull);
        expect(
          (decoration.border as Border).top.color,
          AppColors.borderGold,
        );
      });

      testWidgets('renders subtle variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              variant: AppCardVariant.subtle,
              child: Text('Subtle'),
            ),
          ),
        );

        expect(find.text('Subtle'), findsOneWidget);
      });

      testWidgets('renders glass variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              variant: AppCardVariant.glass,
              child: Text('Glass'),
            ),
          ),
        );

        expect(find.text('Glass'), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('shows ink splash on tap', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppCard(
              onTap: () {},
              child: const Text('Splash'),
            ),
          ),
        );

        await tester.tap(find.byType(AppCard));
        await tester.pump();

        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('does not respond to tap when onTap is null', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              child: Text('No tap'),
            ),
          ),
        );

        final inkWell = tester.widget<InkWell>(find.byType(InkWell));
        expect(inkWell.onTap, isNull);
      });
    });

    group('Layout', () {
      testWidgets('uses default padding when not specified', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              child: Text('Default'),
            ),
          ),
        );

        final padding = tester.widget<Padding>(
          find.descendant(
            of: find.byType(InkWell),
            matching: find.byType(Padding),
          ),
        );

        expect(
          padding.padding,
          const EdgeInsets.all(AppSpacing.cardPadding),
        );
      });

      testWidgets('uses default border radius when not specified', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              child: Text('Default Radius'),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        expect(
          decoration.borderRadius,
          BorderRadius.circular(AppRadius.xl),
        );
      });
    });

    group('Edge Cases', () {
      testWidgets('handles complex child widget', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppCard(
              child: Column(
                children: [
                  const Text('Title'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star),
                      const SizedBox(width: 4),
                      const Text('Subtitle'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('handles zero padding', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Text('No Padding'),
            ),
          ),
        );

        final padding = tester.widget<Padding>(
          find.descendant(
            of: find.byType(InkWell),
            matching: find.byType(Padding),
          ),
        );

        expect(padding.padding, EdgeInsets.zero);
      });

      testWidgets('handles very small border radius', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppCard(
              borderRadius: 0,
              child: Text('Square'),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;

        expect(
          decoration.borderRadius,
          BorderRadius.circular(0),
        );
      });
    });
  });
}
