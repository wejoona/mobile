import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/theme/app_theme.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';

void main() {
  group('AppText Theme Adaptation Tests', () {
    testWidgets('uses primary text color in dark theme by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText('Test', variant: AppTextVariant.bodyLarge),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test'));
      expect(textWidget.style?.color, AppColors.textPrimary);
    });

    testWidgets('uses primary text color in light theme by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppText('Test', variant: AppTextVariant.bodyLarge),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test'));
      expect(textWidget.style?.color, AppColorsLight.textPrimary);
    });

    testWidgets('semantic colors adapt to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Column(
              children: [
                AppText('Primary', semanticColor: AppTextColor.primary),
                AppText('Secondary', semanticColor: AppTextColor.secondary),
                AppText('Tertiary', semanticColor: AppTextColor.tertiary),
                AppText('Error', semanticColor: AppTextColor.error),
                AppText('Success', semanticColor: AppTextColor.success),
                AppText('Warning', semanticColor: AppTextColor.warning),
                AppText('Link', semanticColor: AppTextColor.link),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.text('Primary')).style?.color,
        AppColors.textPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Secondary')).style?.color,
        AppColors.textSecondary,
      );
      expect(
        tester.widget<Text>(find.text('Tertiary')).style?.color,
        AppColors.textTertiary,
      );
      expect(
        tester.widget<Text>(find.text('Error')).style?.color,
        AppColors.errorText,
      );
      expect(
        tester.widget<Text>(find.text('Success')).style?.color,
        AppColors.successText,
      );
      expect(
        tester.widget<Text>(find.text('Warning')).style?.color,
        AppColors.warningText,
      );
      expect(
        tester.widget<Text>(find.text('Link')).style?.color,
        AppColors.gold500,
      );
    });

    testWidgets('semantic colors adapt to light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                AppText('Primary', semanticColor: AppTextColor.primary),
                AppText('Secondary', semanticColor: AppTextColor.secondary),
                AppText('Tertiary', semanticColor: AppTextColor.tertiary),
                AppText('Error', semanticColor: AppTextColor.error),
                AppText('Success', semanticColor: AppTextColor.success),
                AppText('Warning', semanticColor: AppTextColor.warning),
                AppText('Link', semanticColor: AppTextColor.link),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.text('Primary')).style?.color,
        AppColorsLight.textPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Secondary')).style?.color,
        AppColorsLight.textSecondary,
      );
      expect(
        tester.widget<Text>(find.text('Tertiary')).style?.color,
        AppColorsLight.textTertiary,
      );
      expect(
        tester.widget<Text>(find.text('Error')).style?.color,
        AppColorsLight.errorText,
      );
      expect(
        tester.widget<Text>(find.text('Success')).style?.color,
        AppColorsLight.successText,
      );
      expect(
        tester.widget<Text>(find.text('Warning')).style?.color,
        AppColorsLight.warningText,
      );
      expect(
        tester.widget<Text>(find.text('Link')).style?.color,
        AppColorsLight.gold500,
      );
    });

    testWidgets('custom color overrides semantic color', (tester) async {
      const customColor = Colors.purple;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText(
              'Test',
              color: customColor,
              semanticColor: AppTextColor.primary,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test'));
      expect(textWidget.style?.color, customColor);
    });

    testWidgets('all text variants render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AppText('Display Large', variant: AppTextVariant.displayLarge),
                  AppText('Display Medium', variant: AppTextVariant.displayMedium),
                  AppText('Display Small', variant: AppTextVariant.displaySmall),
                  AppText('Headline Large', variant: AppTextVariant.headlineLarge),
                  AppText('Headline Medium', variant: AppTextVariant.headlineMedium),
                  AppText('Headline Small', variant: AppTextVariant.headlineSmall),
                  AppText('Title Large', variant: AppTextVariant.titleLarge),
                  AppText('Title Medium', variant: AppTextVariant.titleMedium),
                  AppText('Title Small', variant: AppTextVariant.titleSmall),
                  AppText('Body Large', variant: AppTextVariant.bodyLarge),
                  AppText('Body Medium', variant: AppTextVariant.bodyMedium),
                  AppText('Body Small', variant: AppTextVariant.bodySmall),
                  AppText('Label Large', variant: AppTextVariant.labelLarge),
                  AppText('Label Medium', variant: AppTextVariant.labelMedium),
                  AppText('Label Small', variant: AppTextVariant.labelSmall),
                  AppText('Balance', variant: AppTextVariant.balance),
                  AppText('Percentage', variant: AppTextVariant.percentage),
                  AppText('Card Label', variant: AppTextVariant.cardLabel),
                  AppText('Mono Large', variant: AppTextVariant.monoLarge),
                  AppText('Mono Medium', variant: AppTextVariant.monoMedium),
                  AppText('Mono Small', variant: AppTextVariant.monoSmall),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify all variants render
      expect(find.text('Display Large'), findsOneWidget);
      expect(find.text('Display Medium'), findsOneWidget);
      expect(find.text('Display Small'), findsOneWidget);
      expect(find.text('Headline Large'), findsOneWidget);
      expect(find.text('Body Medium'), findsOneWidget);
      expect(find.text('Label Small'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Percentage'), findsOneWidget);
    });

    testWidgets('disabled text has correct color in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText('Disabled', semanticColor: AppTextColor.disabled),
          ),
        ),
      );

      final darkText = tester.widget<Text>(find.text('Disabled'));
      expect(darkText.style?.color, AppColors.textDisabled);
    });

    testWidgets('disabled text has correct color in light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppText('Disabled Light', semanticColor: AppTextColor.disabled),
          ),
        ),
      );

      final lightText = tester.widget<Text>(find.text('Disabled Light'));
      expect(lightText.style?.color, AppColorsLight.textDisabled);
    });

    testWidgets('bodySmall uses tertiary color by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText('Small', variant: AppTextVariant.bodySmall),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Small'));
      expect(textWidget.style?.color, AppColors.textTertiary);
    });

    testWidgets('percentage variant uses success color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText('+12.5%', variant: AppTextVariant.percentage),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('+12.5%'));
      expect(textWidget.style?.color, AppColors.successText);
    });

    testWidgets('accessibility - semantic label works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText(
              '\$1,234.56',
              semanticLabel: 'Balance: one thousand two hundred thirty four dollars and fifty six cents',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.text('\$1,234.56'));
      expect(
        semantics.label,
        'Balance: one thousand two hundred thirty four dollars and fifty six cents',
      );
    });

    testWidgets('accessibility - excludeSemantics works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText('Decorative', excludeSemantics: true),
          ),
        ),
      );

      // Widget renders without errors
      expect(find.text('Decorative'), findsOneWidget);
    });
  });

  group('AppText Typography Tests', () {
    testWidgets('font weight override works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppText(
              'Bold',
              variant: AppTextVariant.bodyMedium,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Bold'));
      expect(textWidget.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('text alignment works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SizedBox(
              width: 200,
              child: AppText(
                'Centered',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Centered'));
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('maxLines and overflow work', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: SizedBox(
              width: 100,
              child: AppText(
                'This is a very long text that should overflow',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('This is a very long text that should overflow'),
      );
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
