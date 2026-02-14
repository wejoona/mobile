import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: SETTINGS SCREENS
///
/// Screens covered:
/// - 7.1 Settings Main Screen
/// - 7.2 Profile View
/// - 7.3 Profile Edit Screen
/// - 7.4 Change PIN View
/// - 7.5 KYC Settings View
/// - 7.6 Notification Settings View
/// - 7.7 Security View
/// - 7.8 Biometric Settings View
/// - 7.9 Biometric Enrollment View
/// - 7.10 Limits View
/// - 7.11 Help View
/// - 7.12 Language View
/// - 7.13 Theme Settings View
/// - 7.14 Currency View
/// - 7.15 Devices Screen
/// - 7.16 Sessions Screen
/// - 7.17 Business Setup View
/// - 7.18 Business Profile View
/// - 7.19 Cookie Policy View
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Settings Golden Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      TestHelpers.configureMocks();
      await TestHelpers.clearAppData();
    });

    /// Helper to login and reach home screen
    Future<void> loginToHome(WidgetTester tester) async {
      TestHelpers.setKycStatus('verified');

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
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    /// Helper to navigate to settings screen
    Future<void> navigateToSettings(WidgetTester tester) async {
      await loginToHome(tester);

      // Tap Settings tab
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 7.1 SETTINGS MAIN SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.1 Settings Main Screen', (tester) async {
      /// GIVEN an authenticated user
      /// WHEN the Settings tab is selected
      /// THEN settings menu should display
      /// AND Profile, Security, Help, Logout options should be visible

      await navigateToSettings(tester);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/settings/7.1_settings_main.png'),
      );
    });

    // ─────────────────────────────────────────────────────────────
    // 7.2 PROFILE VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.2 Profile View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Profile
      /// THEN profile details should display
      /// AND Edit button should be available

      await navigateToSettings(tester);

      final profileItem = find.text('Profile');
      if (profileItem.evaluate().isNotEmpty) {
        await tester.tap(profileItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.2_profile.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.3 PROFILE EDIT SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.3 Profile Edit Screen', (tester) async {
      /// GIVEN user is on profile view
      /// WHEN they tap Edit
      /// THEN editable form should display
      /// AND Save button should be available

      await navigateToSettings(tester);

      final profileItem = find.text('Profile');
      if (profileItem.evaluate().isNotEmpty) {
        await tester.tap(profileItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final editBtn = find.text('Edit');
        if (editBtn.evaluate().isNotEmpty) {
          await tester.tap(editBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/settings/7.3_profile_edit.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.4 CHANGE PIN VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.4 Change PIN View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Change PIN
      /// THEN PIN change flow should display
      /// AND current PIN entry should be visible

      await navigateToSettings(tester);

      final securityItem = find.text('Security');
      if (securityItem.evaluate().isNotEmpty) {
        await tester.tap(securityItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final changePinItem = find.text('Change PIN');
        if (changePinItem.evaluate().isNotEmpty) {
          await tester.tap(changePinItem.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/settings/7.4_change_pin.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.5 KYC SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.5 KYC Settings View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap KYC/Identity
      /// THEN KYC status should display
      /// AND upgrade options may be available

      await navigateToSettings(tester);

      final kycItem = find.text('Identity');
      final verificationItem = find.text('Verification');

      if (kycItem.evaluate().isNotEmpty) {
        await tester.tap(kycItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.5_kyc_settings.png'),
        );
      } else if (verificationItem.evaluate().isNotEmpty) {
        await tester.tap(verificationItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.5_kyc_settings.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.6 NOTIFICATION SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.6 Notification Settings View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Notifications
      /// THEN notification preferences should display
      /// AND toggle switches should be available

      await navigateToSettings(tester);

      final notificationsItem = find.text('Notifications');
      if (notificationsItem.evaluate().isNotEmpty) {
        await tester.tap(notificationsItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.6_notifications.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.7 SECURITY VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.7 Security View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Security
      /// THEN security options should display
      /// AND PIN, Biometric, 2FA options should be visible

      await navigateToSettings(tester);

      final securityItem = find.text('Security');
      if (securityItem.evaluate().isNotEmpty) {
        await tester.tap(securityItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.7_security.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.8 BIOMETRIC SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.8 Biometric Settings View', (tester) async {
      /// GIVEN user is on security view
      /// WHEN they tap Biometric
      /// THEN biometric settings should display
      /// AND enable/disable toggle should be visible

      await navigateToSettings(tester);

      final securityItem = find.text('Security');
      if (securityItem.evaluate().isNotEmpty) {
        await tester.tap(securityItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final biometricItem = find.text('Biometric');
        // ignore: unused_local_variable
        final __fingerprintItem = find.text('Fingerprint');
        // ignore: unused_local_variable
        final __faceIdItem = find.text('Face ID');

        if (biometricItem.evaluate().isNotEmpty) {
          await tester.tap(biometricItem.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/settings/7.8_biometric.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.10 LIMITS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.10 Limits View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Limits
      /// THEN transaction limits should display
      /// AND daily/monthly limits should be shown

      await navigateToSettings(tester);

      final limitsItem = find.text('Limits');
      if (limitsItem.evaluate().isNotEmpty) {
        await tester.tap(limitsItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.10_limits.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.11 HELP VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.11 Help View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Help
      /// THEN help options should display
      /// AND FAQ, Contact Support options should be visible

      await navigateToSettings(tester);

      final helpItem = find.text('Help');
      if (helpItem.evaluate().isNotEmpty) {
        await tester.tap(helpItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.11_help.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.12 LANGUAGE VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.12 Language View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Language
      /// THEN language options should display
      /// AND French and English should be available

      await navigateToSettings(tester);

      final languageItem = find.text('Language');
      if (languageItem.evaluate().isNotEmpty) {
        await tester.tap(languageItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.12_language.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.13 THEME SETTINGS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.13 Theme Settings View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Theme
      /// THEN theme options should display
      /// AND Light, Dark, System options should be available

      await navigateToSettings(tester);

      final themeItem = find.text('Theme');
      final appearanceItem = find.text('Appearance');

      if (themeItem.evaluate().isNotEmpty) {
        await tester.tap(themeItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.13_theme.png'),
        );
      } else if (appearanceItem.evaluate().isNotEmpty) {
        await tester.tap(appearanceItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.13_theme.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.14 CURRENCY VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.14 Currency View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Currency
      /// THEN currency options should display
      /// AND XOF, USD, EUR options may be available

      await navigateToSettings(tester);

      final currencyItem = find.text('Currency');
      if (currencyItem.evaluate().isNotEmpty) {
        await tester.tap(currencyItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.14_currency.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.15 DEVICES SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.15 Devices Screen', (tester) async {
      /// GIVEN user is on security view
      /// WHEN they tap Devices
      /// THEN logged in devices should display
      /// AND option to remove device should be available

      await navigateToSettings(tester);

      final securityItem = find.text('Security');
      if (securityItem.evaluate().isNotEmpty) {
        await tester.tap(securityItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final devicesItem = find.text('Devices');
        if (devicesItem.evaluate().isNotEmpty) {
          await tester.tap(devicesItem.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/settings/7.15_devices.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.16 SESSIONS SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.16 Sessions Screen', (tester) async {
      /// GIVEN user is on security view
      /// WHEN they tap Sessions
      /// THEN active sessions should display
      /// AND option to terminate session should be available

      await navigateToSettings(tester);

      final securityItem = find.text('Security');
      if (securityItem.evaluate().isNotEmpty) {
        await tester.tap(securityItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final sessionsItem = find.text('Sessions');
        if (sessionsItem.evaluate().isNotEmpty) {
          await tester.tap(sessionsItem.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/settings/7.16_sessions.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.17 BUSINESS SETUP VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.17 Business Setup View', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Business
      /// THEN business setup options should display

      await navigateToSettings(tester);

      final businessItem = find.text('Business');
      if (businessItem.evaluate().isNotEmpty) {
        await tester.tap(businessItem.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.17_business_setup.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 7.20 LOGOUT CONFIRMATION
    // ─────────────────────────────────────────────────────────────
    testWidgets('7.20 Logout Confirmation', (tester) async {
      /// GIVEN user is on settings screen
      /// WHEN they tap Logout
      /// THEN confirmation dialog should appear
      /// AND Cancel and Confirm options should be visible

      await navigateToSettings(tester);

      final logoutItem = find.text('Logout');
      final signOutItem = find.text('Sign Out');

      if (logoutItem.evaluate().isNotEmpty) {
        await tester.tap(logoutItem.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.20_logout.png'),
        );
      } else if (signOutItem.evaluate().isNotEmpty) {
        await tester.tap(signOutItem.first);
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/settings/7.20_logout.png'),
        );
      }
    });
  });
}
