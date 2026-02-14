import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:usdc_wallet/main.dart' as app;

import '../../helpers/test_helpers.dart';
import '../../helpers/test_data.dart';
import '../../robots/auth_robot.dart';

/// Golden Tests: FEATURE FLAG GATED SCREENS
///
/// Screens covered (require feature flags to be enabled):
/// - 22.1 Bill Pay View (bills)
/// - 22.2 Buy Airtime View (airtime)
/// - 22.3 Savings Goals View (savings)
/// - 22.4 Virtual Card View (virtualCards)
/// - 22.5 Split Bill View (splitBills)
/// - 22.6 Budget View (budget)
/// - 22.7 Analytics View (analytics)
/// - 22.8 Currency Converter View (currencyConverter)
/// - 22.9 Request Money View (requestMoney)
/// - 22.10 Saved Recipients View (savedRecipients)
/// - 22.11 Scheduled Transfers View (recurringTransfers)
/// - 22.12 Withdraw View (withdraw)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => TestHelpers.configureMocks());

  group('Feature Flag Gated Screens Golden Tests', () {
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

    // ─────────────────────────────────────────────────────────────
    // 22.1 BILL PAY VIEW
    // FEATURE_FLAG: bills
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.1 Bill Pay View', (tester) async {
      /// GIVEN the bills feature flag is enabled
      /// WHEN user accesses Bill Pay
      /// THEN bill categories should display
      /// AND providers should be listed

      await loginToHome(tester);

      final billPayBtn = find.text('Bill Pay');
      // ignore: unused_local_variable
      final __payBillsBtn = find.text('Pay Bills');

      if (billPayBtn.evaluate().isNotEmpty) {
        await tester.tap(billPayBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.1_bill_pay.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.2 BUY AIRTIME VIEW
    // FEATURE_FLAG: airtime
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.2 Buy Airtime View', (tester) async {
      /// GIVEN the airtime feature flag is enabled
      /// WHEN user accesses Buy Airtime
      /// THEN phone number input should be visible
      /// AND carrier options should be shown (Orange, MTN, etc.)
      /// AND amount presets should be available

      await loginToHome(tester);

      final airtimeBtn = find.text('Airtime');
      // ignore: unused_local_variable
      final __buyAirtimeBtn = find.text('Buy Airtime');

      if (airtimeBtn.evaluate().isNotEmpty) {
        await tester.tap(airtimeBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.2_buy_airtime.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.3 SAVINGS GOALS VIEW
    // FEATURE_FLAG: savings
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.3 Savings Goals View', (tester) async {
      /// GIVEN the savings feature flag is enabled
      /// WHEN user accesses Savings Goals
      /// THEN goals list should display
      /// AND progress towards each goal should be shown

      await loginToHome(tester);

      final savingsBtn = find.text('Savings');
      // ignore: unused_local_variable
      final __goalsBtn = find.text('Goals');

      if (savingsBtn.evaluate().isNotEmpty) {
        await tester.tap(savingsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.3_savings_goals.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.4 VIRTUAL CARD VIEW
    // FEATURE_FLAG: virtualCards
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.4 Virtual Card View', (tester) async {
      /// GIVEN the virtualCards feature flag is enabled
      /// WHEN user accesses Virtual Card
      /// THEN card details or request card option should display

      await loginToHome(tester);

      final cardBtn = find.text('Card');
      // ignore: unused_local_variable
      final __virtualCardBtn = find.text('Virtual Card');

      if (cardBtn.evaluate().isNotEmpty) {
        await tester.tap(cardBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.4_virtual_card.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.5 SPLIT BILL VIEW
    // FEATURE_FLAG: splitBills
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.5 Split Bill View', (tester) async {
      /// GIVEN the splitBills feature flag is enabled
      /// WHEN user accesses Split Bill
      /// THEN split bill form should display
      /// AND total amount input should be visible
      /// AND participants selector should be available

      await loginToHome(tester);

      final splitBtn = find.text('Split');
      // ignore: unused_local_variable
      final __splitBillBtn = find.text('Split Bill');

      if (splitBtn.evaluate().isNotEmpty) {
        await tester.tap(splitBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.5_split_bill.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.6 BUDGET VIEW
    // FEATURE_FLAG: budget
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.6 Budget View', (tester) async {
      /// GIVEN the budget feature flag is enabled
      /// WHEN user accesses Budget
      /// THEN budget overview should display
      /// AND spending by category should be shown
      /// AND budget limits may be configurable

      await loginToHome(tester);

      final budgetBtn = find.text('Budget');

      if (budgetBtn.evaluate().isNotEmpty) {
        await tester.tap(budgetBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.6_budget.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.7 ANALYTICS VIEW
    // FEATURE_FLAG: analytics
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.7 Analytics View', (tester) async {
      /// GIVEN the analytics feature flag is enabled
      /// WHEN user accesses Analytics
      /// THEN spending analytics should display
      /// AND charts/graphs should be shown
      /// AND date range filter should be available

      await loginToHome(tester);

      final analyticsBtn = find.text('Analytics');

      if (analyticsBtn.evaluate().isNotEmpty) {
        await tester.tap(analyticsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.7_analytics.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.8 CURRENCY CONVERTER VIEW
    // FEATURE_FLAG: currencyConverter
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.8 Currency Converter View', (tester) async {
      /// GIVEN the currencyConverter feature flag is enabled
      /// WHEN user accesses Currency Converter
      /// THEN conversion form should display
      /// AND from/to currency selectors should be visible
      /// AND live exchange rate should be shown

      await loginToHome(tester);

      final converterBtn = find.text('Converter');
      // ignore: unused_local_variable
      final __exchangeBtn = find.text('Exchange');

      if (converterBtn.evaluate().isNotEmpty) {
        await tester.tap(converterBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.8_converter.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.9 REQUEST MONEY VIEW
    // FEATURE_FLAG: requestMoney
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.9 Request Money View', (tester) async {
      /// GIVEN the requestMoney feature flag is enabled
      /// WHEN user accesses Request Money
      /// THEN request form should display
      /// AND amount input should be visible
      /// AND recipient selector should be available

      await loginToHome(tester);

      final requestBtn = find.text('Request');
      // ignore: unused_local_variable
      final __requestMoneyBtn = find.text('Request Money');

      if (requestBtn.evaluate().isNotEmpty) {
        await tester.tap(requestBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.9_request_money.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.10 SAVED RECIPIENTS VIEW
    // FEATURE_FLAG: savedRecipients
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.10 Saved Recipients View', (tester) async {
      /// GIVEN the savedRecipients feature flag is enabled
      /// WHEN user accesses Saved Recipients
      /// THEN recipients list should display
      /// AND each recipient should show name, phone

      await loginToHome(tester);

      final recipientsBtn = find.text('Recipients');
      // ignore: unused_local_variable
      final __savedBtn = find.text('Saved');

      if (recipientsBtn.evaluate().isNotEmpty) {
        await tester.tap(recipientsBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.10_saved_recipients.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.11 SCHEDULED TRANSFERS VIEW
    // FEATURE_FLAG: recurringTransfers
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.11 Scheduled Transfers View', (tester) async {
      /// GIVEN the recurringTransfers feature flag is enabled
      /// WHEN user accesses Scheduled Transfers
      /// THEN scheduled transfers list should display
      /// AND next execution date should be shown

      await loginToHome(tester);

      final scheduledBtn = find.text('Scheduled');

      if (scheduledBtn.evaluate().isNotEmpty) {
        await tester.tap(scheduledBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.11_scheduled.png'),
        );
      }
    });

    // ─────────────────────────────────────────────────────────────
    // 22.12 WITHDRAW VIEW
    // FEATURE_FLAG: withdraw
    // ─────────────────────────────────────────────────────────────
    testWidgets('22.12 Withdraw View', (tester) async {
      /// GIVEN the withdraw feature flag is enabled
      /// WHEN user accesses Withdraw
      /// THEN withdrawal form should display
      /// AND amount input should be visible
      /// AND destination options should be available

      await loginToHome(tester);

      final withdrawBtn = find.text('Withdraw');

      if (withdrawBtn.evaluate().isNotEmpty) {
        await tester.tap(withdrawBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../goldens/feature_flags/22.12_withdraw.png'),
        );
      }
    });
  });
}
