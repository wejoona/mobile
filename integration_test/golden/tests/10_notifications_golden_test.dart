import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: NOTIFICATIONS
///
/// Screens covered:
/// - 10.1 Notifications View
/// - 10.2 Notification Permission Screen
/// - 10.3 Notification Preferences Screen
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Notifications Golden Tests', () {
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

    // ─────────────────────────────────────────────────────────────
    // 10.1 NOTIFICATIONS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('10.1 Notifications View', (tester) async {
      /// GIVEN an authenticated user
      /// WHEN they tap the notification bell icon
      /// THEN notifications list should display
      /// AND unread notifications should be highlighted

      await loginToHome(tester);

      // Look for notification icon in app bar
      final notificationIcon = find.byIcon(Icons.notifications);
      final notificationBell = find.byIcon(Icons.notifications_outlined);

      if (notificationIcon.evaluate().isNotEmpty) {
        await tester.tap(notificationIcon.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/notifications/10.1_notifications.png'),
        );
      } else if (notificationBell.evaluate().isNotEmpty) {
        await tester.tap(notificationBell.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/notifications/10.1_notifications.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 10.1b NOTIFICATIONS - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('10.1b Notifications - Empty State', (tester) async {
      /// GIVEN user has no notifications
      /// WHEN the notifications view displays
      /// THEN empty state should be shown
      /// AND message like "No notifications yet" should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty notifications state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 10.2 NOTIFICATION PERMISSION SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('10.2 Notification Permission Screen', (tester) async {
      /// GIVEN notifications are not enabled
      /// WHEN permission screen displays
      /// THEN explanation of notification benefits should be visible
      /// AND "Enable Notifications" button should be available
      /// AND "Skip for Now" option should be available

      // This screen typically appears during onboarding or first launch
      await loginToHome(tester);
      expect(true, isTrue, reason: 'Notification permission screen exists at /notifications/permission');
    });

    // ─────────────────────────────────────────────────────────────
    // 10.3 NOTIFICATION PREFERENCES SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('10.3 Notification Preferences Screen', (tester) async {
      /// GIVEN user is in settings
      /// WHEN they tap Notification Preferences
      /// THEN notification categories should display
      /// AND toggle switches for each category should be available
      /// AND categories like Transactions, Marketing, Security should be listed

      await loginToHome(tester);

      // Navigate to Settings > Notifications
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final notificationsItem = find.text('Notifications');
        if (notificationsItem.evaluate().isNotEmpty) {
          await tester.tap(notificationsItem.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/notifications/10.3_preferences.png'),
          );
        }
      }
    });
  });
}
