import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

import '../../helpers/test_wrapper.dart';

/// Component Golden Tests for Design Validation
///
/// These tests capture screenshots of UI components to:
/// 1. Validate UI matches design mockups
/// 2. Detect visual regressions
/// 3. Ensure consistency across releases
///
/// To update goldens after intentional design changes:
///   flutter test --update-goldens test/screens/golden/
///
/// KNOWN ISSUE: First test in some groups may fail due to GoogleFonts
/// async loading timers. The goldens are still generated. Run tests
/// twice if needed - failures on second run indicate real issues.
void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final screenSizes = {
    'medium': const Size(390, 844),
    'large': const Size(430, 932),
  };

  group('AppButton Golden Tests - Screen Variants', () {
    for (final entry in screenSizes.entries) {
      testWidgets('primary button - ${entry.key} device', (tester) async {
        tester.view.physicalSize = entry.value * tester.view.devicePixelRatio;
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: 'Continue',
                  onPressed: () {},
                  isFullWidth: true,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/components/button_primary_${entry.key}.png'),
        );
      });

      testWidgets('secondary button - ${entry.key} device', (tester) async {
        tester.view.physicalSize = entry.value * tester.view.devicePixelRatio;
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(
                  label: 'Cancel',
                  onPressed: () {},
                  variant: AppButtonVariant.secondary,
                  isFullWidth: true,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(AppButton),
          matchesGoldenFile('goldens/components/button_secondary_${entry.key}.png'),
        );
      });
    }
  });

  group('AppInput Golden Tests', () {
    for (final entry in screenSizes.entries) {
      testWidgets('text input - ${entry.key} device', (tester) async {
        tester.view.physicalSize = entry.value * tester.view.devicePixelRatio;
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppInput(
                  label: 'Phone Number',
                  hint: '+225 XX XX XX XX',
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/components/input_${entry.key}.png'),
        );
      });

      testWidgets('input with error - ${entry.key} device', (tester) async {
        tester.view.physicalSize = entry.value * tester.view.devicePixelRatio;
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppInput(
                  label: 'Phone Number',
                  hint: '+225 XX XX XX XX',
                  error: 'Invalid phone number',
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(AppInput),
          matchesGoldenFile('goldens/components/input_error_${entry.key}.png'),
        );
      });
    }
  });

  group('AppCard Golden Tests', () {
    for (final entry in screenSizes.entries) {
      testWidgets('card - ${entry.key} device', (tester) async {
        tester.view.physicalSize = entry.value * tester.view.devicePixelRatio;
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          TestWrapper(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('\$1,234.56', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/components/card_${entry.key}.png'),
        );
      });
    }
  });

  group('Button States Golden Tests', () {
    testWidgets('disabled button', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: AppButton(
                label: 'Disabled',
                onPressed: null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/components/button_disabled.png'),
      );
    });

    testWidgets('loading button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Loading',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/components/button_loading.png'),
      );
    });

    testWidgets('button with icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Send',
                onPressed: () {},
                icon: Icons.send,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/components/button_with_icon.png'),
      );
    });

    testWidgets('success button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Success',
                onPressed: () {},
                variant: AppButtonVariant.success,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/components/button_success.png'),
      );
    });

    testWidgets('danger button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Delete',
                onPressed: () {},
                variant: AppButtonVariant.danger,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/components/button_danger.png'),
      );
    });

    testWidgets('ghost button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Learn More',
                onPressed: () {},
                variant: AppButtonVariant.ghost,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/components/button_ghost.png'),
      );
    });
  });

  group('Light Theme Golden Tests', () {
    testWidgets('button in light theme', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          useDarkTheme: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                label: 'Light Theme',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/components/button_light_theme.png'),
      );
    });

    testWidgets('input in light theme', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          useDarkTheme: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppInput(
                label: 'Email',
                hint: 'example@email.com',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppInput),
        matchesGoldenFile('goldens/components/input_light_theme.png'),
      );
    });

    testWidgets('card in light theme', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          useDarkTheme: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('Premium', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(AppCard),
        matchesGoldenFile('goldens/components/card_light_theme.png'),
      );
    });
  });
}
