import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'dart:io';

/// Common utilities for integration tests
class TestHelpers {
  /// Take a screenshot on test failure
  static Future<void> takeScreenshot(
    IntegrationTestWidgetsFlutterBinding binding,
    String name,
  ) async {
    try {
      await binding.takeScreenshot(name);
    } catch (e) {
      debugPrint('Failed to take screenshot: $e');
    }
  }

  /// Wait for any pending animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// Scroll until a widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
    double delta = 100.0,
    int maxScrolls = 20,
  }) async {
    final scrollableFinder = scrollable ?? find.byType(Scrollable);

    for (int i = 0; i < maxScrolls; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }

      await tester.drag(scrollableFinder, Offset(0, -delta));
      await tester.pumpAndSettle();
    }

    throw Exception('Could not find widget after $maxScrolls scrolls');
  }

  /// Enter text into a field by finding it by label
  static Future<void> enterTextByLabel(
    WidgetTester tester,
    String label,
    String text,
  ) async {
    final finder = find.ancestor(
      of: find.text(label),
      matching: find.byType(TextField),
    );

    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Enter text into a field by key
  static Future<void> enterTextByKey(
    WidgetTester tester,
    Key key,
    String text,
  ) async {
    await tester.enterText(find.byKey(key), text);
    await tester.pumpAndSettle();
  }

  /// Tap a button by text
  static Future<void> tapButtonByText(
    WidgetTester tester,
    String text,
  ) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// Tap a button by key
  static Future<void> tapByKey(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  /// Wait for a widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle();

      if (finder.evaluate().isNotEmpty) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    throw Exception('Widget not found within timeout: $finder');
  }

  /// Wait for a widget to disappear
  static Future<void> waitForWidgetToDisappear(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle();

      if (finder.evaluate().isEmpty) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    throw Exception('Widget still visible after timeout: $finder');
  }

  /// Verify text appears on screen
  static void verifyTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verify text does not appear on screen
  static void verifyTextDoesNotExist(String text) {
    expect(find.text(text), findsNothing);
  }

  /// Verify widget by key exists
  static void verifyKeyExists(Key key) {
    expect(find.byKey(key), findsOneWidget);
  }

  /// Enter PIN digits one by one
  static Future<void> enterPin(
    WidgetTester tester,
    String pin,
  ) async {
    for (int i = 0; i < pin.length; i++) {
      final digit = pin[i];
      await tester.tap(find.text(digit).last);
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();
  }

  /// Dismiss keyboard if open
  static Future<void> dismissKeyboard(WidgetTester tester) async {
    await tester.testTextInput.hide();
    await tester.pumpAndSettle();
  }

  /// Simulate app going to background
  static Future<void> sendToBackground(WidgetTester tester) async {
    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
  }

  /// Simulate app coming to foreground
  static Future<void> bringToForeground(WidgetTester tester) async {
    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  }

  /// Verify navigation to route
  static void verifyRoute(BuildContext context, String expectedRoute) {
    // This would need access to GoRouter context
    // For now, we verify by checking for screen-specific widgets
  }

  /// Wait for loading indicator to disappear
  static Future<void> waitForLoadingToComplete(WidgetTester tester) async {
    await waitForWidgetToDisappear(
      tester,
      find.byType(CircularProgressIndicator),
    );
  }

  /// Tap back button
  static Future<void> tapBackButton(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  /// Pull to refresh
  static Future<void> pullToRefresh(WidgetTester tester) async {
    await tester.drag(
      find.byType(RefreshIndicator),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
  }

  /// Clear app data (for fresh test runs)
  static Future<void> clearAppData() async {
    // This would clear SharedPreferences, SecureStorage, etc.
    // Implementation depends on having access to those services
  }

  /// Generate realistic West African test data
  static Map<String, dynamic> getTestUser() {
    return {
      'firstName': 'Amadou',
      'lastName': 'Diallo',
      'phone': '+225 07 12 34 56 78',
      'countryCode': '+225',
      'phoneNumber': '0712345678',
    };
  }

  static String getTestPin() => '123456';

  static String getTestOtp() => '123456';

  static Map<String, dynamic> getTestRecipient() {
    return {
      'name': 'Fatou Traore',
      'phone': '+225 07 98 76 54 32',
    };
  }

  /// Delay for visual debugging
  static Future<void> delay([Duration duration = const Duration(seconds: 1)]) async {
    await Future.delayed(duration);
  }
}

/// Extension methods for WidgetTester
extension TestHelpersExtension on WidgetTester {
  Future<void> tapByText(String text) async {
    await tap(find.text(text));
    await pumpAndSettle();
  }

  Future<void> tapByKey(Key key) async {
    await tap(find.byKey(key));
    await pumpAndSettle();
  }

  Future<void> enterTextByLabel(String label, String text) async {
    await TestHelpers.enterTextByLabel(this, label, text);
  }

  Future<void> waitForText(String text) async {
    await TestHelpers.waitForWidget(this, find.text(text));
  }

  Future<void> enterPin(String pin) async {
    await TestHelpers.enterPin(this, pin);
  }
}
