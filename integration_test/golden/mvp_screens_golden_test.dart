import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';

/// MVP Golden Tests - Captures all critical screens
///
/// Run with real backend:
/// flutter test integration_test/golden/mvp_screens_golden_test.dart --update-goldens --dart-define=USE_MOCKS=false
///
/// Run with mocks (for CI):
/// flutter test integration_test/golden/mvp_screens_golden_test.dart --update-goldens
void main() {
  final _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Check if running with real backend
  const useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: true);

  setUpAll(() {
    if (useMocks) {
      MockConfig.enableAllMocks();
    } else {
      MockConfig.useMocks = false;
    }
  });

  // ============================================================
  // SECTION 1: AUTH FLOW
  // ============================================================
  group('1. Auth Flow', () {
    late AuthRobot authRobot;

    setUp(() async {
      if (useMocks) MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('1.1 Splash Screen', (tester) async {
      app.main();
      // Capture immediately before navigation
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/1.1_splash.png'),
      );
    });

    testWidgets('1.2 Login Screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding
      final skip = find.text('Skip');
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/1.2_login.png'),
      );
    });

    testWidgets('1.3 OTP Screen (Secure Login)', (tester) async {
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

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/1.3_otp.png'),
      );
    });
  });

  // ============================================================
  // SECTION 2: KYC FLOW
  // ============================================================
  group('2. KYC Flow', () {
    late AuthRobot authRobot;

    setUp(() async {
      if (useMocks) MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginToKycScreen(WidgetTester tester) async {
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
    }

    testWidgets('2.1 Identity Verification Screen', (tester) async {
      await loginToKycScreen(tester);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/2.1_identity_verification.png'),
      );
    });

    testWidgets('2.2 Document Type Selection', (tester) async {
      await loginToKycScreen(tester);

      // Tap Start Verification
      final startBtn = find.text('Start Verification');
      await tester.tap(startBtn.last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/2.2_document_type.png'),
      );
    });

    testWidgets('2.3 Document Type Selected', (tester) async {
      await loginToKycScreen(tester);

      final startBtn = find.text('Start Verification');
      await tester.tap(startBtn.last);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Select National ID
      await tester.tap(find.text('National ID Card'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/2.3_document_selected.png'),
      );
    });

    testWidgets('2.4 Personal Information', (tester) async {
      await loginToKycScreen(tester);

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

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/2.4_personal_info.png'),
      );
    });

    testWidgets('2.5 Personal Info Filled', (tester) async {
      await loginToKycScreen(tester);

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

      // Fill form
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

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/2.5_personal_info_filled.png'),
      );
    });

    testWidgets('2.6 Document Capture Instructions', (tester) async {
      await loginToKycScreen(tester);

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

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/2.6_document_capture_instructions.png'),
      );
    });

    testWidgets('2.7 Camera Fallback (Gallery Option)', (tester) async {
      await loginToKycScreen(tester);

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

      // Continue from instructions to camera
      final continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/mvp/2.7_camera_fallback.png'),
      );
    });
  });

  // ============================================================
  // SECTION 3: DEPOSIT FLOW (Requires authenticated user with wallet)
  // ============================================================
  // NOTE: These tests require a user who has completed KYC
  // Skip for now as they need state setup

  // ============================================================
  // SECTION 4: SEND FLOW
  // ============================================================
  // NOTE: These tests require authenticated user with balance

  // ============================================================
  // SECTION 5: SETTINGS
  // ============================================================
  // NOTE: Requires authenticated user
}
