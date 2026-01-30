import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      // Clear app data before each test
      await TestHelpers.clearAppData();
    });

    testWidgets('Complete registration flow', (tester) async {
      try {
        app.main();
        await tester.pumpAndSettle();

        authRobot = AuthRobot(tester);

        // Skip onboarding if present
        final skipButton = find.text('Skip');
        if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton);
          await tester.pumpAndSettle();
        }

        // Verify on login screen
        authRobot.verifyOnLoginScreen();

        // Switch to registration
        await authRobot.tapRegisterTab();
        await TestHelpers.delay(const Duration(milliseconds: 500));

        // Enter phone number
        final user = TestData.defaultUser;
        await authRobot.enterPhoneNumber(user['phone'] as String);

        // Accept terms
        await authRobot.acceptTermsAndConditions();

        // Continue
        await authRobot.tapContinue();

        // Verify OTP screen
        await TestHelpers.waitForWidget(tester, find.text('Enter OTP'));
        authRobot.verifyOnOtpScreen();

        // Enter OTP
        await authRobot.enterOtp(TestData.testOtp);

        // Verify name entry screen
        await TestHelpers.waitForWidget(tester, find.text('First Name'));

        // Enter name
        await authRobot.enterName(
          user['firstName'] as String,
          user['lastName'] as String,
        );
        await authRobot.tapContinue();

        // Create PIN
        await TestHelpers.waitForWidget(tester, find.text('Create PIN'));
        await authRobot.createPin(TestData.testPin);

        // Wait for success or home screen
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify registration success
        expect(
          find.textContaining('Welcome'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'registration_flow_error');
        rethrow;
      }
    });

    testWidgets('Complete login flow', (tester) async {
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

        // Verify on login screen
        authRobot.verifyOnLoginScreen();

        // Complete login
        await authRobot.completeLogin();

        // Verify home screen
        authRobot.verifyOnHomeScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'login_flow_error');
        rethrow;
      }
    });

    testWidgets('Login with invalid OTP', (tester) async {
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

        // Enter phone
        await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
        await authRobot.tapContinue();

        // Enter invalid OTP
        await TestHelpers.waitForWidget(tester, find.text('Enter OTP'));
        await authRobot.enterOtp('000000');

        // Wait a moment for error
        await tester.pump(const Duration(seconds: 2));

        // Verify error message
        expect(
          find.textContaining('Invalid'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'invalid_otp_error');
        rethrow;
      }
    });

    testWidgets('Login with invalid PIN', (tester) async {
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

        // Enter phone
        await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
        await authRobot.tapContinue();

        // Enter OTP
        await TestHelpers.waitForWidget(tester, find.text('Enter OTP'));
        await authRobot.enterOtp(TestData.testOtp);

        // Enter invalid PIN
        await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));
        await authRobot.enterPin('000000');

        // Wait for error
        await tester.pump(const Duration(seconds: 2));

        // Verify error
        expect(
          find.textContaining('Invalid PIN'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'invalid_pin_error');
        rethrow;
      }
    });

    testWidgets('Resend OTP code', (tester) async {
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

        // Enter phone
        await authRobot.enterPhoneNumber(TestData.defaultUser['phone'] as String);
        await authRobot.tapContinue();

        // Wait for OTP screen
        await TestHelpers.waitForWidget(tester, find.text('Enter OTP'));

        // Tap resend OTP
        await authRobot.tapResendOtp();

        // Wait for confirmation
        await tester.pump(const Duration(seconds: 1));

        // Verify success message
        expect(
          find.textContaining('sent'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'resend_otp_error');
        rethrow;
      }
    });

    testWidgets('Logout flow', (tester) async {
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

        // Login first
        await authRobot.completeLogin();
        authRobot.verifyOnHomeScreen();

        // Logout
        await authRobot.logout();

        // Verify back on login screen
        authRobot.verifyLoggedOut();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'logout_error');
        rethrow;
      }
    });

    testWidgets('Country selection during registration', (tester) async {
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

        // Select different country
        await authRobot.selectCountry('Senegal');

        // Verify country changed
        expect(find.text('+221'), findsOneWidget);

        // Enter phone for Senegal
        await authRobot.enterPhoneNumber('77 123 45 67');

        // Verify formatting
        expect(
          find.textContaining('77'),
          findsOneWidget,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'country_selection_error');
        rethrow;
      }
    });
  });
}
