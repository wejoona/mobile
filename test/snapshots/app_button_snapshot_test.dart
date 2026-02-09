import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

import '../helpers/test_wrapper.dart';

/// Golden/Snapshot tests for AppButton component
/// Ensures visual consistency across all variants, sizes, and states
///
/// To update goldens: flutter test --update-goldens test/snapshots/app_button_snapshot_test.dart
void main() {
  setUpAll(() { GoogleFonts.config.allowRuntimeFetching = false; });
  group('AppButton Snapshot Tests', () {
    group('Variants', () {
      testWidgets('primary variant - default state', (tester) async {
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
          matchesGoldenFile('goldens/button/primary.png'),
        );
      });

      testWidgets('secondary variant', (tester) async {
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
          matchesGoldenFile('goldens/button/secondary.png'),
        );
      });

      testWidgets('ghost variant', (tester) async {
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
          matchesGoldenFile('goldens/button/ghost.png'),
        );
      });

      testWidgets('success variant', (tester) async {
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
          matchesGoldenFile('goldens/button/success.png'),
        );
      });

      testWidgets('danger variant', (tester) async {
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
          matchesGoldenFile('goldens/button/danger.png'),
        );
      });
    });

    group('Sizes', () {
      testWidgets('small size', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'Small Button',
                onPressed: () {},
                size: AppButtonSize.small,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/small.png'),
        );
      });

      testWidgets('medium size', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'Medium Button',
                onPressed: () {},
                size: AppButtonSize.medium,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/medium.png'),
        );
      });

      testWidgets('large size', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'Large Button',
                onPressed: () {},
                size: AppButtonSize.large,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/large.png'),
        );
      });
    });

    group('States', () {
      testWidgets('disabled state', (tester) async {
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
          matchesGoldenFile('goldens/button/disabled.png'),
        );
      });

      testWidgets('loading state', (tester) async {
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
          matchesGoldenFile('goldens/button/loading.png'),
        );
      });

      testWidgets('loading with secondary variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'Loading',
                onPressed: () {},
                variant: AppButtonVariant.secondary,
                isLoading: true,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/loading_secondary.png'),
        );
      });
    });

    group('Icons', () {
      testWidgets('icon on left', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'With Icon',
                onPressed: () {},
                icon: Icons.send,
                iconPosition: IconPosition.left,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/icon_left.png'),
        );
      });

      testWidgets('icon on right', (tester) async {
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
          matchesGoldenFile('goldens/button/icon_right.png'),
        );
      });

      testWidgets('icon with small button', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'Small Icon',
                onPressed: () {},
                icon: Icons.add,
                size: AppButtonSize.small,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/icon_small.png'),
        );
      });
    });

    group('Width', () {
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
          matchesGoldenFile('goldens/button/full_width.png'),
        );
      });

      testWidgets('auto width button', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'Auto',
                onPressed: () {},
                isFullWidth: false,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/auto_width.png'),
        );
      });
    });

    group('Combined States', () {
      testWidgets('small secondary button with icon', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: AppButton(
                label: 'Combined',
                onPressed: () {},
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                icon: Icons.check,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/combined_small_secondary_icon.png'),
        );
      });

      testWidgets('large danger button full width', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Delete Account',
                onPressed: () {},
                variant: AppButtonVariant.danger,
                size: AppButtonSize.large,
                isFullWidth: true,
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/combined_large_danger_full.png'),
        );
      });
    });

    group('Text Overflow', () {
      testWidgets('long text button', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 200,
                child: AppButton(
                  label: 'This is a very long button label that should truncate',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/button/long_text.png'),
        );
      });
    });
  });
}
