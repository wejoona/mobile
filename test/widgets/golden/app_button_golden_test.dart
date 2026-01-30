import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../../helpers/test_wrapper.dart';

/// Golden tests for AppButton visual regression
///
/// To update goldens: flutter test --update-goldens
void main() {
  group('AppButton Golden Tests', () {
    testWidgets('primary button default state', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Primary Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_primary.png'),
      );
    });

    testWidgets('primary button disabled state', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_primary_disabled.png'),
      );
    });

    testWidgets('primary button loading state', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Loading Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_primary_loading.png'),
      );
    });

    testWidgets('secondary button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Secondary Button',
              onPressed: () {},
              variant: AppButtonVariant.secondary,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_secondary.png'),
      );
    });

    testWidgets('ghost button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Ghost Button',
              onPressed: () {},
              variant: AppButtonVariant.ghost,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_ghost.png'),
      );
    });

    testWidgets('success button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Success Button',
              onPressed: () {},
              variant: AppButtonVariant.success,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_success.png'),
      );
    });

    testWidgets('danger button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Danger Button',
              onPressed: () {},
              variant: AppButtonVariant.danger,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_danger.png'),
      );
    });

    testWidgets('small button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Small',
              onPressed: () {},
              size: AppButtonSize.small,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_small.png'),
      );
    });

    testWidgets('large button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'Large',
              onPressed: () {},
              size: AppButtonSize.large,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_large.png'),
      );
    });

    testWidgets('button with icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: AppButton(
              label: 'With Icon',
              onPressed: () {},
              icon: Icons.arrow_forward,
              iconPosition: IconPosition.right,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_with_icon.png'),
      );
    });

    testWidgets('full width button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Full Width',
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_full_width.png'),
      );
    });
  });
}
