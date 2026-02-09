import 'dart:ui' show SemanticsFlag;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import '../helpers/accessibility_test_helper.dart';

void main() {
  group('AppButton Accessibility Tests', () {
    testWidgets('has proper semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find by semantic label
      expect(
        find.bySemanticsLabel('Continue'),
        findsOneWidget,
      );
    });

    testWidgets('announces loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              isLoading: true,
            ),
          ),
        ),
      );

      // Should find loading semantics
      final semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.label, contains('Continue'));
      expect(semantics.hint, contains('Loading'));
    });

    testWidgets('announces disabled state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: null, // Disabled
            ),
          ),
        ),
      );

      // Should be marked as disabled
      final semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
    });

    testWidgets('has button role', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: () {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('meets minimum touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: () {},
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppButton));

      // WCAG requires minimum 44x44 dp
      expect(size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('custom semantic label overrides default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Next',
              semanticLabel: 'Continue to payment',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Should use custom label
      expect(
        find.bySemanticsLabel('Continue to payment'),
        findsOneWidget,
      );
    });

    testWidgets('primary button meets contrast requirements', (tester) async {
      // Primary button: gold gradient on dark background
      const textColor = AppColors.textInverse; // Dark text
      const backgroundColor = AppColors.gold500; // Gold background

      final ratio = AccessibilityTestHelper.calculateContrastRatio(
        textColor,
        backgroundColor,
      );

      // Should meet WCAG AA for normal text (4.5:1)
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    testWidgets('secondary button meets contrast requirements', (tester) async {
      // Secondary button: light text on dark background
      const textColor = AppColors.textPrimary;
      const backgroundColor = AppColors.obsidian;

      final ratio = AccessibilityTestHelper.calculateContrastRatio(
        textColor,
        backgroundColor,
      );

      // Should meet WCAG AAA (7:1)
      expect(ratio, greaterThanOrEqualTo(7.0));
    });

    testWidgets('button with icon maintains accessibility', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Send',
              icon: Icons.send,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Icon should not interfere with semantics
      expect(
        find.bySemanticsLabel('Send'),
        findsOneWidget,
      );
    });

    testWidgets('full-width button meets touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppButton(
                label: 'Continue',
                isFullWidth: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(48.0)); // Full-width uses larger height
    });

    testWidgets('small button still meets minimum size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Cancel',
              size: AppButtonSize.small,
              onPressed: () {},
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(40.0)); // Minimum for small
    });

    testWidgets('error button has proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Delete',
              variant: AppButtonVariant.danger,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Should still be accessible
      expect(
        find.bySemanticsLabel('Delete'),
        findsOneWidget,
      );

      final semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('ghost button meets contrast requirements', (tester) async {
      // Ghost button: gold text on dark background
      const textColor = AppColors.gold500;
      const backgroundColor = AppColors.obsidian;

      final ratio = AccessibilityTestHelper.calculateContrastRatio(
        textColor,
        backgroundColor,
      );

      // Should meet WCAG AA (4.5:1)
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    testWidgets('passes full accessibility audit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppButton(
                label: 'Continue',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Run comprehensive audit
      await AccessibilityTestHelper.checkSemanticLabels(tester);
      await AccessibilityTestHelper.checkTouchTargets(tester);
      await AccessibilityTestHelper.checkButtonStateAnnouncements(
        tester,
        find.byType(AppButton),
      );
    });
  });

  group('AppButton State Announcements', () {
    testWidgets('loading to enabled state change', (tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppButton(
                  label: 'Submit',
                  isLoading: isLoading,
                  onPressed: () {},
                );
              },
            ),
          ),
        ),
      );

      // Initially loading
      var semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.hint, contains('Loading'));

      // Change to not loading
      isLoading = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit',
              isLoading: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Should now be enabled
      semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
    });

    testWidgets('disabled to enabled state change', (tester) async {
      VoidCallback? onPressed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: onPressed,
            ),
          ),
        ),
      );

      // Initially disabled
      var semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);

      // Enable button
      onPressed = () {};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Continue',
              onPressed: onPressed,
            ),
          ),
        ),
      );

      // Should now be enabled
      semantics = tester.getSemantics(find.byType(AppButton));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
    });
  });

  group('AppButton Contrast Tests', () {
    test('primary button contrast ratio', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.textInverse,
        AppColors.gold500,
        reason: 'Primary button text must be readable',
      );
    });

    test('secondary button contrast ratio', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.textPrimary,
        AppColors.obsidian,
        reason: 'Secondary button text must be readable',
      );
    });

    test('ghost button contrast ratio', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.gold500,
        AppColors.obsidian,
        reason: 'Ghost button text must be readable',
      );
    });

    test('success button contrast ratio', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.textPrimary,
        AppColors.successBase,
        reason: 'Success button text must be readable',
      );
    });

    test('danger button contrast ratio', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.textPrimary,
        AppColors.errorBase,
        reason: 'Danger button text must be readable',
      );
    });

    test('disabled button maintains minimum contrast', () {
      // Even disabled buttons should have some contrast
      const textColor = AppColors.textDisabled;
      const backgroundColor = AppColors.elevated;

      final ratio = AccessibilityTestHelper.calculateContrastRatio(
        textColor,
        backgroundColor,
      );

      // Lower threshold for disabled (3:1) but still readable
      expect(ratio, greaterThanOrEqualTo(3.0));
    });
  });
}
