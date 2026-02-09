import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/send/views/amount_screen.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Send - Amount Screen
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/send/views/amount_screen.dart
/// Route: /send/amount
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/send/amount_screen_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('AmountScreen Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: AmountScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/send/amount_screen/initial_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: AmountScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/send/amount_screen/initial_dark.png'),
        );
      });
    });
  });
}
