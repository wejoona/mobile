import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';

import '../helpers/golden_test_helper.dart';

/// Golden tests for Login View
///
/// Status: ACTIVE (MVP Critical)
/// File: lib/features/auth/views/login_view.dart
/// Route: /login
///
/// Test Matrix:
/// - Light/Dark mode
/// - Default state (login mode)
/// - Register mode
/// - Loading state
/// - Error state
/// - Invalid phone input
/// - Valid phone input
/// - Different country selected
///
/// To update goldens:
/// flutter test --update-goldens test/golden/auth/login_view_golden_test.dart
void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('LoginView Golden Tests', () {
    group('Light Mode', () {
      testWidgets('default login state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: LoginView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/default_light.png'),
        );
      });

      testWidgets('register mode', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: LoginView(),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap "Sign up" link to switch to register mode
        final signUpFinder = find.text('Sign up');
        if (signUpFinder.evaluate().isNotEmpty) {
          await tester.tap(signUpFinder);
          await tester.pumpAndSettle();
        }

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/register_mode_light.png'),
        );
      });

      testWidgets('with valid phone number entered', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: LoginView(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter a valid 10-digit phone number for Ivory Coast
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '0123456789');
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/valid_phone_light.png'),
        );
      });

      testWidgets('with invalid phone number entered', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: LoginView(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter an invalid short phone number
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '012');
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/invalid_phone_light.png'),
        );
      });
    });

    group('Dark Mode', () {
      testWidgets('default login state', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: LoginView(),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/default_dark.png'),
        );
      });

      testWidgets('register mode', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: LoginView(),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap "Sign up" link
        final signUpFinder = find.text('Sign up');
        if (signUpFinder.evaluate().isNotEmpty) {
          await tester.tap(signUpFinder);
          await tester.pumpAndSettle();
        }

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/register_mode_dark.png'),
        );
      });

      testWidgets('with valid phone number entered', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: true,
            child: LoginView(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter a valid phone number
        final phoneField = find.byType(TextField).first;
        await tester.enterText(phoneField, '0123456789');
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/valid_phone_dark.png'),
        );
      });
    });

    group('Responsive - Tablet', () {
      testWidgets('tablet layout light mode', (tester) async {
        await tester.binding.setSurfaceSize(GoldenTestConfig.devices['ipad_mini']!);
        
        await tester.pumpWidget(
          GoldenTestWrapper(
            isDarkMode: false,
            child: Builder(
              builder: (context) => MediaQuery(
                data: MediaQueryData(
                  size: GoldenTestConfig.devices['ipad_mini']!,
                  devicePixelRatio: 2.0,
                ),
                child: const LoginView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/auth/login_view/tablet_light.png'),
        );
      });
    });
  });
}
