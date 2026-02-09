import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('AppInput Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            label: 'Username',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('renders with hint', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            hint: 'Enter your name',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Test input');
      expect(controller.text, 'Test input');
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'New text');
      expect(changedValue, 'New text');
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            error: 'This field is required',
          ),
        ),
      );

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('displays helper text', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            helper: 'At least 8 characters',
          ),
        ),
      );

      expect(find.text('At least 8 characters'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            obscureText: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            enabled: false,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('is read-only when readOnly is true', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            readOnly: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);
    });

    group('Input Variants', () {
      testWidgets('phone variant uses phone keyboard', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.phone,
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.phone);
      });

      testWidgets('pin variant uses number keyboard', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.number);
      });

      testWidgets('amount variant uses decimal keyboard', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, const TextInputType.numberWithOptions(decimal: true));
      });

      testWidgets('amount variant has center text alignment', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.textAlign, TextAlign.center);
      });
    });

    testWidgets('renders prefix icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            prefixIcon: Icons.person,
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders suffix icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            suffixIcon: Icons.visibility,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(TextFormField));
      expect(tapped, isTrue);
    });

    testWidgets('validates using validator function', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        TestWrapper(
          child: Form(
            key: formKey,
            child: AppInput(
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      expect(find.text('Required'), findsOneWidget);

      controller.text = 'value';
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('respects maxLength', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            maxLength: 5,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 5);
    });

    testWidgets('respects maxLines', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            maxLines: 3,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 3);
    });

    group('Focus Management', () {
      testWidgets('shows focused state when focused', (tester) async {
        final focusNode = FocusNode();

        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        expect(focusNode.hasFocus, isTrue);

        focusNode.dispose();
      });

      testWidgets('autofocus works', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              autofocus: true,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.autofocus, isTrue);
      });
    });

    group('Accessibility', () {
      testWidgets('has proper semantic label', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              label: 'Email',
              semanticLabel: 'Email address input',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.label, contains('Email address input'));
      });

      testWidgets('indicates text field in semantics', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.hasFlag(SemanticsFlag.isTextField), isTrue);
      });

      testWidgets('includes error in semantic hint', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              error: 'Invalid input',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.hint, contains('Error: Invalid input'));
      });
    });

    group('Edge Cases', () {
      testWidgets('handles rapid text changes', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'A');
        await tester.enterText(find.byType(TextFormField), 'AB');
        await tester.enterText(find.byType(TextFormField), 'ABC');

        expect(controller.text, 'ABC');
      });

      testWidgets('clears controller text', (tester) async {
        controller.text = 'Initial text';

        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
            ),
          ),
        );

        expect(find.text('Initial text'), findsOneWidget);

        controller.clear();
        await tester.pumpAndSettle();

        expect(controller.text, '');
      });
    });
  });

  group('PhoneInput Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with country code', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: PhoneInput(
            controller: controller,
            countryCode: '+225',
          ),
        ),
      );

      expect(find.text('+225'), findsOneWidget);
    });

    testWidgets('calls onCountryCodeTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        TestWrapper(
          child: PhoneInput(
            controller: controller,
            onCountryCodeTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('accepts phone number input', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: PhoneInput(
            controller: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '0123456789');
      expect(controller.text, '0123456789');
    });

    testWidgets('displays error', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: PhoneInput(
            controller: controller,
            error: 'Invalid phone number',
          ),
        ),
      );

      expect(find.text('Invalid phone number'), findsOneWidget);
    });

    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: PhoneInput(
            controller: controller,
            label: 'Phone Number',
          ),
        ),
      );

      expect(find.text('Phone Number'), findsOneWidget);
    });
  });
}
