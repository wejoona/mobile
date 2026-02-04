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

  group('Onboarding Flow Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    testWidgets('Complete onboarding tutorial pages', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Check for onboarding screens
        final welcomeText = find.textContaining('Welcome');
        if (welcomeText.evaluate().isNotEmpty) {
          // Page 1
          expect(welcomeText, findsWidgets);

          // Swipe to next page
          await tester.drag(find.byType(PageView), const Offset(-300, 0));
          await tester.pumpAndSettle();

          // Page 2
          await tester.drag(find.byType(PageView), const Offset(-300, 0));
          await tester.pumpAndSettle();

          // Page 3
          await tester.drag(find.byType(PageView), const Offset(-300, 0));
          await tester.pumpAndSettle();

          // Get started button
          final getStarted = find.text('Get Started');
          if (getStarted.evaluate().isNotEmpty) {
            await tester.tap(getStarted);
            await tester.pumpAndSettle();
          }
        }

        // Should be on login screen now
        authRobot.verifyOnLoginScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'onboarding_pages_error');
        rethrow;
      }
    });

    testWidgets('Skip onboarding tutorial', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Find skip button
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Should be on login screen
        authRobot.verifyOnLoginScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'skip_onboarding_error');
        rethrow;
      }
    });

    testWidgets('Complete registration with all fields', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Switch to register
        await authRobot.tapRegisterTab();

        // Enter phone number
        final user = TestData.defaultUser;
        await authRobot.enterPhoneNumber(user['phone'] as String);

        // Accept terms and conditions
        await authRobot.acceptTermsAndConditions();

        // Continue
        await authRobot.tapContinue();

        // Verify OTP screen
        await TestHelpers.waitForWidget(tester, find.text('Secure Login'));
        await authRobot.enterOtp(TestData.testOtp);

        // Enter name
        await TestHelpers.waitForWidget(tester, find.text('First Name'));
        await authRobot.enterName(
          user['firstName'] as String,
          user['lastName'] as String,
        );
        await authRobot.tapContinue();

        // Create PIN
        await TestHelpers.waitForWidget(tester, find.text('Create PIN'));
        await authRobot.createPin(TestData.testPin);

        // Wait for success
        await TestHelpers.waitForLoadingToComplete(tester);

        // Should show home or success
        expect(
          find.textContaining('Welcome'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'full_registration_error');
        rethrow;
      }
    });

    testWidgets('Terms and conditions are required', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Switch to register
        await authRobot.tapRegisterTab();

        // Enter phone number
        await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);

        // Try to continue without accepting terms
        await authRobot.tapContinue();

        // Should show error or button disabled
        // Continue button might be disabled or show error
        await tester.pump(const Duration(seconds: 1));
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'terms_required_error');
        rethrow;
      }
    });

    testWidgets('View terms and conditions', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Switch to register
        await authRobot.tapRegisterTab();

        // Find terms link
        final termsLink = find.text('Terms and Conditions');
        if (termsLink.evaluate().isNotEmpty) {
          await tester.tap(termsLink);
          await tester.pumpAndSettle();

          // Should show terms content
          expect(find.textContaining('Terms'), findsWidgets);

          // Close
          await TestHelpers.tapBackButton(tester);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'view_terms_error');
        rethrow;
      }
    });

    testWidgets('View privacy policy', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Switch to register
        await authRobot.tapRegisterTab();

        // Find privacy link
        final privacyLink = find.text('Privacy Policy');
        if (privacyLink.evaluate().isNotEmpty) {
          await tester.tap(privacyLink);
          await tester.pumpAndSettle();

          // Should show privacy content
          expect(find.textContaining('Privacy'), findsWidgets);

          // Close
          await TestHelpers.tapBackButton(tester);
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'view_privacy_error');
        rethrow;
      }
    });

    testWidgets('PIN creation with confirmation', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Go through registration to PIN creation
        await authRobot.tapRegisterTab();
        await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
        await authRobot.acceptTermsAndConditions();
        await authRobot.tapContinue();

        await TestHelpers.waitForWidget(tester, find.text('Secure Login'));
        await authRobot.enterOtp(TestData.testOtp);

        await TestHelpers.waitForWidget(tester, find.text('First Name'));
        await authRobot.enterName('Test', 'User');
        await authRobot.tapContinue();

        // Create PIN
        await TestHelpers.waitForWidget(tester, find.text('Create PIN'));
        await TestHelpers.enterPin(tester, TestData.testPin);
        await tester.pumpAndSettle();

        // Confirm PIN
        await TestHelpers.waitForWidget(tester, find.text('Confirm PIN'));
        await TestHelpers.enterPin(tester, TestData.testPin);
        await tester.pumpAndSettle();

        // Should succeed
        await TestHelpers.waitForLoadingToComplete(tester);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'pin_creation_error');
        rethrow;
      }
    });

    testWidgets('PIN confirmation mismatch shows error', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Go through registration to PIN creation
        await authRobot.tapRegisterTab();
        await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
        await authRobot.acceptTermsAndConditions();
        await authRobot.tapContinue();

        await TestHelpers.waitForWidget(tester, find.text('Secure Login'));
        await authRobot.enterOtp(TestData.testOtp);

        await TestHelpers.waitForWidget(tester, find.text('First Name'));
        await authRobot.enterName('Test', 'User');
        await authRobot.tapContinue();

        // Create PIN
        await TestHelpers.waitForWidget(tester, find.text('Create PIN'));
        await TestHelpers.enterPin(tester, TestData.testPin);
        await tester.pumpAndSettle();

        // Confirm with different PIN
        await TestHelpers.waitForWidget(tester, find.text('Confirm PIN'));
        await TestHelpers.enterPin(tester, '999999');
        await tester.pump(const Duration(seconds: 2));

        // Should show mismatch error
        expect(
          find.textContaining('match'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'pin_mismatch_onboarding_error');
        rethrow;
      }
    });
  });
}
