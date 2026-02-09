import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../robots/auth_robot.dart';

/// Smoke test: verifies the app launches and all main tabs/sections
/// are navigable without crashes.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
    MockConfig.networkDelayMs = 0;
  });

  group('App Smoke Tests', () {
    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('App launches without crashing', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        // App should render at least one Scaffold
        expect(find.byType(Scaffold), findsAtLeast(1));
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'smoke_launch_error');
        rethrow;
      }
    });

    testWidgets('Full app launch → login → navigate all tabs', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        final authRobot = AuthRobot(tester);

        // Skip onboarding if present
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Complete login
        await authRobot.completeLogin();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));

        // Verify we're on the home/wallet screen
        authRobot.verifyOnHomeScreen();

        // Try navigating bottom navigation tabs
        final bottomNav = find.byType(BottomNavigationBar);
        if (bottomNav.evaluate().isNotEmpty) {
          final navBar =
              bottomNav.evaluate().first.widget as BottomNavigationBar;

          // Tap each tab (skip first since we're already there)
          for (int i = 1; i < navBar.items.length; i++) {
            // Find the tab icons in the bottom nav
            final icons = find.descendant(
              of: bottomNav,
              matching: find.byType(InkResponse),
            );
            if (icons.evaluate().length > i) {
              await tester.tap(icons.at(i));
              await tester.pumpAndSettle();

              // Verify no crash — just check Scaffold is still present
              expect(find.byType(Scaffold), findsAtLeast(1),
                  reason: 'App crashed navigating to tab $i');
            }
          }
        }

        // Try navigating to settings
        final settingsIcon = find.byIcon(Icons.settings);
        if (settingsIcon.evaluate().isNotEmpty) {
          await tester.tap(settingsIcon.first);
          await tester.pumpAndSettle();
          expect(find.byType(Scaffold), findsAtLeast(1));

          // Go back
          final backButton = find.byType(BackButton);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
            await tester.pumpAndSettle();
          }
        }

        // Try navigating to notifications
        final notifIcon = find.byIcon(Icons.notifications);
        final notifOutlined = find.byIcon(Icons.notifications_outlined);
        final notifFinder = notifIcon.evaluate().isNotEmpty
            ? notifIcon
            : notifOutlined;
        if (notifFinder.evaluate().isNotEmpty) {
          await tester.tap(notifFinder.first);
          await tester.pumpAndSettle();
          expect(find.byType(Scaffold), findsAtLeast(1));
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'smoke_navigate_error');
        rethrow;
      }
    });

    testWidgets('App renders login screen when unauthenticated', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        // Should see either onboarding or login
        final hasLoginIndicator =
            find.textContaining(RegExp(r'Log in|Sign in|Phone|Welcome')).evaluate().isNotEmpty ||
            find.textContaining('Skip').evaluate().isNotEmpty;

        expect(hasLoginIndicator, isTrue,
            reason: 'Expected login or onboarding screen when unauthenticated');
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'smoke_login_screen_error');
        rethrow;
      }
    });
  });
}
