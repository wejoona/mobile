import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';

import '../helpers/test_wrapper.dart';

/// Golden/Snapshot tests for AppInput component
/// Ensures visual consistency across all variants and states
///
/// To update goldens: flutter test --update-goldens test/snapshots/app_input_snapshot_test.dart
void main() {
  group('AppInput Snapshot Tests', () {
    group('Variants', () {
      testWidgets('standard variant - idle', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Email',
                hint: 'Enter your email',
                variant: AppInputVariant.standard,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/standard_idle.png'),
        );
      });

      testWidgets('phone variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Phone Number',
                hint: '0X XX XX XX XX',
                variant: AppInputVariant.phone,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/phone.png'),
        );
      });

      testWidgets('pin variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'PIN',
                hint: 'Enter PIN',
                variant: AppInputVariant.pin,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/pin.png'),
        );
      });

      testWidgets('amount variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Amount',
                hint: '0.00',
                variant: AppInputVariant.amount,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/amount.png'),
        );
      });

      testWidgets('search variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                hint: 'Search transactions...',
                variant: AppInputVariant.search,
                prefixIcon: Icons.search,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/search.png'),
        );
      });
    });

    group('States', () {
      testWidgets('focused state', (tester) async {
        final controller = TextEditingController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                controller: controller,
                focusNode: focusNode,
                label: 'Username',
                hint: 'Enter username',
                autofocus: true,
              ),
            ),
          ),
        );

        // Wait for autofocus
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/focused.png'),
        );
      });

      testWidgets('filled state', (tester) async {
        final controller = TextEditingController(text: 'john.doe@example.com');

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                controller: controller,
                label: 'Email',
                hint: 'Enter email',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/filled.png'),
        );
      });

      testWidgets('error state', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Email',
                hint: 'Enter email',
                error: 'Invalid email format',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/error.png'),
        );
      });

      testWidgets('disabled state', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Disabled Field',
                hint: 'Cannot edit',
                enabled: false,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/disabled.png'),
        );
      });

      testWidgets('readonly state', (tester) async {
        final controller = TextEditingController(text: 'Read only value');

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                controller: controller,
                label: 'Read Only',
                readOnly: true,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/readonly.png'),
        );
      });
    });

    group('Helper Text', () {
      testWidgets('with helper text', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Password',
                hint: 'Enter password',
                helper: 'Must be at least 8 characters',
                obscureText: true,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/with_helper.png'),
        );
      });

      testWidgets('with error overrides helper', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Password',
                hint: 'Enter password',
                helper: 'Must be at least 8 characters',
                error: 'Password is too short',
                obscureText: true,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/error_over_helper.png'),
        );
      });
    });

    group('Icons', () {
      testWidgets('with prefix icon', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Email',
                hint: 'Enter email',
                prefixIcon: Icons.email_outlined,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/prefix_icon.png'),
        );
      });

      testWidgets('with suffix icon', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Search',
                hint: 'Enter search term',
                suffixIcon: Icons.clear,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/suffix_icon.png'),
        );
      });

      testWidgets('with both icons', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Username',
                hint: 'Enter username',
                prefixIcon: Icons.person_outline,
                suffixIcon: Icons.check_circle,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/both_icons.png'),
        );
      });
    });

    group('Prefix/Suffix Widgets', () {
      testWidgets('with prefix widget', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Amount',
                hint: '0.00',
                prefix: const Text('\$ ', style: TextStyle(fontSize: 16)),
                variant: AppInputVariant.amount,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/prefix_widget.png'),
        );
      });

      testWidgets('with suffix widget', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Amount',
                hint: '0.00',
                suffix: const Text(' USDC', style: TextStyle(fontSize: 14)),
                variant: AppInputVariant.amount,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/suffix_widget.png'),
        );
      });
    });

    group('Multiline', () {
      testWidgets('multiline input', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Description',
                hint: 'Enter description',
                maxLines: 4,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/multiline.png'),
        );
      });

      testWidgets('multiline with content', (tester) async {
        final controller = TextEditingController(
          text: 'This is a longer description\nthat spans multiple lines\nto test multiline input',
        );

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                controller: controller,
                label: 'Description',
                maxLines: 4,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/multiline_filled.png'),
        );
      });
    });

    group('Obscure Text', () {
      testWidgets('password field', (tester) async {
        final controller = TextEditingController(text: 'password123');

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                controller: controller,
                label: 'Password',
                hint: 'Enter password',
                obscureText: true,
                prefixIcon: Icons.lock_outline,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/password.png'),
        );
      });
    });

    group('PhoneInput Widget', () {
      testWidgets('phone input with country code', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PhoneInput(
                controller: controller,
                label: 'Phone Number',
                countryCode: '+225',
                onCountryCodeTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(PhoneInput),
          matchesGoldenFile('goldens/input/phone_input_widget.png'),
        );
      });

      testWidgets('phone input with different country code', (tester) async {
        final controller = TextEditingController(text: '0712345678');

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PhoneInput(
                controller: controller,
                label: 'Phone Number',
                countryCode: '+221',
                onCountryCodeTap: () {},
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(PhoneInput),
          matchesGoldenFile('goldens/input/phone_input_senegal.png'),
        );
      });

      testWidgets('phone input with error', (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PhoneInput(
                controller: controller,
                label: 'Phone Number',
                countryCode: '+225',
                error: 'Invalid phone number',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(PhoneInput),
          matchesGoldenFile('goldens/input/phone_input_error.png'),
        );
      });
    });

    group('No Label', () {
      testWidgets('input without label', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                hint: 'Search...',
                prefixIcon: Icons.search,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/input/no_label.png'),
        );
      });
    });
  });
}
