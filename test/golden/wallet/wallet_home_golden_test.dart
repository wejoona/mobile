import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/wallet/views/wallet_home_screen.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Wallet Home Screen
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/wallet/views/wallet_home_screen.dart
/// Route: /home
///
/// Test Matrix:
/// - Light/Dark mode
/// - Initial state
///
/// To update goldens:
/// flutter test --update-goldens test/golden/wallet/wallet_home_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('WalletHomeScreen Golden Tests', () {
    group('Light Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: WalletHomeScreen(),
          ),
        );
        // Use pump with duration instead of pumpAndSettle (screen has ongoing timers)
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/wallet/wallet_home/initial_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('initial state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: WalletHomeScreen(),
          ),
        );
        // Use pump with duration instead of pumpAndSettle (screen has ongoing timers)
        await tester.pump(const Duration(milliseconds: 500));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/wallet/wallet_home/initial_dark.png'),
        );
      });
    });
  });
}
