import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('OnboardingView Golden Tests', () {
    group('Light Mode', () {
      testWidgets('first page', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: OnboardingView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/onboarding/onboarding_view/page1_light.png'),
        );
      });

      testWidgets('second page', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: OnboardingView(),
          ),
        );
        await tester.pumpAndSettle();

        // Swipe to second page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/onboarding/onboarding_view/page2_light.png'),
        );
      });

      testWidgets('third page with CTA', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: OnboardingView(),
          ),
        );
        await tester.pumpAndSettle();

        // Swipe to third page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/onboarding/onboarding_view/page3_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('first page', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: OnboardingView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/onboarding/onboarding_view/page1_dark.png'),
        );
      });

      testWidgets('third page with CTA', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: OnboardingView(),
          ),
        );
        await tester.pumpAndSettle();

        // Swipe to third page
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/onboarding/onboarding_view/page3_dark.png'),
        );
      });
    });
  });
}
