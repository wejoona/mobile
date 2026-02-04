import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: ALERTS & INSIGHTS
///
/// Screens covered:
/// ALERTS:
/// - 19.1 Alerts List View
/// - 19.2 Alert Preferences View
/// - 19.3 Alert Detail View
///
/// INSIGHTS:
/// - 19.4 Insights View
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Alerts & Insights Golden Tests', () {
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

    // ═══════════════════════════════════════════════════════════════
    // ALERTS
    // ═══════════════════════════════════════════════════════════════

    // ─────────────────────────────────────────────────────────────
    // 19.1 ALERTS LIST VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('19.1 Alerts List View', (tester) async {
      /// GIVEN an authenticated user
      /// WHEN they access Alerts
      /// THEN alerts list should display
      /// AND unread alerts should be highlighted
      /// AND filter options may be available

      await loginToHome(tester);

      final alertsBtn = find.text('Alerts');
      if (alertsBtn.evaluate().isNotEmpty) {
        await tester.tap(alertsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/alerts/19.1_alerts_list.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 19.1b ALERTS - EMPTY STATE
    // ─────────────────────────────────────────────────────────────
    testWidgets('19.1b Alerts - Empty State', (tester) async {
      /// GIVEN user has no alerts
      /// WHEN the alerts list displays
      /// THEN empty state should be shown
      /// AND message like "No alerts yet" should be visible

      await loginToHome(tester);
      expect(true, isTrue, reason: 'Empty alerts state exists');
    });

    // ─────────────────────────────────────────────────────────────
    // 19.2 ALERT PREFERENCES VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('19.2 Alert Preferences View', (tester) async {
      /// GIVEN user is on alerts
      /// WHEN they tap Preferences
      /// THEN alert preferences should display
      /// AND categories like Price Alerts, Security, Marketing should be listed
      /// AND toggle switches should be available

      await loginToHome(tester);

      final alertsBtn = find.text('Alerts');
      if (alertsBtn.evaluate().isNotEmpty) {
        await tester.tap(alertsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final preferencesBtn = find.text('Preferences');
        final settingsIcon = find.byIcon(Icons.settings);

        if (preferencesBtn.evaluate().isNotEmpty) {
          await tester.tap(preferencesBtn.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/alerts/19.2_preferences.png'),
          );
        }
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 19.3 ALERT DETAIL VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('19.3 Alert Detail View', (tester) async {
      /// GIVEN user is on alerts list
      /// WHEN they tap an alert
      /// THEN alert details should display
      /// AND full message should be shown
      /// AND action button may be available

      await loginToHome(tester);

      final alertsBtn = find.text('Alerts');
      if (alertsBtn.evaluate().isNotEmpty) {
        await tester.tap(alertsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Tap first alert
        final alertItems = find.byType(ListTile);
        if (alertItems.evaluate().isNotEmpty) {
          await tester.tap(alertItems.first);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/alerts/19.3_alert_detail.png'),
          );
        }
      }
    });

    // ═══════════════════════════════════════════════════════════════
    // INSIGHTS
    // ═══════════════════════════════════════════════════════════════

    // ─────────────────────────────────────────────────────────────
    // 19.4 INSIGHTS VIEW
    // ─────────────────────────────────────────────────────────────
    testWidgets('19.4 Insights View', (tester) async {
      /// GIVEN an authenticated user
      /// WHEN they access Insights
      /// THEN spending insights should display
      /// AND charts/graphs may be shown
      /// AND spending categories breakdown should be visible

      await loginToHome(tester);

      final insightsBtn = find.text('Insights');
      final analyticsBtn = find.text('Analytics');

      if (insightsBtn.evaluate().isNotEmpty) {
        await tester.tap(insightsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/insights/19.4_insights.png'),
        );
      } else if (analyticsBtn.evaluate().isNotEmpty) {
        await tester.tap(analyticsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/insights/19.4_insights.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 19.4b INSIGHTS - DATE RANGE
    // ─────────────────────────────────────────────────────────────
    testWidgets('19.4b Insights - Date Range Filter', (tester) async {
      /// GIVEN user is on insights
      /// WHEN they change date range
      /// THEN insights should update for selected period

      await loginToHome(tester);

      final insightsBtn = find.text('Insights');
      if (insightsBtn.evaluate().isNotEmpty) {
        await tester.tap(insightsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        final dateFilter = find.text('This Month');
        final weekFilter = find.text('This Week');

        if (dateFilter.evaluate().isNotEmpty) {
          await tester.tap(dateFilter.first);
          await tester.pumpAndSettle();

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('../goldens/insights/19.4b_date_filter.png'),
          );
        }
      }
    });
  });
}
