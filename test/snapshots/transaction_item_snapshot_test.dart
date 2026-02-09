import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

import '../helpers/test_wrapper.dart';

/// Golden/Snapshot tests for Transaction List Item component
/// Ensures visual consistency for transaction display
///
/// To update goldens: flutter test --update-goldens test/snapshots/transaction_item_snapshot_test.dart
void main() {
  setUpAll(() { GoogleFonts.config.allowRuntimeFetching = false; });
  group('Transaction Item Snapshot Tests', () {
    Widget buildTransactionItem({
      required String title,
      required String subtitle,
      required String amount,
      required IconData icon,
      required Color iconColor,
      required Color amountColor,
      String? status,
      Color? statusColor,
      DateTime? date,
    }) {
      return Center(
        child: SizedBox(
          width: 350,
          child: AppCard(
            variant: AppCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            title,
                            variant: AppTextVariant.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          AppText(
                            subtitle,
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.textSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Amount
                    Flexible(
                      child: AppText(
                        amount,
                        variant: AppTextVariant.titleMedium,
                        color: amountColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status badge
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: (statusColor ?? AppColors.textTertiary).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: AppText(
                          status,
                          variant: AppTextVariant.labelSmall,
                          color: statusColor ?? AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
                if (date != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    _formatDate(date),
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    group('Transaction Types', () {
      testWidgets('deposit transaction', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Mobile Money Deposit',
              subtitle: 'Orange Money',
              amount: '+\$250.00',
              icon: Icons.arrow_downward,
              iconColor: AppColors.successText,
              amountColor: AppColors.successText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/deposit.png'),
        );
      });

      testWidgets('withdrawal transaction', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Withdrawal',
              subtitle: 'To Orange Money',
              amount: '-\$150.00',
              icon: Icons.arrow_upward,
              iconColor: AppColors.errorText,
              amountColor: AppColors.errorText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/withdrawal.png'),
        );
      });

      testWidgets('transfer sent', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Sent to Amadou Diallo',
              subtitle: '+225 07 12 34 56 78',
              amount: '-\$75.50',
              icon: Icons.send,
              iconColor: AppColors.errorText,
              amountColor: AppColors.errorText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/transfer_sent.png'),
        );
      });

      testWidgets('transfer received', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Received from Fatou Traore',
              subtitle: '+225 05 98 76 54 32',
              amount: '+\$125.00',
              icon: Icons.call_received,
              iconColor: AppColors.successText,
              amountColor: AppColors.successText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/transfer_received.png'),
        );
      });

      testWidgets('bill payment', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'CIE Bill Payment',
              subtitle: 'Electricity',
              amount: '-\$45.00',
              icon: Icons.receipt_long,
              iconColor: AppColors.warningText,
              amountColor: AppColors.errorText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/bill_payment.png'),
        );
      });

      testWidgets('airtime purchase', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Airtime Purchase',
              subtitle: 'Orange CI - 5000 XOF',
              amount: '-\$8.50',
              icon: Icons.phone_android,
              iconColor: AppColors.warningText,
              amountColor: AppColors.errorText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/airtime.png'),
        );
      });
    });

    group('Transaction Status', () {
      testWidgets('pending status', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Withdrawal',
              subtitle: 'To MTN Mobile Money',
              amount: '-\$200.00',
              icon: Icons.arrow_upward,
              iconColor: AppColors.errorText,
              amountColor: AppColors.errorText,
              status: 'Pending',
              statusColor: AppColors.warningBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/status_pending.png'),
        );
      });

      testWidgets('failed status', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Transfer Failed',
              subtitle: 'Insufficient funds',
              amount: '-\$500.00',
              icon: Icons.error_outline,
              iconColor: AppColors.errorText,
              amountColor: AppColors.errorText,
              status: 'Failed',
              statusColor: AppColors.errorBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/status_failed.png'),
        );
      });

      testWidgets('processing status', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Withdrawal Processing',
              subtitle: 'To Wave',
              amount: '-\$100.00',
              icon: Icons.sync,
              iconColor: AppColors.warningText,
              amountColor: AppColors.errorText,
              status: 'Processing',
              statusColor: AppColors.gold500,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/status_processing.png'),
        );
      });
    });

    group('Text Overflow', () {
      testWidgets('long recipient name', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Sent to Jean-Baptiste Kouassi Kouadio',
              subtitle: '+225 07 12 34 56 78',
              amount: '-\$50.00',
              icon: Icons.send,
              iconColor: AppColors.errorText,
              amountColor: AppColors.errorText,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/long_name.png'),
        );
      });

      testWidgets('long description', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Bill Payment',
              subtitle: 'This is a very long description that should truncate properly',
              amount: '-\$35.00',
              icon: Icons.receipt_long,
              iconColor: AppColors.warningText,
              amountColor: AppColors.errorText,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/long_description.png'),
        );
      });
    });

    group('Large Amounts', () {
      testWidgets('large amount', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Large Deposit',
              subtitle: 'Bank transfer',
              amount: '+\$12,345.67',
              icon: Icons.arrow_downward,
              iconColor: AppColors.successText,
              amountColor: AppColors.successText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/large_amount.png'),
        );
      });

      testWidgets('very large amount', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Business Payment',
              subtitle: 'Invoice #12345',
              amount: '+\$1,234,567.89',
              icon: Icons.business,
              iconColor: AppColors.successText,
              amountColor: AppColors.successText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/very_large_amount.png'),
        );
      });
    });

    group('With Date', () {
      testWidgets('transaction with date', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Transfer',
              subtitle: 'To Amadou Diallo',
              amount: '-\$100.00',
              icon: Icons.send,
              iconColor: AppColors.errorText,
              amountColor: AppColors.errorText,
              status: 'Completed',
              statusColor: AppColors.successBase,
              date: DateTime(2024, 1, 15, 14, 30),
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/with_date.png'),
        );
      });
    });

    group('Different Icons', () {
      testWidgets('QR payment', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'QR Payment',
              subtitle: 'Restaurant ABC',
              amount: '-\$25.00',
              icon: Icons.qr_code_scanner,
              iconColor: AppColors.gold500,
              amountColor: AppColors.errorText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/qr_payment.png'),
        );
      });

      testWidgets('recurring payment', (tester) async {
        await tester.pumpWidget(
          TestWrapper(
            child: buildTransactionItem(
              title: 'Recurring Payment',
              subtitle: 'Netflix subscription',
              amount: '-\$15.99',
              icon: Icons.autorenew,
              iconColor: AppColors.gold500,
              amountColor: AppColors.errorText,
              status: 'Completed',
              statusColor: AppColors.successBase,
            ),
          ),
        );

        await expectLater(
          find.byType(AppCard),
          matchesGoldenFile('goldens/transaction_item/recurring.png'),
        );
      });
    });
  });
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
