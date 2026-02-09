import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppButton(
            label: 'Test Button',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        TestWrapper(
          child: AppButton(
            label: 'Test Button',
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppButton(
            label: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );

      final button = find.byType(InkWell);
      expect(button, findsOneWidget);

      final inkWell = tester.widget<InkWell>(button);
      expect(inkWell.onTap, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppButton(
            label: 'Loading Button',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    group('Button Variants', () {
      testWidgets('renders primary variant with gold gradient', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Primary',
              onPressed: () {},
              variant: AppButtonVariant.primary,
            ),
          ),
        );

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.gradient, isNotNull);
        expect(decoration.boxShadow, isNotNull);
      });

      testWidgets('renders secondary variant with border', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Secondary',
              onPressed: () {},
              variant: AppButtonVariant.secondary,
            ),
          ),
        );

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.border, isNotNull);
        expect(decoration.color, Colors.transparent);
      });

      testWidgets('renders ghost variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Ghost',
              onPressed: () {},
              variant: AppButtonVariant.ghost,
            ),
          ),
        );

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, Colors.transparent);
        expect(decoration.border, isNull);
      });

      testWidgets('renders success variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Success',
              onPressed: () {},
              variant: AppButtonVariant.success,
            ),
          ),
        );

        expect(find.text('Success'), findsOneWidget);
      });

      testWidgets('renders danger variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Danger',
              onPressed: () {},
              variant: AppButtonVariant.danger,
            ),
          ),
        );

        expect(find.text('Danger'), findsOneWidget);
      });
    });

    group('Button Sizes', () {
      testWidgets('renders small button', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Small',
              onPressed: () {},
              size: AppButtonSize.small,
            ),
          ),
        );

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('renders medium button (default)', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Medium',
              onPressed: () {},
              size: AppButtonSize.medium,
            ),
          ),
        );

        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('renders large button', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Large',
              onPressed: () {},
              size: AppButtonSize.large,
            ),
          ),
        );

        expect(find.text('Large'), findsOneWidget);
      });
    });

    testWidgets('renders full-width button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppButton(
            label: 'Full Width',
            onPressed: () {},
            isFullWidth: true,
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(container.constraints!.minHeight, 48);
    });

    testWidgets('renders button with icon on left', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppButton(
            label: 'With Icon',
            onPressed: () {},
            icon: Icons.arrow_forward,
            iconPosition: IconPosition.left,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('renders button with icon on right', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppButton(
            label: 'With Icon',
            onPressed: () {},
            icon: Icons.arrow_forward,
            iconPosition: IconPosition.right,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    group('Accessibility', () {
      testWidgets('has proper semantic label', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Test Button',
              onPressed: () {},
              semanticLabel: 'Custom semantic label',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.label, contains('Custom semantic label'));
      });

      testWidgets('indicates button role in semantics', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
      });

      testWidgets('indicates enabled state in semantics', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      });

      testWidgets('indicates loading state in semantics', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Test Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.hint, contains('Loading'));
      });
    });

    group('Edge Cases', () {
      testWidgets('handles very long text with ellipsis', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'This is a very long button label that should be truncated',
              onPressed: () {},
            ),
          ),
        );

        final text = tester.widget<Text>(find.text(
          'This is a very long button label that should be truncated',
        ));

        expect(text.overflow, TextOverflow.ellipsis);
        expect(text.maxLines, 1);
      });

      testWidgets('does not respond to taps when loading', (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Loading',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        );

        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();

        expect(pressed, isFalse);
      });

      testWidgets('animates when constraints change', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Test',
              onPressed: () {},
              isFullWidth: false,
            ),
          ),
        );

        await tester.pumpWidget(
          TestWrapper(
            child: AppButton(
              label: 'Test',
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 75));
        await tester.pumpAndSettle();

        expect(find.byType(AppButton), findsOneWidget);
      });
    });
  });
}
