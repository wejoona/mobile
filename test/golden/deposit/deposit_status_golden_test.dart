import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/views/deposit_status_screen.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Deposit - Status Screen
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/deposit/views/deposit_status_screen.dart
/// Route: /deposit/status/:id
///
/// Note: This screen reads from depositProvider state, not URL params
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state (loading)
///
/// To update goldens:
/// flutter test --update-goldens test/golden/deposit/deposit_status_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('DepositStatusScreen Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: DepositStatusScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/deposit/deposit_status/initial_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: DepositStatusScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/deposit/deposit_status/initial_dark.png'),
        );
      });
    });
  });
}
