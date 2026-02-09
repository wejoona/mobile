import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

import '../helpers/test_wrapper.dart';

/// Golden/Snapshot tests for AppCard component
/// Ensures visual consistency across all variants
///
/// To update goldens: flutter test --update-goldens test/snapshots/app_card_snapshot_test.dart
void main() {
  setUpAll(() { GoogleFonts.config.allowRuntimeFetching = false; });
  group('AppCard Snapshot Tests', () {
    group('Variants', () {
      testWidgets('elevated variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppText('Card Title', variant: AppTextVariant.titleMedium),
                      SizedBox(height: 8),
                      AppText('This is an elevated card with shadow and border.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/elevated.png'),
        );
      });

      testWidgets('goldAccent variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  variant: AppCardVariant.goldAccent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppText('Premium Card', variant: AppTextVariant.titleMedium),
                      SizedBox(height: 8),
                      AppText('Card with gold border accent.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/gold_accent.png'),
        );
      });

      testWidgets('subtle variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  variant: AppCardVariant.subtle,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppText('Subtle Card', variant: AppTextVariant.titleMedium),
                      SizedBox(height: 8),
                      AppText('Minimal styling for subtle emphasis.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/subtle.png'),
        );
      });

      testWidgets('glass variant', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  variant: AppCardVariant.glass,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      AppText('Glass Card', variant: AppTextVariant.titleMedium),
                      SizedBox(height: 8),
                      AppText('Glass morphism effect.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/glass.png'),
        );
      });
    });

    group('Padding', () {
      testWidgets('default padding', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  child: const AppText('Default padding'),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/padding_default.png'),
        );
      });

      testWidgets('custom padding', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: const AppText('Custom padding'),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/padding_custom.png'),
        );
      });

      testWidgets('no padding', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: const AppText('No padding'),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/padding_none.png'),
        );
      });
    });

    group('Border Radius', () {
      testWidgets('default radius', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  child: const AppText('Default border radius'),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/radius_default.png'),
        );
      });

      testWidgets('custom radius', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  borderRadius: AppRadius.sm,
                  child: const AppText('Small border radius'),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/radius_small.png'),
        );
      });
    });

    group('Interactive', () {
      testWidgets('tappable card', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Expanded(
                        child: AppText('Tappable card'),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/tappable.png'),
        );
      });
    });

    group('Content Variations', () {
      testWidgets('card with icon and text', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.gold500,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText('Wallet', variant: AppTextVariant.labelLarge),
                            SizedBox(height: 4),
                            AppText(
                              'Main wallet',
                              variant: AppTextVariant.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const AppText(
                        '\$1,234.56',
                        variant: AppTextVariant.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/with_icon.png'),
        );
      });

      testWidgets('card with divider', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: SizedBox(
                width: 300,
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      AppText('Section 1', variant: AppTextVariant.titleMedium),
                      SizedBox(height: AppSpacing.sm),
                      Divider(color: AppColors.borderSubtle, height: 1),
                      SizedBox(height: AppSpacing.sm),
                      AppText('Section 2', variant: AppTextVariant.titleMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/card/with_divider.png'),
        );
      });
    });

    group('Margin', () {
      testWidgets('card with margin', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: Container(
              width: 300,
              height: 200,
              color: AppColors.canvas,
              child: AppCard(
                margin: const EdgeInsets.all(AppSpacing.md),
                child: const AppText('Card with margin'),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(Container).first,
          matchesGoldenFile('goldens/card/with_margin.png'),
        );
      });
    });
  });
}
