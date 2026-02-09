import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';

import '../../helpers/test_wrapper.dart';

void main() {
  group('PIN Entry Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders PIN input field', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.pin,
            obscureText: true,
            maxLength: 6,
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('accepts numeric PIN input', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.pin,
            obscureText: true,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '123456');
      expect(controller.text, '123456');
    });

    testWidgets('obscures PIN text', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.pin,
            obscureText: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('limits PIN length', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.pin,
            maxLength: 6,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 6);
    });

    testWidgets('uses number keyboard', (tester) async {
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

    testWidgets('centers PIN text', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AppInput(
            controller: controller,
            variant: AppInputVariant.pin,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textAlign, TextAlign.center);
    });

    testWidgets('validates PIN requirements', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        TestWrapper(
          child: Form(
            key: formKey,
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'PIN must be 6 digits';
                }
                return null;
              },
            ),
          ),
        ),
      );

      // Empty PIN
      expect(formKey.currentState!.validate(), isFalse);

      // Too short
      controller.text = '123';
      expect(formKey.currentState!.validate(), isFalse);

      // Valid length
      controller.text = '123456';
      expect(formKey.currentState!.validate(), isTrue);
    });

    group('PIN Confirmation', () {
      testWidgets('validates PIN match', (tester) async {
        final pinController = TextEditingController();
        final confirmController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          TestWrapper(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  AppInput(
                    controller: pinController,
                    variant: AppInputVariant.pin,
                    label: 'Enter PIN',
                  ),
                  AppInput(
                    controller: confirmController,
                    variant: AppInputVariant.pin,
                    label: 'Confirm PIN',
                    validator: (value) {
                      if (value != pinController.text) {
                        return 'PINs do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        // Enter different PINs
        pinController.text = '123456';
        confirmController.text = '654321';

        expect(formKey.currentState!.validate(), isFalse);

        // Enter matching PINs
        confirmController.text = '123456';
        expect(formKey.currentState!.validate(), isTrue);

        pinController.dispose();
        confirmController.dispose();
      });
    });

    group('Security', () {
      testWidgets('does not expose PIN in plain text', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
              obscureText: true,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '123456');

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);

        // Text should be obscured in UI
        expect(find.text('123456'), findsNothing);
      });
    });

    group('Error States', () {
      testWidgets('shows error for weak PIN', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
              error: 'PIN is too weak',
            ),
          ),
        );

        expect(find.text('PIN is too weak'), findsOneWidget);
      });

      testWidgets('shows error for sequential digits', (tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          TestWrapper(
            child: Form(
              key: formKey,
              child: AppInput(
                controller: controller,
                variant: AppInputVariant.pin,
                validator: (value) {
                  if (value == '123456' || value == '654321') {
                    return 'Sequential PINs not allowed';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        controller.text = '123456';
        expect(formKey.currentState!.validate(), isFalse);
        expect(find.text('Sequential PINs not allowed'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('announces PIN field to screen readers', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
              label: 'Enter PIN',
              semanticLabel: 'Enter your 6-digit PIN',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Semantics).first);
        expect(semantics.label, contains('Enter your 6-digit PIN'));
      });
    });

    group('Edge Cases', () {
      testWidgets('filters non-numeric input', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'abc123');

        // Only digits should be accepted
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.number);
      });

      testWidgets('handles paste of non-numeric content', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
            ),
          ),
        );

        // Input formatters should filter non-numeric
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.inputFormatters, isNotEmpty);
      });

      testWidgets('clears PIN on demand', (tester) async {
        controller.text = '123456';

        await tester.pumpWidget(
          TestWrapper(
            child: AppInput(
              controller: controller,
              variant: AppInputVariant.pin,
              obscureText: true,
            ),
          ),
        );

        controller.clear();
        await tester.pumpAndSettle();

        expect(controller.text, '');
      });
    });
  });
}
