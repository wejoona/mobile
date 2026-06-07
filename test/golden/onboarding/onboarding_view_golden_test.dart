import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_view.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Onboarding View
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/onboarding/views/onboarding_view.dart
/// Route: /onboarding
///
/// Test Matrix:
/// - Light/Dark mode
/// - First page
/// - Second page
/// - Third page (last with CTA)
///
/// To update goldens:
/// flutter test --update-goldens test/golden/onboarding/onboarding_view_golden_test.dart
void main() {
  if (skipVisualSuiteIfDisabled()) return;

  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  Future<void> pumpOnboardingGolden(
    WidgetTester tester, {
    required bool isDarkMode,
  }) async {
    await tester.pumpWidget(
      GoldenTestWrapper(isDarkMode: isDarkMode, child: const OnboardingView()),
    );
    await tester.pump(const Duration(milliseconds: 900));
  }

  Future<void> goToNextPage(WidgetTester tester) async {
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pump(const Duration(milliseconds: 500));
  }

  goldenGroup('OnboardingView Golden Tests', () {
    goldenGroup('Light Mode', () {
      testWidgets('first page', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await pumpOnboardingGolden(tester, isDarkMode: false);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/onboarding/onboarding_view/page1_light.png',
          ),
        );
      });

      testWidgets('second page', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await pumpOnboardingGolden(tester, isDarkMode: false);

        // Swipe to second page
        await goToNextPage(tester);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/onboarding/onboarding_view/page2_light.png',
          ),
        );
      });

      testWidgets('third page with CTA', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await pumpOnboardingGolden(tester, isDarkMode: false);

        // Swipe to third page
        await goToNextPage(tester);
        await goToNextPage(tester);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/onboarding/onboarding_view/page3_light.png',
          ),
        );
      });
    });

    goldenGroup('Dark Mode', () {
      testWidgets('first page', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await pumpOnboardingGolden(tester, isDarkMode: true);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/onboarding/onboarding_view/page1_dark.png',
          ),
        );
      });

      testWidgets('third page with CTA', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);

        await pumpOnboardingGolden(tester, isDarkMode: true);

        // Swipe to third page
        await goToNextPage(tester);
        await goToNextPage(tester);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/onboarding/onboarding_view/page3_dark.png',
          ),
        );
      });
    });
  });
}
