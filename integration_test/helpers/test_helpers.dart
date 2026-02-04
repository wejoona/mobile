import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/services/kyc/kyc_mock.dart';
import 'dart:io';
import 'dart:typed_data';

/// Check if tests should use mocks (set via --dart-define=USE_MOCKS=true/false)
const bool useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: true);

/// Common utilities for integration tests
class TestHelpers {
  /// Configure mocks based on dart-define flag
  /// Call this in setUpAll() instead of MockConfig.enableAllMocks()
  static void configureMocks() {
    if (useMocks) {
      MockConfig.enableAllMocks();
    } else {
      MockConfig.disableAllMocks();
    }
  }

  /// Set KYC status (only when using mocks)
  /// When using real backend, the test user should already have the expected KYC status
  static void setKycStatus(String status) {
    if (useMocks) {
      KycMockState.setStatus(status);
    }
    // When using real backend, we expect the test user to already have the correct status
  }
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
    // Unfocus any focused widget to dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();
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

  /// Create a test image file for KYC document testing
  /// Returns the path to the created test image
  static Future<String> createTestImage({String filename = 'test_document.jpg'}) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/$filename';

    // Create a simple valid JPEG image (1x1 red pixel)
    // This is a minimal valid JPEG that will pass basic file validation
    final bytes = Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
      0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
      0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
      0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
      0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
      0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
      0x09, 0x0A, 0x0B, 0xFF, 0xC4, 0x00, 0xB5, 0x10, 0x00, 0x02, 0x01, 0x03,
      0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04, 0x04, 0x00, 0x00, 0x01, 0x7D,
      0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06,
      0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xA1, 0x08,
      0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0, 0x24, 0x33, 0x62, 0x72,
      0x82, 0x09, 0x0A, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28,
      0x29, 0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x43, 0x44, 0x45,
      0x46, 0x47, 0x48, 0x49, 0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
      0x5A, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x73, 0x74, 0x75,
      0x76, 0x77, 0x78, 0x79, 0x7A, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
      0x8A, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3,
      0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6,
      0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
      0xCA, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xE1, 0xE2,
      0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xF1, 0xF2, 0xF3, 0xF4,
      0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01,
      0x00, 0x00, 0x3F, 0x00, 0xFB, 0xD5, 0xDB, 0x20, 0xA8, 0xF1, 0x4C, 0xF1,
      0x4C, 0xF1, 0x4C, 0xF1, 0x4C, 0xF1, 0x4C, 0xF1, 0x4C, 0xF1, 0x4C, 0xF1,
      0xFF, 0xD9,
    ]);

    final file = File(imagePath);
    await file.writeAsBytes(bytes);

    return imagePath;
  }

  /// Setup mock image picker to return a test image
  /// Call this in test setUp before running KYC tests
  static void setupMockImagePicker(String testImagePath) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'pickImage') {
          return testImagePath;
        }
        return null;
      },
    );
  }

  /// Setup mock image picker for multiple images (KYC flow)
  /// Provides different images for front, back, selfie
  static void setupMockImagePickerWithPaths(List<String> imagePaths) {
    int callIndex = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'pickImage') {
          final path = imagePaths[callIndex % imagePaths.length];
          callIndex++;
          return path;
        }
        return null;
      },
    );
  }

  /// Clear mock image picker
  static void clearMockImagePicker() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      null,
    );
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
