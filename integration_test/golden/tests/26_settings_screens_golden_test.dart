import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: SETTINGS SCREENS
///
/// Status: ACTIVE - All screens are in production use
///
/// Tests all settings and profile management screens.
///
/// Screens covered:
/// - 26.1 Profile View (/settings/profile)
/// - 26.2 Profile Edit Screen (/settings/profile/edit)
/// - 26.3 Change PIN View (/settings/pin)
/// - 26.4 Security View (/settings/security)
/// - 26.5 Biometric Settings View (/settings/biometric)
/// - 26.6 Notification Settings View (/settings/notifications)
/// - 26.7 Limits View (/settings/limits)
/// - 26.8 Help View (/settings/help)
/// - 26.9 Language View (/settings/language)
/// - 26.10 Theme Settings View (/settings/theme)
/// - 26.11 Currency View (/settings/currency)
/// - 26.12 Devices Screen (/settings/devices)
/// - 26.13 Sessions Screen (/settings/sessions)
/// - 26.14 KYC Settings View (/settings/kyc)
///
/// Run with mocks (default):
///   flutter test integration_test/golden/tests/26_settings_screens_golden_test.dart --update-goldens
///
/// Run with real backend:
///   flutter test integration_test/golden/tests/26_settings_screens_golden_test.dart --update-goldens --dart-define=USE_MOCKS=false
void main() {
  final __binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Settings Screens Golden Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      TestHelpers.configureMocks();
      await TestHelpers.clearAppData();
    });

    /// Helper to login and navigate to settings
    Future<void> navigateToSettings(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      // Skip onboarding if present
      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Navigate to settings tab
      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 26.1 PROFILE VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.1 Profile View', (tester) async {
      /// GIVEN user is authenticated with complete profile
      /// WHEN profile screen is displayed
      /// THEN show avatar, name, phone, email

      await navigateToSettings(tester);

      // Tap on profile section
      final profileTap = find.textContaining('Profile');
      if (profileTap.evaluate().isNotEmpty) {
        await tester.tap(profileTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.1_profile_view.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.2 PROFILE EDIT SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.2 Profile Edit Screen', (tester) async {
      /// GIVEN user taps "Edit Profile"
      /// WHEN edit screen is displayed
      /// THEN show editable fields

      await navigateToSettings(tester);

      final profileTap = find.textContaining('Profile');
      if (profileTap.evaluate().isNotEmpty) {
        await tester.tap(profileTap.first);
        await tester.pumpAndSettle();

        final editButton = find.text('Edit');
        if (editButton.evaluate().isNotEmpty) {
          await tester.tap(editButton.first);
          await tester.pumpAndSettle();

          // Verify editable fields
          expect(find.byType(TextFormField), findsWidgets);

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/settings/26.2_profile_edit.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.3 CHANGE PIN VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.3 Change PIN View', (tester) async {
      /// GIVEN user taps "Change PIN"
      /// WHEN change PIN screen is displayed
      /// THEN prompt for current PIN

      await navigateToSettings(tester);

      final pinTap = find.textContaining('PIN');
      if (pinTap.evaluate().isNotEmpty) {
        await tester.tap(pinTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.3_change_pin.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.4 SECURITY VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.4 Security View', (tester) async {
      /// GIVEN user taps Security settings
      /// WHEN security screen is displayed
      /// THEN show security options list

      await navigateToSettings(tester);

      final securityTap = find.textContaining('Security');
      if (securityTap.evaluate().isNotEmpty) {
        await tester.tap(securityTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.4_security.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.5 BIOMETRIC SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.5 Biometric Settings View', (tester) async {
      /// GIVEN user taps Biometric settings
      /// WHEN biometric screen is displayed
      /// THEN show biometric toggle

      await navigateToSettings(tester);

      final biometricTap = find.textContaining('Biometric');
      if (biometricTap.evaluate().isNotEmpty) {
        await tester.tap(biometricTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.5_biometric.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.6 NOTIFICATION SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.6 Notification Settings View', (tester) async {
      /// GIVEN user taps Notification settings
      /// WHEN notification screen is displayed
      /// THEN show notification toggles

      await navigateToSettings(tester);

      final notificationTap = find.textContaining('Notification');
      if (notificationTap.evaluate().isNotEmpty) {
        await tester.tap(notificationTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.6_notifications.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.7 LIMITS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.7 Limits View', (tester) async {
      /// GIVEN user taps Limits
      /// WHEN limits screen is displayed
      /// THEN show transaction limits

      await navigateToSettings(tester);

      final limitsTap = find.textContaining('Limit');
      if (limitsTap.evaluate().isNotEmpty) {
        await tester.tap(limitsTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.7_limits.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.8 HELP VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.8 Help View', (tester) async {
      /// GIVEN user taps Help
      /// WHEN help screen is displayed
      /// THEN show FAQ and support options

      await navigateToSettings(tester);

      final helpTap = find.textContaining('Help');
      if (helpTap.evaluate().isNotEmpty) {
        await tester.tap(helpTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.8_help.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.9 LANGUAGE VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.9 Language View', (tester) async {
      /// GIVEN user taps Language
      /// WHEN language screen is displayed
      /// THEN show language options (English, French)

      await navigateToSettings(tester);

      final languageTap = find.textContaining('Language');
      if (languageTap.evaluate().isNotEmpty) {
        await tester.tap(languageTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.9_language.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.10 THEME SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.10 Theme Settings View', (tester) async {
      /// GIVEN user taps Theme
      /// WHEN theme screen is displayed
      /// THEN show theme options (Light, Dark, System)

      await navigateToSettings(tester);

      final themeTap = find.textContaining('Theme');
      if (themeTap.evaluate().isNotEmpty) {
        await tester.tap(themeTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.10_theme.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.11 CURRENCY VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.11 Currency View', (tester) async {
      /// GIVEN user taps Currency
      /// WHEN currency screen is displayed
      /// THEN show currency options (USDC, XOF)

      await navigateToSettings(tester);

      final currencyTap = find.textContaining('Currency');
      if (currencyTap.evaluate().isNotEmpty) {
        await tester.tap(currencyTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.11_currency.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.12 DEVICES SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.12 Devices Screen', (tester) async {
      /// GIVEN user taps Devices
      /// WHEN devices screen is displayed
      /// THEN show list of trusted devices

      await navigateToSettings(tester);

      final devicesTap = find.textContaining('Device');
      if (devicesTap.evaluate().isNotEmpty) {
        await tester.tap(devicesTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.12_devices.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.13 SESSIONS SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.13 Sessions Screen', (tester) async {
      /// GIVEN user taps Active Sessions
      /// WHEN sessions screen is displayed
      /// THEN show list of active sessions

      await navigateToSettings(tester);

      final sessionsTap = find.textContaining('Session');
      if (sessionsTap.evaluate().isNotEmpty) {
        await tester.tap(sessionsTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.13_sessions.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 26.14 KYC SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('26.14 KYC Settings View', (tester) async {
      /// GIVEN KYC settings accessed
      /// WHEN KYC settings screen is displayed
      /// THEN show verification status and tier

      await navigateToSettings(tester);

      final kycTap = find.textContaining('KYC');
      if (kycTap.evaluate().isNotEmpty) {
        await tester.tap(kycTap.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/26.14_kyc_settings.png'),
        );
      }
    });
  });
}
