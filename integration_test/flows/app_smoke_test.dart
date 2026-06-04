import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../helpers/korido_flow_driver.dart';
import '../helpers/test_helpers.dart';

/// Smoke test: verifies the app launches and all main tabs/sections
/// are navigable without crashes.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Tests', () {
    setUp(KoridoFlowDriver.resetMocksAndStorage);

    testWidgets('App launches without crashing', (tester) async {
      try {
        final flow = KoridoFlowDriver(tester);
        await flow.launchApp();

        // App should render at least one Scaffold
        expect(find.byType(Scaffold), findsAtLeast(1));
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'smoke_launch_error');
        rethrow;
      }
    });

    testWidgets('Full app launch → login → navigate all tabs', (tester) async {
      try {
        final flow = KoridoFlowDriver(tester);
        await flow.launchApp();
        await flow.completeOnboarding();

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
              await tester.pump(const Duration(milliseconds: 500));

              // Verify no crash — just check Scaffold is still present
              expect(
                find.byType(Scaffold),
                findsAtLeast(1),
                reason: 'App crashed navigating to tab $i',
              );
            }
          }
        }

        // Try navigating to settings
        final settingsIcon = find.byIcon(Icons.settings);
        if (settingsIcon.evaluate().isNotEmpty) {
          await tester.tap(settingsIcon.first);
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.byType(Scaffold), findsAtLeast(1));

          // Go back
          final backButton = find.byType(BackButton);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
            await tester.pump(const Duration(milliseconds: 500));
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
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.byType(Scaffold), findsAtLeast(1));
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'smoke_navigate_error');
        rethrow;
      }
    });

    testWidgets('App renders a stable entry screen on relaunch', (
      tester,
    ) async {
      try {
        final flow = KoridoFlowDriver(tester);
        await flow.launchApp();

        expect(find.byType(Scaffold), findsAtLeast(1));
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'smoke_login_screen_error');
        rethrow;
      }
    });
  });
}
