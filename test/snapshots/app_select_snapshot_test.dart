import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_select.dart';

import '../helpers/test_wrapper.dart';

/// Golden/Snapshot tests for AppSelect component
/// Ensures visual consistency across all states
///
/// To update goldens: flutter test --update-goldens test/snapshots/app_select_snapshot_test.dart
void main() {
  setUpAll(() { GoogleFonts.config.allowRuntimeFetching = false; });
  final testItems = [
    const AppSelectItem(
      value: 'option1',
      label: 'Option 1',
    ),
    const AppSelectItem(
      value: 'option2',
      label: 'Option 2',
    ),
    const AppSelectItem(
      value: 'option3',
      label: 'Option 3',
    ),
  ];

  group('AppSelect Snapshot Tests', () {
    group('States', () {
      testWidgets('idle state - no selection', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: null,
                onChanged: (_) {},
                label: 'Select an option',
                hint: 'Choose one',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/idle_no_selection.png'),
        );
      });

      testWidgets('with selection', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: 'option2',
                onChanged: (_) {},
                label: 'Select an option',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/with_selection.png'),
        );
      });

      testWidgets('disabled state', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: 'option1',
                onChanged: (_) {},
                label: 'Disabled select',
                enabled: false,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/disabled.png'),
        );
      });

      testWidgets('error state', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: null,
                onChanged: (_) {},
                label: 'Select an option',
                error: 'This field is required',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/error.png'),
        );
      });
    });

    group('Helper Text', () {
      testWidgets('with helper text', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: null,
                onChanged: (_) {},
                label: 'Select an option',
                helper: 'Choose the best option for you',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/with_helper.png'),
        );
      });
    });

    group('Icons', () {
      testWidgets('with prefix icon', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: 'option1',
                onChanged: (_) {},
                label: 'Category',
                prefixIcon: Icons.category,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/with_prefix_icon.png'),
        );
      });

      testWidgets('items with icons', (tester) async {
        final itemsWithIcons = [
          const AppSelectItem(
            value: 'wallet',
            label: 'Wallet',
            icon: Icons.account_balance_wallet,
          ),
          const AppSelectItem(
            value: 'card',
            label: 'Card',
            icon: Icons.credit_card,
          ),
          const AppSelectItem(
            value: 'bank',
            label: 'Bank',
            icon: Icons.account_balance,
          ),
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: itemsWithIcons,
                value: 'wallet',
                onChanged: (_) {},
                label: 'Payment Method',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/items_with_icons.png'),
        );
      });
    });

    group('Subtitles', () {
      testWidgets('items with subtitles', (tester) async {
        final itemsWithSubtitles = [
          const AppSelectItem(
            value: 'premium',
            label: 'Premium Account',
            subtitle: 'Unlimited transactions',
            icon: Icons.star,
          ),
          const AppSelectItem(
            value: 'standard',
            label: 'Standard Account',
            subtitle: 'Up to 50 transactions/month',
            icon: Icons.person,
          ),
          const AppSelectItem(
            value: 'basic',
            label: 'Basic Account',
            subtitle: 'Up to 10 transactions/month',
            icon: Icons.person_outline,
          ),
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: itemsWithSubtitles,
                value: 'standard',
                onChanged: (_) {},
                label: 'Account Type',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/items_with_subtitles.png'),
        );
      });
    });

    group('Disabled Items', () {
      testWidgets('with disabled items', (tester) async {
        final itemsWithDisabled = [
          const AppSelectItem(
            value: 'option1',
            label: 'Available Option',
            enabled: true,
          ),
          const AppSelectItem(
            value: 'option2',
            label: 'Disabled Option',
            subtitle: 'Coming soon',
            enabled: false,
          ),
          const AppSelectItem(
            value: 'option3',
            label: 'Another Available',
            enabled: true,
          ),
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: itemsWithDisabled,
                value: 'option1',
                onChanged: (_) {},
                label: 'Feature',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/with_disabled_items.png'),
        );
      });
    });

    group('No Label', () {
      testWidgets('select without label', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: null,
                onChanged: (_) {},
                hint: 'Choose an option',
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/no_label.png'),
        );
      });
    });

    group('Currency Selection Example', () {
      testWidgets('currency select', (tester) async {
        final currencies = [
          const AppSelectItem(
            value: 'XOF',
            label: 'XOF - CFA Franc',
            subtitle: 'West African CFA',
          ),
          const AppSelectItem(
            value: 'USD',
            label: 'USD - US Dollar',
            subtitle: 'United States',
          ),
          const AppSelectItem(
            value: 'EUR',
            label: 'EUR - Euro',
            subtitle: 'European Union',
          ),
        ];

        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: currencies,
                value: 'XOF',
                onChanged: (_) {},
                label: 'Currency',
                prefixIcon: Icons.attach_money,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/currency_example.png'),
        );
      });
    });

    group('Without Checkmark', () {
      testWidgets('select without checkmark', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppSelect<String>(
                items: testItems,
                value: 'option2',
                onChanged: (_) {},
                label: 'Simple select',
                showCheckmark: false,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppSelect<String>),
          matchesGoldenFile('goldens/select/no_checkmark.png'),
        );
      });
    });
  });
}
