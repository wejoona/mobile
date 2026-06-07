// Golden tests for Bulk Payments feature screens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_batch.dart';
import 'package:usdc_wallet/features/bulk_payments/models/bulk_payment.dart';
import 'package:usdc_wallet/features/bulk_payments/providers/bulk_payments_provider.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_payments_view.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_preview_view.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_status_view.dart';
import 'package:usdc_wallet/features/bulk_payments/views/bulk_upload_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  if (skipVisualSuiteIfDisabled()) return;

  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  goldenGroup('BulkPaymentsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: BulkPaymentsView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/main/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: BulkPaymentsView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/main/default_dark.png'),
      );
    });
  });

  goldenGroup('BulkUploadView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: false, child: BulkUploadView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/upload/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(isDarkMode: true, child: BulkUploadView()),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/upload/default_dark.png'),
      );
    });
  });

  goldenGroup('BulkPreviewView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          overrides: [
            draftBatchProvider.overrideWith((ref) => _goldenDraftBatch()),
          ],
          child: BulkPreviewView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/preview/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          overrides: [
            draftBatchProvider.overrideWith((ref) => _goldenDraftBatch()),
          ],
          child: BulkPreviewView(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/preview/default_dark.png'),
      );
    });
  });

  goldenGroup('BulkStatusView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: false,
          child: BulkStatusView(batchId: 'batch_1'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/status/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await tester.pumpWidget(
        GoldenTestWrapper(
          isDarkMode: true,
          child: BulkStatusView(batchId: 'batch_1'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/bulk_payments/status/default_dark.png'),
      );
    });
  });
}

BulkBatch _goldenDraftBatch() {
  return BulkBatch.fromPayments(
    id: 'draft_batch_001',
    name: 'Vendor payouts.csv',
    payments: const [
      BulkPayment(
        phone: '+2250711223344',
        amount: 120,
        description: 'Market delivery',
      ),
      BulkPayment(
        phone: '+2250748805663',
        amount: 80,
        description: 'Design review',
      ),
    ],
  );
}
