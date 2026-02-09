import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('AppText Widget Tests', () {
    testWidgets('renders text content', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppText('Hello World'),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppText(
            'Colored Text',
            color: Colors.red,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Colored Text'));
      expect(text.style?.color, Colors.red);
    });

    testWidgets('applies custom font weight', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppText(
            'Bold Text',
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Bold Text'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('applies text align', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppText(
            'Centered',
            textAlign: TextAlign.center,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Centered'));
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('respects max lines', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppText(
            'Multi-line text',
            maxLines: 2,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Multi-line text'));
      expect(text.maxLines, 2);
    });

    testWidgets('applies overflow style', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AppText(
            'Overflow text',
            overflow: TextOverflow.fade,
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Overflow text'));
      expect(text.overflow, TextOverflow.fade);
    });

    group('Text Variants', () {
      testWidgets('renders displayLarge variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              'Display Large',
              variant: AppTextVariant.displayLarge,
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Display Large'));
        expect(text.style?.fontSize, AppTypography.displayLarge.fontSize);
      });

      testWidgets('renders headlineMedium variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              'Headline',
              variant: AppTextVariant.headlineMedium,
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Headline'));
        expect(text.style?.fontSize, AppTypography.headlineMedium.fontSize);
      });

      testWidgets('renders bodyMedium variant (default)', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText('Body'),
          ),
        );

        final text = tester.widget<Text>(find.text('Body'));
        expect(text.style?.fontSize, AppTypography.bodyMedium.fontSize);
      });

      testWidgets('renders labelSmall variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              'Label',
              variant: AppTextVariant.labelSmall,
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Label'));
        expect(text.style?.fontSize, AppTypography.labelSmall.fontSize);
      });

      testWidgets('renders balance variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              '1,000.00',
              variant: AppTextVariant.balance,
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('1,000.00'));
        expect(text.style?.fontSize, AppTypography.balanceDisplay.fontSize);
      });

      testWidgets('renders monoLarge variant', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              '0x1234',
              variant: AppTextVariant.monoLarge,
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('0x1234'));
        expect(text.style?.fontFamily, AppTypography.monoLarge.fontFamily);
      });
    });

    group('Accessibility', () {
      testWidgets('uses custom semantic label when provided', (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      addTearDown(semanticsHandle.dispose);

        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              '\$1,000',
              semanticLabel: 'One thousand dollars',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('\$1,000'));
        expect(semantics.label, 'One thousand dollars');
      });

      testWidgets('excludes from semantics when requested', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              'Decorative text',
              excludeSemantics: true,
            ),
          ),
        );

        expect(find.byType(ExcludeSemantics), findsWidgets);
      });

      testWidgets('uses text as semantic label by default', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText('Default label'),
          ),
        );

        expect(find.text('Default label'), findsOneWidget);
      });
    });

    group('Custom Styles', () {
      testWidgets('merges custom style with variant', (tester) async {
        const customStyle = TextStyle(
          fontSize: 100,
          letterSpacing: 2.0,
        );

        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              'Custom',
              style: customStyle,
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Custom'));
        expect(text.style?.fontSize, 100);
        expect(text.style?.letterSpacing, 2.0);
      });

      testWidgets('custom color overrides variant color', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(
              'Custom Color',
              variant: AppTextVariant.headlineLarge,
              color: Colors.green,
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Custom Color'));
        expect(text.style?.color, Colors.green);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles empty string', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(''),
          ),
        );

        expect(find.byType(AppText), findsOneWidget);
      });

      testWidgets('handles very long text', (tester) async {
        const longText = 'This is a very long text that might wrap across '
            'multiple lines depending on the available space in the widget '
            'and the font size being used for rendering';

        await tester.pumpWidget(
          const TestWrapper(
            child: AppText(longText),
          ),
        );

        expect(find.text(longText), findsOneWidget);
      });

      testWidgets('handles special characters', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText('Special: @#\$%^&*()'),
          ),
        );

        expect(find.text('Special: @#\$%^&*()'), findsOneWidget);
      });

      testWidgets('handles unicode characters', (tester) async {
        await tester.pumpWidget(
          const TestWrapper(
            child: AppText('Français: Côte d\'Ivoire 🇨🇮'),
          ),
        );

        expect(find.text('Français: Côte d\'Ivoire 🇨🇮'), findsOneWidget);
      });
    });
  });
}
