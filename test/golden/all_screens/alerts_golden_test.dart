// Golden tests for Alerts feature screens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/alerts/views/alert_detail_view.dart';
import 'package:usdc_wallet/features/alerts/views/alert_preferences_view.dart';
import 'package:usdc_wallet/features/alerts/views/alerts_list_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('AlertsListView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: AlertsListView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/alerts/alerts_list/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: AlertsListView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/alerts/alerts_list/default_dark.png'),
      );
    });
  });

  group('AlertPreferencesView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: AlertPreferencesView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/alerts/alert_preferences/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: AlertPreferencesView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/alerts/alert_preferences/default_dark.png'),
      );
    });
  });

  group('AlertDetailView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: AlertDetailView(alertId: 'alert_001'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/alerts/alert_detail/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: AlertDetailView(alertId: 'alert_001'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/alerts/alert_detail/default_dark.png'),
      );
    });
  });
}
