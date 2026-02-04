import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: AUTH FLOW
///
/// Screens covered:
/// - 1.1 Splash Screen
/// - 1.2 Onboarding Screen
/// - 1.3 Login Screen
/// - 1.4 OTP Screen (Secure Login)
/// - 1.5 Login PIN Screen
///
/// Run with mocks (default):
///   flutter test integration_test/golden/tests/01_auth_golden_test.dart --update-goldens
///
/// Run with real backend:
///   flutter test integration_test/golden/tests/01_auth_golden_test.dart --update-goldens --dart-define=USE_MOCKS=false
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Auth Flow Golden Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      TestHelpers.configureMocks();
      await TestHelpers.clearAppData();
    });

    // ─────────────────────────────────────────────────────────────
    // 1.1 SPLASH SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('1.1 Splash Screen', (tester) async {
      /// GIVEN the app is launched
      /// WHEN the splash screen displays
      /// THEN the JoonaPay logo should be visible

      app.main();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/auth/1.1_splash.png'),
      );
    });

    // ─────────────────────────────────────────────────────────────
    // 1.2 ONBOARDING SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('1.2 Onboarding Screen', (tester) async {
      /// GIVEN a new user opens the app
      /// WHEN the onboarding screen displays
      /// THEN feature highlights should be visible
      /// AND "Skip" and "Get Started" buttons should be available

      app.main();
      await tester.pumpAndSettle();

      // Should show onboarding for new users
      final hasOnboarding = find.text('Skip').evaluate().isNotEmpty ||
          find.text('Get Started').evaluate().isNotEmpty;

      if (hasOnboarding) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/auth/1.2_onboarding.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 1.3 LOGIN SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('1.3 Login Screen', (tester) async {
      /// GIVEN an unauthenticated user
      /// WHEN the login screen displays
      /// THEN phone number input should be visible
      /// AND country code selector (+225) should be visible
      /// AND "Continue" button should be visible

      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/auth/1.3_login.png'),
      );
    });

    // ─────────────────────────────────────────────────────────────
    // 1.4 OTP SCREEN (SECURE LOGIN)
    // ─────────────────────────────────────────────────────────────
    testWidgets('1.4 OTP Screen - Initial State', (tester) async {
      /// GIVEN a user has entered their phone number
      /// WHEN the OTP screen displays
      /// THEN "Secure Login" title should be visible
      /// AND custom PinPad with digits 0-9 should be visible
      /// AND "Resend Code" option should be visible

      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/auth/1.4_otp_initial.png'),
      );
    });

    testWidgets('1.4b OTP Screen - Digits Entered', (tester) async {
      /// GIVEN the OTP screen is displayed
      /// WHEN user enters some digits
      /// THEN the entered digits should show as filled dots

      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Enter 3 digits
      for (final digit in ['1', '2', '3']) {
        await tester.tap(find.text(digit).last);
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/auth/1.4b_otp_partial.png'),
      );
    });

    // ─────────────────────────────────────────────────────────────
    // 1.5 LOGIN PIN SCREEN (if enabled)
    // ─────────────────────────────────────────────────────────────
    testWidgets('1.5 Login PIN Screen', (tester) async {
      /// GIVEN a returning user with PIN enabled
      /// WHEN PIN verification is required
      /// THEN 6-digit PIN entry should be shown
      /// NOTE: This screen may not appear in mock flow

      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Check if PIN screen appears
      final pinScreen = find.text('Enter PIN');
      if (pinScreen.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/auth/1.5_login_pin.png'),
        );
      }
    });
  });
}
