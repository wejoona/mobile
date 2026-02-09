// Golden tests for additional Wallet feature views
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/wallet/views/deposit_view.dart';
import 'package:usdc_wallet/features/wallet/views/receive_view.dart';
import 'package:usdc_wallet/features/wallet/views/withdraw_view.dart';
import 'package:usdc_wallet/features/wallet/views/analytics_view.dart';
import 'package:usdc_wallet/features/wallet/views/budget_view.dart';
import 'package:usdc_wallet/features/wallet/views/currency_converter_view.dart';
import 'package:usdc_wallet/features/wallet/views/request_money_view.dart';
import 'package:usdc_wallet/features/wallet/views/saved_recipients_view.dart';
import 'package:usdc_wallet/features/wallet/views/savings_goals_view.dart';
import 'package:usdc_wallet/features/wallet/views/scheduled_transfers_view.dart';
import 'package:usdc_wallet/features/wallet/views/split_bill_view.dart';
import 'package:usdc_wallet/features/wallet/views/buy_airtime_view.dart';
import 'package:usdc_wallet/features/wallet/views/transfer_success_view.dart';
import 'package:usdc_wallet/features/wallet/views/scan_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('DepositView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: DepositView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/deposit_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: DepositView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/deposit_view/default_dark.png'),
      );
    });
  });

  group('ReceiveView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ReceiveView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/receive_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ReceiveView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/receive_view/default_dark.png'),
      );
    });
  });

  group('WithdrawView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: WithdrawView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/withdraw_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: WithdrawView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/withdraw_view/default_dark.png'),
      );
    });
  });

  group('AnalyticsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: AnalyticsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/analytics_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: AnalyticsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/analytics_view/default_dark.png'),
      );
    });
  });

  group('BudgetView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: BudgetView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/budget_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: BudgetView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/budget_view/default_dark.png'),
      );
    });
  });

  group('CurrencyConverterView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: CurrencyConverterView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/currency_converter/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: CurrencyConverterView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/currency_converter/default_dark.png'),
      );
    });
  });

  group('RequestMoneyView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: RequestMoneyView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/request_money/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: RequestMoneyView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/request_money/default_dark.png'),
      );
    });
  });

  group('SavedRecipientsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: SavedRecipientsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/saved_recipients/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: SavedRecipientsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/saved_recipients/default_dark.png'),
      );
    });
  });

  group('SavingsGoalsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: SavingsGoalsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/savings_goals/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: SavingsGoalsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/savings_goals/default_dark.png'),
      );
    });
  });

  group('ScheduledTransfersView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ScheduledTransfersView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/scheduled_transfers/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ScheduledTransfersView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/scheduled_transfers/default_dark.png'),
      );
    });
  });

  group('SplitBillView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: SplitBillView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/split_bill/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: SplitBillView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/split_bill/default_dark.png'),
      );
    });
  });

  group('BuyAirtimeView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: BuyAirtimeView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/buy_airtime/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: BuyAirtimeView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/buy_airtime/default_dark.png'),
      );
    });
  });

  group('TransferSuccessView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: TransferSuccessView(
            amount: 100.0,
            recipient: 'John Doe',
            transactionId: 'TXN123456',
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/transfer_success/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: TransferSuccessView(
            amount: 100.0,
            recipient: 'John Doe',
            transactionId: 'TXN123456',
          ),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/transfer_success/default_dark.png'),
      );
    });
  });

  group('ScanView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ScanView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/scan_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ScanView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/wallet/scan_view/default_dark.png'),
      );
    });
  });
}
