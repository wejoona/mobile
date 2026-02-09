import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/splash/views/splash_view.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Splash View
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/splash/views/splash_view.dart
/// Route: /
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial loading animation
/// - Post-animation state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/splash/splash_view_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('SplashView Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial animation frame', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: SplashView(),
          ),
        );
        // Capture early in animation
        await tester.pump(const Duration(milliseconds: 200));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/splash/splash_view/initial_light.png'),
        );
      });

      testWidgets('animation complete', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: SplashView(),
          ),
        );
        // Let animation complete (1500ms)
        await tester.pump(const Duration(milliseconds: 800));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/splash/splash_view/complete_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial animation frame', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: SplashView(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/splash/splash_view/initial_dark.png'),
        );
      });

      testWidgets('animation complete', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: SplashView(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 800));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/splash/splash_view/complete_dark.png'),
        );
      });
    });
  });
}
