import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/views/provider_selection_screen.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Deposit - Provider Selection Screen
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/deposit/views/provider_selection_screen.dart
/// Route: /deposit/provider
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/deposit/provider_selection_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('ProviderSelectionScreen Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: ProviderSelectionScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/deposit/provider_selection/initial_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: ProviderSelectionScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/deposit/provider_selection/initial_dark.png'),
        );
      });
    });
  });
}
