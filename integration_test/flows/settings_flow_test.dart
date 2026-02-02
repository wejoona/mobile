import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';
import '../robots/settings_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('Settings Flow Tests', () {
    late AuthRobot authRobot;
    late SettingsRobot settingsRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToSettings(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);
      settingsRobot = SettingsRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Login
      await authRobot.completeLogin();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
    }

    testWidgets('Change PIN successfully', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        // Change PIN
        await settingsRobot.changePin(
          TestData.testPin,
          TestData.newPin,
        );

        // Verify success message
        settingsRobot.verifyPinChanged();

        // Change back to original
        await settingsRobot.changePin(
          TestData.newPin,
          TestData.testPin,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'change_pin_error');
        rethrow;
      }
    });

    testWidgets('Enable biometric authentication', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        // Enable biometric
        await settingsRobot.enableBiometric(TestData.testPin);

        // Verify enabled
        settingsRobot.verifyBiometricEnabled();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'enable_biometric_error');
        rethrow;
      }
    });

    testWidgets('Edit profile information', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        // Edit profile
        await settingsRobot.editProfile(
          firstName: 'Updated',
          lastName: 'Name',
        );

        // Verify updated
        settingsRobot.verifyProfileUpdated();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'edit_profile_error');
        rethrow;
      }
    });

    testWidgets('Change language to French', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        // Change to French
        await settingsRobot.changeLanguage('Français');

        // Verify language changed (UI should be in French)
        await tester.pump(const Duration(seconds: 1));

        // Some text should be in French now
        expect(find.text('Paramètres'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'change_language_error');
        rethrow;
      }
    });

    testWidgets('Toggle notification preferences', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        // Toggle transaction notifications
        await settingsRobot.toggleNotification('Transaction Notifications');

        // Wait for state update
        await tester.pump(const Duration(milliseconds: 500));

        // Toggle back
        await settingsRobot.toggleNotification('Transaction Notifications');
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'toggle_notification_error');
        rethrow;
      }
    });

    testWidgets('View security settings', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        await settingsRobot.openSecurity();

        // Verify security options
        settingsRobot.verifyOnSettingsScreen();
        expect(find.text('Change PIN'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'security_settings_error');
        rethrow;
      }
    });

    testWidgets('Search help articles', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        await settingsRobot.openHelp();

        // Search for help
        await settingsRobot.searchHelp('transfer');

        // Wait for search results
        await tester.pump(const Duration(seconds: 1));

        // Should show search results
        expect(find.byType(ListView), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'search_help_error');
        rethrow;
      }
    });

    testWidgets('View device list', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        await settingsRobot.viewDevices();

        // Should show current device
        expect(
          find.textContaining('This device'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'view_devices_error');
        rethrow;
      }
    });

    testWidgets('View active sessions', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        await settingsRobot.viewSessions();

        // Should show current session
        expect(find.text('Active Sessions'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'view_sessions_error');
        rethrow;
      }
    });

    testWidgets('Toggle theme', (tester) async {
      try {
        await loginAndNavigateToSettings(tester);

        // Toggle theme
        await settingsRobot.toggleTheme();

        // Wait for theme change
        await tester.pump(const Duration(seconds: 1));

        // UI should reflect theme change
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'toggle_theme_error');
        rethrow;
      }
    });
  });
}
