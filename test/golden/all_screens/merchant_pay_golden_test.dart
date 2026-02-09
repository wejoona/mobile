// Golden tests for Merchant Pay feature screens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/merchant_pay/views/create_payment_request_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/merchant_dashboard_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/merchant_qr_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/merchant_transactions_view.dart';
import 'package:usdc_wallet/features/merchant_pay/views/scan_qr_view.dart';
import 'package:usdc_wallet/features/merchant_pay/services/merchant_service.dart';

import '../helpers/golden_test_helper.dart';

final _sampleMerchant = MerchantResponse(
  merchantId: 'merchant_001',
  businessName: 'Test Business',
  displayName: 'Test Merchant',
  category: 'retail',
  country: 'CI',
  walletId: 'wallet_001',
  qrCode: 'QR_DATA_001',
  isVerified: true,
  feePercent: 1.5,
  dailyLimit: 5000.0,
  monthlyLimit: 50000.0,
  dailyVolume: 1200.0,
  monthlyVolume: 15000.0,
  remainingDailyLimit: 3800.0,
  remainingMonthlyLimit: 35000.0,
  totalTransactions: 142,
  status: 'active',
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 6, 15),
);

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('MerchantDashboardView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: MerchantDashboardView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/dashboard/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: MerchantDashboardView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/dashboard/default_dark.png'),
      );
    });
  });

  group('MerchantQrView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: MerchantQrView(merchant: _sampleMerchant),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/qr_display/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: MerchantQrView(merchant: _sampleMerchant),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/qr_display/default_dark.png'),
      );
    });
  });

  group('ScanQrView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: ScanQrView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/scan_qr/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: ScanQrView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/scan_qr/default_dark.png'),
      );
    });
  });

  group('CreatePaymentRequestView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: CreatePaymentRequestView(merchant: _sampleMerchant),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/create_request/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: CreatePaymentRequestView(merchant: _sampleMerchant),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/create_request/default_dark.png'),
      );
    });
  });

  // Note: PaymentConfirmView and PaymentReceiptView require complex runtime objects
  // (QrDecodeResponse, PaymentResponse with callbacks) that are better tested via
  // integration tests. Skipping their golden tests for now.

  group('MerchantTransactionsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: MerchantTransactionsView(merchantId: 'merchant_001'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/transactions/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: MerchantTransactionsView(merchantId: 'merchant_001'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/merchant_pay/transactions/default_dark.png'),
      );
    });
  });
}
