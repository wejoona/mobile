import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Helper for golden tests in integration tests
class GoldenTestHelper {
  /// Compare current screen with golden image
  /// On first run, creates the golden file
  /// On subsequent runs, compares against saved golden
  static Future<void> matchGolden(
    WidgetTester tester,
    String name, {
    bool skip = false,
  }) async {
    if (skip) return;

    await tester.pumpAndSettle();

    // Use expectLater for golden comparison
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  /// Take a screenshot and save as golden
  /// Use this to update goldens when UI changes intentionally
  static Future<void> updateGolden(
    IntegrationTestWidgetsFlutterBinding binding,
    String name,
  ) async {
    await binding.takeScreenshot('goldens/$name');
  }

  /// Compare specific widget with golden
  static Future<void> matchWidgetGolden(
    WidgetTester tester,
    Finder finder,
    String name,
  ) async {
    await tester.pumpAndSettle();

    await expectLater(
      finder,
      matchesGoldenFile('goldens/$name.png'),
    );
  }
}

/// Extension for easier golden testing
extension GoldenTesterExtension on WidgetTester {
  /// Verify screen matches golden image
  Future<void> matchGolden(String name) async {
    await GoldenTestHelper.matchGolden(this, name);
  }
}
