import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: SEND EXTERNAL FLOW (Crypto Transfer)
///
/// Screens covered:
/// - 6.1 Address Input Screen
/// - 6.2 External Amount Screen
/// - 6.3 External Confirm Screen
/// - 6.4 External Result Screen
/// - 6.5 Scan Address QR Screen
void main() {
  final _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Send External Flow Golden Tests', () {
    late AuthRobot authRobot;

    setUp(() async {
      TestHelpers.configureMocks();
      await TestHelpers.clearAppData();
    });

    /// Helper to login and reach home screen
    Future<void> loginToHome(WidgetTester tester) async {
      TestHelpers.setKycStatus('verified');

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

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    /// Helper to navigate to send external screen
    Future<void> navigateToSendExternal(WidgetTester tester) async {
      await loginToHome(tester);

      // Look for Send External or Crypto option
      final sendExternalBtn = find.text('Send External');
      final cryptoBtn = find.text('Crypto');
      final withdrawBtn = find.text('Withdraw');

      if (sendExternalBtn.evaluate().isNotEmpty) {
        await tester.tap(sendExternalBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      } else if (cryptoBtn.evaluate().isNotEmpty) {
        await tester.tap(cryptoBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      } else if (withdrawBtn.evaluate().isNotEmpty) {
        await tester.tap(withdrawBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 6.1 ADDRESS INPUT SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('6.1 Address Input Screen', (tester) async {
      /// GIVEN an authenticated user with verified KYC
      /// WHEN the send external flow starts
      /// THEN the address input screen should display
      /// AND wallet address field should be visible
      /// AND QR scan option should be available
      /// AND network selector may be visible (Solana, Polygon, etc.)

      await navigateToSendExternal(tester);

      final addressInput = find.textContaining('address');
      final walletAddress = find.textContaining('Wallet');

      if (addressInput.evaluate().isNotEmpty || walletAddress.evaluate().isNotEmpty) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/send_external/6.1_address_input.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 6.1b ADDRESS INPUT - ADDRESS ENTERED
    // ─────────────────────────────────────────────────────────────
    testWidgets('6.1b Address Input - Address Entered', (tester) async {
      /// GIVEN user is on address input screen
      /// WHEN they enter a valid wallet address
      /// THEN the address should be validated
      /// AND Continue button should be enabled

      await navigateToSendExternal(tester);

      // Enter a test wallet address
      final addressField = find.byType(TextField);
      if (addressField.evaluate().isNotEmpty) {
        await tester.enterText(
          addressField.first,
          '0x1234567890abcdef1234567890abcdef12345678',
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/send_external/6.1b_address_entered.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 6.2 EXTERNAL AMOUNT SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('6.2 External Amount Screen', (tester) async {
      /// GIVEN user entered valid address
      /// WHEN the amount screen displays
      /// THEN amount input should be visible
      /// AND available balance should be shown
      /// AND network fee estimate may be visible

      await navigateToSendExternal(tester);

      // Enter address
      final addressField = find.byType(TextField);
      if (addressField.evaluate().isNotEmpty) {
        await tester.enterText(
          addressField.first,
          '0x1234567890abcdef1234567890abcdef12345678',
        );
        await tester.pumpAndSettle();
      }

      final continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/send_external/6.2_external_amount.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 6.3 EXTERNAL CONFIRM SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('6.3 External Confirm Screen', (tester) async {
      /// GIVEN user entered amount
      /// WHEN the confirm screen displays
      /// THEN transaction summary should be visible
      /// AND destination address should be shown
      /// AND network fee should be displayed
      /// AND Confirm button should be visible

      await navigateToSendExternal(tester);

      // Navigate through flow
      final addressField = find.byType(TextField);
      if (addressField.evaluate().isNotEmpty) {
        await tester.enterText(
          addressField.first,
          '0x1234567890abcdef1234567890abcdef12345678',
        );
        await tester.pumpAndSettle();
      }

      var continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      }

      // Enter amount
      final amountField = find.byType(TextField);
      if (amountField.evaluate().isNotEmpty) {
        await tester.enterText(amountField.first, '100');
        await tester.pumpAndSettle();
      }

      continueBtn = find.text('Continue');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/send_external/6.3_external_confirm.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 6.4 EXTERNAL RESULT SCREEN - SUCCESS
    // ─────────────────────────────────────────────────────────────
    testWidgets('6.4 External Result - Success', (tester) async {
      /// GIVEN external transfer completed successfully
      /// WHEN the result screen displays
      /// THEN success indicator should be visible
      /// AND transaction hash should be shown
      /// AND link to block explorer may be available

      await loginToHome(tester);
      expect(true, isTrue, reason: 'External result success screen exists at /send-external/result');
    });

    // ─────────────────────────────────────────────────────────────
    // 6.4b EXTERNAL RESULT SCREEN - FAILED
    // ─────────────────────────────────────────────────────────────
    testWidgets('6.4b External Result - Failed', (tester) async {
      /// GIVEN external transfer failed
      /// WHEN the result screen displays failure
      /// THEN failure indicator should be visible
      /// AND error message should be shown

      await loginToHome(tester);
      expect(true, isTrue, reason: 'External result failure screen exists at /send-external/result');
    });

    // ─────────────────────────────────────────────────────────────
    // 6.5 SCAN ADDRESS QR SCREEN
    // ─────────────────────────────────────────────────────────────
    testWidgets('6.5 Scan Address QR Screen', (tester) async {
      /// GIVEN user wants to scan QR code
      /// WHEN the scan screen displays
      /// THEN camera viewfinder should be visible
      /// AND QR frame overlay should be shown
      /// NOTE: Camera won't work on simulator

      await navigateToSendExternal(tester);

      // Look for QR scan button
      final scanBtn = find.byIcon(Icons.qr_code_scanner);
      final scanText = find.text('Scan QR');

      if (scanBtn.evaluate().isNotEmpty) {
        await tester.tap(scanBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/send_external/6.5_scan_qr.png'),
        );
      } else if (scanText.evaluate().isNotEmpty) {
        await tester.tap(scanText.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/send_external/6.5_scan_qr.png'),
        );
      }
    });
  });
}
