import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_data.dart';
import '../robots/auth_robot.dart';
import '../robots/wallet_robot.dart';
import '../robots/send_robot.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MockConfig.enableAllMocks();
  });

  group('PIN Security Flow Tests', () {
    late AuthRobot authRobot;
    late WalletRobot walletRobot;
    late SendRobot sendRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginUser(WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      authRobot = AuthRobot(tester);
      walletRobot = WalletRobot(tester);
      sendRobot = SendRobot(tester);

      // Skip onboarding
      final skipButton = find.text('Skip');
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }

      // Login
      await authRobot.completeLogin();
    }

    testWidgets('Correct PIN allows transaction', (tester) async {
      try {
        await loginUser(tester);

        // Start send flow
        await walletRobot.tapSendAction();

        // Enter recipient and amount
        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();
        await sendRobot.enterAmount(TestData.smallAmount);
        await sendRobot.tapContinueFromAmount();
        await sendRobot.tapConfirm();

        // Enter correct PIN
        await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));
        await sendRobot.enterPin(TestData.testPin);

        // Wait for result
        await TestHelpers.waitForLoadingToComplete(tester);

        // Should succeed
        sendRobot.verifySuccess();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'correct_pin_error');
        rethrow;
      }
    });

    testWidgets('Incorrect PIN shows error', (tester) async {
      try {
        await loginUser(tester);

        // Start send flow
        await walletRobot.tapSendAction();

        // Enter recipient and amount
        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();
        await sendRobot.enterAmount(TestData.smallAmount);
        await sendRobot.tapContinueFromAmount();
        await sendRobot.tapConfirm();

        // Enter incorrect PIN
        await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));
        await sendRobot.enterPin('000000');

        // Wait for error
        await tester.pump(const Duration(seconds: 2));

        // Should show error
        expect(find.textContaining('Invalid'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'incorrect_pin_error');
        rethrow;
      }
    });

    testWidgets('Multiple failed PINs trigger lockout warning', (tester) async {
      try {
        await loginUser(tester);

        // Start send flow
        await walletRobot.tapSendAction();

        // Enter recipient and amount
        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();
        await sendRobot.enterAmount(TestData.smallAmount);
        await sendRobot.tapContinueFromAmount();
        await sendRobot.tapConfirm();

        // Enter wrong PIN twice
        await TestHelpers.waitForWidget(tester, find.text('Enter PIN'));
        await sendRobot.enterPin('000000');
        await tester.pump(const Duration(seconds: 2));

        await sendRobot.enterPin('111111');
        await tester.pump(const Duration(seconds: 2));

        // Should show attempts remaining
        expect(
          find.textContaining('attempt'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'pin_lockout_warning_error');
        rethrow;
      }
    });

    testWidgets('PIN lockout after max attempts', (tester) async {
      try {
        await loginUser(tester);

        // Navigate to settings -> Security -> Change PIN
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        await TestHelpers.scrollUntilVisible(tester, find.text('Security'));
        await tester.tap(find.text('Security'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Change PIN'));
        await tester.pumpAndSettle();

        // Enter wrong current PIN 3 times
        for (int i = 0; i < 3; i++) {
          await TestHelpers.enterPin(tester, '000000');
          await tester.pump(const Duration(seconds: 2));
        }

        // Should be locked
        expect(
          find.textContaining('locked'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'pin_lockout_error');
        rethrow;
      }
    });

    testWidgets('Change PIN with correct current PIN', (tester) async {
      try {
        await loginUser(tester);

        // Navigate to settings -> Security -> Change PIN
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        await TestHelpers.scrollUntilVisible(tester, find.text('Security'));
        await tester.tap(find.text('Security'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Change PIN'));
        await tester.pumpAndSettle();

        // Enter current PIN
        await TestHelpers.enterPin(tester, TestData.testPin);
        await tester.pumpAndSettle();

        // Enter new PIN
        await TestHelpers.enterPin(tester, TestData.newPin);
        await tester.pumpAndSettle();

        // Confirm new PIN
        await TestHelpers.enterPin(tester, TestData.newPin);
        await tester.pumpAndSettle();

        // Should show success
        expect(find.textContaining('changed'), findsWidgets);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'change_pin_success_error');
        rethrow;
      }
    });

    testWidgets('Cannot set same PIN as current', (tester) async {
      try {
        await loginUser(tester);

        // Navigate to settings -> Security -> Change PIN
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        await TestHelpers.scrollUntilVisible(tester, find.text('Security'));
        await tester.tap(find.text('Security'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Change PIN'));
        await tester.pumpAndSettle();

        // Enter current PIN
        await TestHelpers.enterPin(tester, TestData.testPin);
        await tester.pumpAndSettle();

        // Try to set same PIN
        await TestHelpers.enterPin(tester, TestData.testPin);
        await tester.pump(const Duration(seconds: 2));

        // Should show error
        expect(
          find.textContaining('different'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'same_pin_error');
        rethrow;
      }
    });

    testWidgets('PIN confirmation mismatch', (tester) async {
      try {
        await loginUser(tester);

        // Navigate to settings -> Security -> Change PIN
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        await TestHelpers.scrollUntilVisible(tester, find.text('Security'));
        await tester.tap(find.text('Security'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Change PIN'));
        await tester.pumpAndSettle();

        // Enter current PIN
        await TestHelpers.enterPin(tester, TestData.testPin);
        await tester.pumpAndSettle();

        // Enter new PIN
        await TestHelpers.enterPin(tester, TestData.newPin);
        await tester.pumpAndSettle();

        // Confirm with different PIN
        await TestHelpers.enterPin(tester, '999999');
        await tester.pump(const Duration(seconds: 2));

        // Should show mismatch error
        expect(
          find.textContaining('match'),
          findsWidgets,
        );
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'pin_mismatch_error');
        rethrow;
      }
    });
  });
}
