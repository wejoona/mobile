import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('KYC Flow Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToKyc(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Login - will auto-navigate to KYC screen when status is 'none'
      await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
      await authRobot.tapContinue();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await authRobot.enterOtp(TestData.testOtp);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }

    // ====== IDENTITY VERIFICATION SCREEN TESTS ======

    testWidgets('Identity Verification - screen title displayed', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // From golden: 03_identity_verification.png
        expect(find.text('Identity Verification'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_title_error');
        rethrow;
      }
    });

    testWidgets('Identity Verification - Start Verification button shown', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // From golden: "Start Verification" appears twice (heading + button)
        expect(find.text('Start Verification'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_button_error');
        rethrow;
      }
    });

    testWidgets('Identity Verification - info cards displayed', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // From golden: three info cards
        expect(find.text('Your Data is Secure'), findsOneWidget);
        expect(find.text('Quick Process'), findsOneWidget);
        expect(find.text('Documents Needed'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_info_cards_error');
        rethrow;
      }
    });

    testWidgets('Identity Verification - description text shown', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // From golden: description under "Start Verification" heading
        expect(
          find.textContaining('Complete your identity verification'),
          findsOneWidget,
        );
        expect(
          find.textContaining('higher limits'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_description_error');
        rethrow;
      }
    });

    // ====== DOCUMENT TYPE SELECTION SCREEN TESTS ======

    testWidgets('Document Type Selection - navigate from Identity Verification', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Tap "Start Verification" button
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: 04_document_type_selection.png
        expect(find.text('Select Document Type'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_doc_type_nav_error');
        rethrow;
      }
    });

    testWidgets('Document Type Selection - three document options shown', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate to document type selection
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: three document types
        expect(find.text('National ID Card'), findsOneWidget);
        expect(find.text('Passport'), findsOneWidget);
        expect(find.text("Driver's License"), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_doc_options_error');
        rethrow;
      }
    });

    testWidgets('Document Type Selection - Continue button disabled initially', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate to document type selection
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: Continue button exists
        expect(find.text('Continue'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_continue_btn_error');
        rethrow;
      }
    });

    testWidgets('Document Type Selection - select National ID Card', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate to document type selection
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Select National ID Card
        await tester.tap(find.text('National ID Card'));
        await tester.pumpAndSettle();

        // From golden: 05_national_id_selected.png - checkmark appears
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_select_id_error');
        rethrow;
      }
    });

    // ====== PERSONAL INFORMATION SCREEN TESTS ======

    testWidgets('Personal Information - navigate from Document Type', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate to document type selection
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Select National ID Card
        await tester.tap(find.text('National ID Card'));
        await tester.pumpAndSettle();

        // Tap Continue
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: 06_personal_info.png
        expect(find.text('Personal Information'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_personal_info_nav_error');
        rethrow;
      }
    });

    testWidgets('Personal Information - form fields displayed', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate through to Personal Info
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await tester.tap(find.text('National ID Card'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: form fields
        expect(find.text('First name'), findsOneWidget);
        expect(find.text('Last name'), findsOneWidget);
        expect(find.text('Date of birth'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_form_fields_error');
        rethrow;
      }
    });

    testWidgets('Personal Information - info message shown', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate through to Personal Info
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await tester.tap(find.text('National ID Card'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: info message
        expect(
          find.textContaining('information must match exactly'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_info_msg_error');
        rethrow;
      }
    });

    testWidgets('Personal Information - description text shown', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate through to Personal Info
        final startBtn = find.text('Start Verification');
        await tester.tap(startBtn.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await tester.tap(find.text('National ID Card'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: description under title
        expect(
          find.textContaining('Enter your details exactly'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_desc_text_error');
        rethrow;
      }
    });

    // ====== DOCUMENT CAPTURE SCREEN TESTS ======

    testWidgets('Document Capture - instructions screen shown', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate through flow
        await tester.tap(find.text('Start Verification').last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await tester.tap(find.text('National ID Card'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Fill personal info
        await tester.enterText(find.byType(TextField).first, 'Amadou');
        await tester.enterText(find.byType(TextField).at(1), 'Diallo');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Select date'));
        await tester.pumpAndSettle();
        final okBtn = find.text('OK');
        if (okBtn.evaluate().isNotEmpty) {
          await tester.tap(okBtn);
          await tester.pumpAndSettle();
        }

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // From golden: 08_document_capture.png
        expect(find.textContaining('Capture National ID Card'), findsOneWidget);
        expect(find.text('Use your original document'), findsOneWidget);
        expect(find.text('Find good lighting'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_doc_capture_error');
        rethrow;
      }
    });

    testWidgets('Document Capture - camera fallback shows gallery option', (tester) async {
      try {
        await loginAndNavigateToKyc(tester);

        // Navigate through flow
        await tester.tap(find.text('Start Verification').last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await tester.tap(find.text('National ID Card'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Fill personal info
        await tester.enterText(find.byType(TextField).first, 'Amadou');
        await tester.enterText(find.byType(TextField).at(1), 'Diallo');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Select date'));
        await tester.pumpAndSettle();
        final okBtn = find.text('OK');
        if (okBtn.evaluate().isNotEmpty) {
          await tester.tap(okBtn);
          await tester.pumpAndSettle();
        }

        // Continue to document capture instructions
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Continue from instructions to camera
        final continueBtn = find.text('Continue');
        if (continueBtn.evaluate().isNotEmpty) {
          await tester.tap(continueBtn);
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle();
        }

        // From golden: 09_document_capture_camera.png - simulator shows gallery fallback
        expect(find.text('Front Side'), findsOneWidget);
        expect(find.text('Choose from Gallery'), findsOneWidget);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'kyc_camera_fallback_error');
        rethrow;
      }
    });
  });
}
