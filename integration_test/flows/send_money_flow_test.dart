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

  group('Send Money Flow Tests', () {
    late AuthRobot authRobot;
    late WalletRobot walletRobot;
    late SendRobot sendRobot;

    setUp(() async {
      MockConfig.enableAllMocks();
      await TestHelpers.clearAppData();
    });

    Future<void> loginAndNavigateToSend(WidgetTester tester) async {
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

      // Navigate to send
      await walletRobot.tapSendAction();
    }

    testWidgets('Complete send money flow with phone number', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        // Verify on recipient screen
        sendRobot.verifyOnRecipientScreen();

        // Enter phone number
        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();

        // Enter amount
        sendRobot.verifyOnAmountScreen();
        await sendRobot.enterAmount(TestData.smallAmount);
        await sendRobot.tapContinueFromAmount();

        // Confirm
        sendRobot.verifyOnConfirmScreen();
        sendRobot.verifyRecipient(recipient['name'] as String);
        sendRobot.verifyAmount(TestData.smallAmount);
        await sendRobot.tapConfirm();

        // Enter PIN
        sendRobot.verifyOnPinScreen();
        await sendRobot.enterPin(TestData.testPin);

        // Wait for result
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify success
        sendRobot.verifySuccess();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'send_money_error');
        rethrow;
      }
    });

    testWidgets('Send money from beneficiaries', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        // Select from beneficiaries
        final beneficiary = TestData.testBeneficiaries[0];
        await sendRobot.selectBeneficiary(beneficiary['name'] as String);

        // Verify recipient selected
        sendRobot.verifyRecipient(beneficiary['name'] as String);

        // Continue with flow
        await sendRobot.enterAmount(TestData.mediumAmount);
        await sendRobot.tapContinueFromAmount();

        await sendRobot.tapConfirm();
        await sendRobot.enterPin(TestData.testPin);

        await TestHelpers.waitForLoadingToComplete(tester);
        sendRobot.verifySuccess();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'send_beneficiary_error');
        rethrow;
      }
    });

    testWidgets('Send money with note', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();

        await sendRobot.enterAmount(TestData.smallAmount);

        // Add note
        await sendRobot.addNote('Payment for lunch');

        await sendRobot.tapContinueFromAmount();

        // Verify note appears on confirm screen
        expect(find.text('Payment for lunch'), findsOneWidget);

        await sendRobot.tapConfirm();
        await sendRobot.enterPin(TestData.testPin);

        await TestHelpers.waitForLoadingToComplete(tester);
        sendRobot.verifySuccess();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'send_with_note_error');
        rethrow;
      }
    });

    testWidgets('Send money with insufficient balance', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();

        // Enter very large amount
        await sendRobot.enterAmount(TestData.veryLargeAmount);
        await sendRobot.tapContinueFromAmount();

        // Should see insufficient balance error
        sendRobot.verifyInsufficientBalance();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'insufficient_balance_error');
        rethrow;
      }
    });

    testWidgets('Cancel send flow from confirmation', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();

        await sendRobot.enterAmount(TestData.smallAmount);
        await sendRobot.tapContinueFromAmount();

        // Cancel from confirmation
        await sendRobot.tapCancel();

        // Should go back to amount screen
        sendRobot.verifyOnAmountScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'cancel_send_error');
        rethrow;
      }
    });

    testWidgets('Edit amount using backspace', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        final recipient = TestData.testBeneficiaries[0];
        await sendRobot.enterPhoneNumber(recipient['phone'] as String);
        await sendRobot.tapContinueFromRecipient();

        // Enter amount
        await sendRobot.enterAmount(TestData.smallAmount);

        // Clear and enter new amount
        await sendRobot.clearAmount();
        await sendRobot.enterAmount(TestData.mediumAmount);

        // Verify new amount
        sendRobot.verifyAmount(TestData.mediumAmount);
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'edit_amount_error');
        rethrow;
      }
    });

    testWidgets('Share receipt after successful send', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        // Complete send flow
        await sendRobot.completeSendFlow();

        // Verify success
        sendRobot.verifySuccess();

        // Share receipt
        await sendRobot.tapShareReceipt();

        // Verify share dialog appears
        await tester.pump(const Duration(seconds: 1));
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'share_receipt_error');
        rethrow;
      }
    });

    testWidgets('Send again from success screen', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        // Complete send flow
        await sendRobot.completeSendFlow();

        // Tap send again
        await sendRobot.tapSendAgain();

        // Should be back on recipient screen
        sendRobot.verifyOnRecipientScreen();
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'send_again_error');
        rethrow;
      }
    });

    testWidgets('Select from recent recipients', (tester) async {
      try {
        await loginAndNavigateToSend(tester);

        // If recent recipients exist, select one
        final recentRecipient = find.text('Fatou Traore');
        if (recentRecipient.evaluate().isNotEmpty) {
          await sendRobot.selectRecentRecipient('Fatou Traore');

          // Verify recipient selected
          sendRobot.verifyRecipient('Fatou Traore');

          // Continue flow
          await sendRobot.enterAmount(TestData.smallAmount);
          await sendRobot.tapContinueFromAmount();
          await sendRobot.tapConfirm();
          await sendRobot.enterPin(TestData.testPin);

          await TestHelpers.waitForLoadingToComplete(tester);
          sendRobot.verifySuccess();
        }
      } catch (e) {
        await TestHelpers.takeScreenshot(binding, 'recent_recipient_error');
        rethrow;
      }
    });
  });
}
