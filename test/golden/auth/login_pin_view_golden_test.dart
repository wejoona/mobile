import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/auth/views/login_pin_view.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Login PIN View
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/auth/views/login_pin_view.dart
/// Route: /login-pin
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state (no digits entered)
/// - Partial PIN entered
/// - Full PIN entered (before verification)
/// - Biometric prompt available
/// - Error state (wrong PIN)
/// - Locked state (too many attempts)
///
/// To update goldens:
/// flutter test --update-goldens test/golden/auth/login_pin_view_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('LoginPINView Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: LoginPinView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_pin_view/initial_light.png'),
        );
      });

      testWidgets('partial PIN entered', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: LoginPinView(),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate entering 3 digits by tapping number buttons
        for (final digit in ['1', '2', '3']) {
          final button = find.text(digit);
          if (button.evaluate().isNotEmpty) {
            await tester.tap(button.first);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_pin_view/partial_pin_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: LoginPinView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_pin_view/initial_dark.png'),
        );
      });
    });
  });
}
