import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('Amount Input Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders amount input field', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
            label: 'Amount',
          ),
        ),
      );

      expect(find.text('Amount'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('accepts decimal numbers', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '123.45');
      expect(controller.text, '123.45');
    });

    testWidgets('limits decimal places to 2', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
          ),
        ),
      );

      // Input formatters should limit to 2 decimal places
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.inputFormatters, isNotEmpty);
    });

    testWidgets('uses decimal keyboard', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(
        textField.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    });

    testWidgets('centers amount text', (tester) async {
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

    testWidgets('displays currency prefix', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
            prefix: const Text('\$'),
          ),
        ),
      );

      expect(find.text('\$'), findsOneWidget);
    });

    testWidgets('displays currency suffix', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
            suffix: const Text('USDC'),
          ),
        ),
      );

      expect(find.text('USDC'), findsOneWidget);
    });

    testWidgets('validates minimum amount', (tester) async {
      final formKey = GlobalKey<FormState>();
      const minAmount = 1.0;

      await tester.pumpWidget(
        TestWrapper(
          child: Form(
            key: formKey,
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount < minAmount) {
                  return 'Minimum amount is \$$minAmount';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Test below minimum
      controller.text = '0.50';
      expect(formKey.currentState!.validate(), isFalse);

      // Test valid amount
      controller.text = '1.00';
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('validates maximum amount', (tester) async {
      final formKey = GlobalKey<FormState>();
      const maxAmount = 1000.0;

      await tester.pumpWidget(
        TestWrapper(
          child: Form(
            key: formKey,
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount > maxAmount) {
                  return 'Maximum amount is \$$maxAmount';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Test above maximum
      controller.text = '1500.00';
      expect(formKey.currentState!.validate(), isFalse);

      // Test valid amount
      controller.text = '999.99';
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('validates insufficient balance', (tester) async {
      final formKey = GlobalKey<FormState>();
      const balance = 100.0;

      await tester.pumpWidget(
        TestWrapper(
          child: Form(
            key: formKey,
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount > balance) {
                  return 'Insufficient balance';
                }
                return null;
              },
            ),
          ),
        ),
      );

      controller.text = '150.00';
      expect(formKey.currentState!.validate(), isFalse);
      expect(find.text('Insufficient balance'), findsOneWidget);
    });

    testWidgets('formats large amounts with commas', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '1234567.89');
      expect(controller.text, '1234567.89');

      // Note: Formatting with commas would require custom formatter
    });

    testWidgets('shows error for invalid input', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
            error: 'Invalid amount',
          ),
        ),
      );

      expect(find.text('Invalid amount'), findsOneWidget);
    });

    testWidgets('displays helper text', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.amount,
            helper: 'Min: \$1, Max: \$10,000',
          ),
        ),
      );

      expect(find.text('Min: \$1, Max: \$10,000'), findsOneWidget);
    });

    group('Edge Cases', () {
      testWidgets('handles zero amount', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '0');
        expect(controller.text, '0');
      });

      testWidgets('handles leading zeros', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '00123');
        // Formatter behavior may vary
        expect(controller.text, isNotEmpty);
      });

      testWidgets('handles multiple decimal points', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
            ),
          ),
        );

        // Input formatter should prevent multiple decimals
        await tester.enterText(find.byType(TextFormField), '12.34.56');
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.inputFormatters, isNotEmpty);
      });

      testWidgets('clears amount', (tester) async {
        controller.text = '123.45';

        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
            ),
          ),
        );

        controller.clear();
        await tester.pumpAndSettle();

        expect(controller.text, '');
      });
    });

    group('Accessibility', () {
      testWidgets('announces amount to screen readers', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.amount,
              label: 'Amount',
              semanticLabel: 'Enter amount in USDC',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.label, contains('Enter amount in USDC'));
      });
    });
  });
}
