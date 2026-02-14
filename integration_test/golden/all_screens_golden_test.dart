import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';

/// Captures ALL screens in the app flow
/// Run with: flutter test integration_test/golden/all_screens_golden_test.dart --update-goldens
void main() {
  final _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => MockConfig.enableAllMocks());

  group('All Screens Golden Capture', () {
    late AuthRobot authRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('01 - Login Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if present
      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/01_login.png'),
      );
    });

    testWidgets('02 - OTP Screen (Secure Login)', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Enter phone number
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/02_otp_secure_login.png'),
      );
    });

    testWidgets('03 - Identity Verification Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login (phone + OTP)
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Enter OTP digits
      await authRobot.enterOtp(TestData.testOtp);

      // Wait for auth to complete and navigate
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on Identity Verification screen
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/03_identity_verification.png'),
      );
    });

    testWidgets('04 - Document Type Selection Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Find "Start Verification" button - it's in an AppButton at the bottom
      // The text appears twice: once as heading, once in button
      final startVerificationBtn = find.widgetWithText(ElevatedButton, 'Start Verification');
      if (startVerificationBtn.evaluate().isEmpty) {
        // Fallback: find by text and tap last occurrence (the button)
        final startText = find.text('Start Verification');
        await tester.tap(startText.last);
      } else {
        await tester.tap(startVerificationBtn);
      }
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/04_document_type_selection.png'),
      );
    });

    testWidgets('05 - Document Type Selected (National ID)', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Tap "Start Verification" button
      final startText = find.text('Start Verification');
      await tester.tap(startText.last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Select "National ID Card"
      final nationalId = find.text('National ID Card');
      await tester.tap(nationalId);
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/05_national_id_selected.png'),
      );
    });

    testWidgets('06 - Personal Info Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Tap "Start Verification"
      final startText = find.text('Start Verification');
      await tester.tap(startText.last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Select document type
      final nationalId = find.text('National ID Card');
      await tester.tap(nationalId);
      await tester.pumpAndSettle();

      // Tap Continue
      final continueBtn = find.text('Continue');
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/06_personal_info.png'),
      );
    });

    testWidgets('07 - Personal Info Filled', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to document type
      final startText = find.text('Start Verification');
      await tester.tap(startText.last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Select National ID Card
      await tester.tap(find.text('National ID Card'));
      await tester.pumpAndSettle();

      // Continue to Personal Info
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Fill First Name
      final firstNameField = find.byType(TextField).first;
      await tester.enterText(firstNameField, 'Amadou');
      await tester.pumpAndSettle();

      // Fill Last Name
      final lastNameField = find.byType(TextField).at(1);
      await tester.enterText(lastNameField, 'Diallo');
      await tester.pumpAndSettle();

      // Tap date picker
      final datePicker = find.text('Select date');
      await tester.tap(datePicker);
      await tester.pumpAndSettle();

      // Select a date (tap OK)
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/07_personal_info_filled.png'),
      );
    });

    testWidgets('08 - Document Capture Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate through KYC flow
      final startText = find.text('Start Verification');
      await tester.tap(startText.last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Select National ID Card
      await tester.tap(find.text('National ID Card'));
      await tester.pumpAndSettle();

      // Continue to Personal Info
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Fill form
      final firstNameField = find.byType(TextField).first;
      await tester.enterText(firstNameField, 'Amadou');
      await tester.pumpAndSettle();

      final lastNameField = find.byType(TextField).at(1);
      await tester.enterText(lastNameField, 'Diallo');
      await tester.pumpAndSettle();

      // Tap date picker and select date
      final datePicker = find.text('Select date');
      await tester.tap(datePicker);
      await tester.pumpAndSettle();

      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      // Continue to Document Capture
      final continueBtn = find.text('Continue');
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/08_document_capture.png'),
      );
    });

    testWidgets('09 - Document Capture Camera/Gallery', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate through KYC flow
      final startText = find.text('Start Verification');
      await tester.tap(startText.last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Select National ID Card
      await tester.tap(find.text('National ID Card'));
      await tester.pumpAndSettle();

      // Continue to Personal Info
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Fill form
      final firstNameField = find.byType(TextField).first;
      await tester.enterText(firstNameField, 'Amadou');
      await tester.pumpAndSettle();

      final lastNameField = find.byType(TextField).at(1);
      await tester.enterText(lastNameField, 'Diallo');
      await tester.pumpAndSettle();

      // Tap date picker and select date
      final datePicker = find.text('Select date');
      await tester.tap(datePicker);
      await tester.pumpAndSettle();

      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      // Continue to Document Capture instructions
      var continueBtn = find.text('Continue');
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Continue from instructions to camera/gallery
      continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/09_document_capture_camera.png'),
      );
    });

    testWidgets('10 - Home Screen (after skip KYC)', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Look for Skip or later button on KYC screen
      final skipKyc = find.text('Skip');
      final later = find.text('Later');
      final skipForNow = find.text('Skip for now');

      if (skipKyc.evaluate().isNotEmpty) {
        await tester.tap(skipKyc);
        await tester.pumpAndSettle();
      } else if (later.evaluate().isNotEmpty) {
        await tester.tap(later);
        await tester.pumpAndSettle();
      } else if (skipForNow.evaluate().isNotEmpty) {
        await tester.tap(skipForNow);
        await tester.pumpAndSettle();
      }

      // Navigate to Home tab if available
      final homeTab = find.text('Home');
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/07_home.png'),
      );
    });

    testWidgets('08 - Settings Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      authRobot = AuthRobot(tester);

      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      // Complete login
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Navigate to Settings tab
      final settingsTab = find.text('Settings');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/screens/08_settings.png'),
        );
      }
    });
  });
}
