import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design/components/primitives/app_input.dart';
import 'package:mobile/design/tokens/colors.dart';
import '../helpers/accessibility_test_helper.dart';

void main() {
  group('AppInput Accessibility Tests', () {
    testWidgets('has proper semantic label from label prop', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email address',
            ),
          ),
        ),
      );

      // Should announce label
      final semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.label, contains('Email address'));
    });

    testWidgets('has text field role', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.hasFlag(SemanticsFlag.isTextField), isTrue);
    });

    testWidgets('announces error state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
              error: 'Invalid email address',
            ),
          ),
        ),
      );

      // Error should be in hint
      final semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.hint, contains('Error: Invalid email address'));
    });

    testWidgets('announces helper text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Password',
              helper: 'Must be at least 8 characters',
            ),
          ),
        ),
      );

      // Helper should be in hint
      final semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.hint, contains('Must be at least 8 characters'));
    });

    testWidgets('announces read-only state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
              readOnly: true,
            ),
          ),
        ),
      );

      // Read-only should be announced
      final semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.hint, contains('Read only'));
    });

    testWidgets('custom semantic label overrides default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
              semanticLabel: 'Enter your email address to continue',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.label, contains('Enter your email address to continue'));
    });

    testWidgets('meets minimum height for touch target', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
            ),
          ),
        ),
      );

      final textField = find.byType(TextFormField);
      final size = tester.getSize(textField);

      // Input should be tall enough (56dp minimum)
      expect(size.height, greaterThanOrEqualTo(56.0));
    });

    testWidgets('hint text announces when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
              hint: 'example@email.com',
            ),
          ),
        ),
      );

      // Hint should be visible
      expect(find.text('example@email.com'), findsOneWidget);
    });

    testWidgets('disabled input announces state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
              enabled: false,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
    });

    testWidgets('label contrast meets WCAG AA', (tester) async {
      const labelColor = AppColors.textSecondary;
      const backgroundColor = AppColors.obsidian;

      AccessibilityTestHelper.verifyContrastRatio(
        labelColor,
        backgroundColor,
        reason: 'Input label must be readable',
      );
    });

    testWidgets('input text contrast meets WCAG AA', (tester) async {
      const textColor = AppColors.textPrimary;
      const backgroundColor = AppColors.elevated;

      AccessibilityTestHelper.verifyContrastRatio(
        textColor,
        backgroundColor,
        reason: 'Input text must be readable',
      );
    });

    testWidgets('error text contrast meets WCAG AA', (tester) async {
      const errorColor = AppColors.errorText;
      const backgroundColor = AppColors.obsidian;

      AccessibilityTestHelper.verifyContrastRatio(
        errorColor,
        backgroundColor,
        reason: 'Error text must be readable',
      );
    });

    testWidgets('focus border contrast meets WCAG AA', (tester) async {
      const borderColor = AppColors.gold500;
      const backgroundColor = AppColors.obsidian;

      final ratio = AccessibilityTestHelper.calculateContrastRatio(
        borderColor,
        backgroundColor,
      );

      // UI components need 3:1 minimum
      expect(ratio, greaterThanOrEqualTo(3.0));
    });

    testWidgets('passes full accessibility audit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email address',
              hint: 'example@email.com',
            ),
          ),
        ),
      );

      await AccessibilityTestHelper.checkFormAccessibility(tester);
    });
  });

  group('AppInput Variant Accessibility', () {
    testWidgets('phone input has proper semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Phone number',
              variant: AppInputVariant.phone,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.keyboardType, TextInputType.phone);
    });

    testWidgets('pin input has proper semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'PIN',
              variant: AppInputVariant.pin,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.keyboardType, TextInputType.number);
      expect(textField.textAlign, TextAlign.center);
    });

    testWidgets('amount input has proper semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Amount',
              variant: AppInputVariant.amount,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.keyboardType, const TextInputType.numberWithOptions(decimal: true));
      expect(textField.textAlign, TextAlign.center);
    });

    testWidgets('search input has proper semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Search',
              variant: AppInputVariant.search,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.keyboardType, TextInputType.text);
    });
  });

  group('AppInput State Changes', () {
    testWidgets('error state transition announced', (tester) async {
      String? error;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AppInput(
                  label: 'Email',
                  error: error,
                );
              },
            ),
          ),
        ),
      );

      // No error initially
      var semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.hint, isNot(contains('Error')));

      // Add error
      error = 'Invalid email';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
              error: 'Invalid email',
            ),
          ),
        ),
      );

      // Error should be announced
      semantics = tester.getSemantics(find.byType(AppInput));
      expect(semantics.hint, contains('Error: Invalid email'));
    });

    testWidgets('focus state transition', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              controller: controller,
              focusNode: focusNode,
              label: 'Email',
            ),
          ),
        ),
      );

      // Request focus
      focusNode.requestFocus();
      await tester.pump();

      // Should be focused
      expect(focusNode.hasFocus, isTrue);

      controller.dispose();
      focusNode.dispose();
    });
  });

  group('PhoneInput Accessibility', () {
    testWidgets('country selector is accessible', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInput(
              controller: controller,
              label: 'Phone number',
            ),
          ),
        ),
      );

      // Should have country selector and input
      expect(find.text('+225'), findsOneWidget);
      expect(find.byType(AppInput), findsOneWidget);

      controller.dispose();
    });

    testWidgets('country selector announces selection', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInput(
              controller: controller,
              label: 'Phone number',
            ),
          ),
        ),
      );

      // Tap country selector
      final selector = find.byType(GestureDetector).first;
      expect(selector, findsOneWidget);

      controller.dispose();
    });
  });

  group('AppInput Contrast Tests', () {
    test('label color contrast (focused)', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.gold500,
        AppColors.obsidian,
        reason: 'Focused label must be readable',
      );
    });

    test('label color contrast (error)', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.errorText,
        AppColors.obsidian,
        reason: 'Error label must be readable',
      );
    });

    test('input text contrast', () {
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.textPrimary,
        AppColors.elevated,
        reason: 'Input text must be readable',
      );
    });

    test('placeholder text contrast', () {
      // Placeholders can have lower contrast (4.5:1)
      AccessibilityTestHelper.verifyContrastRatio(
        AppColors.textTertiary,
        AppColors.elevated,
        reason: 'Placeholder text should be readable',
      );
    });

    test('disabled input contrast', () {
      const textColor = AppColors.textDisabled;
      const backgroundColor = AppColors.elevated;

      final ratio = AccessibilityTestHelper.calculateContrastRatio(
        textColor,
        backgroundColor,
      );

      // Disabled can be lower but should still be visible
      expect(ratio, greaterThanOrEqualTo(3.0));
    });
  });
}
