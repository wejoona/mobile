import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/deposit/views/payment_instructions_screen.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Deposit - Payment Instructions Screen
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/deposit/views/payment_instructions_screen.dart
/// Route: /deposit/instructions
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/deposit/payment_instructions_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('PaymentInstructionsScreen Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: PaymentInstructionsScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/deposit/payment_instructions/initial_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: PaymentInstructionsScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/deposit/payment_instructions/initial_dark.png'),
        );
      });
    });
  });
}
