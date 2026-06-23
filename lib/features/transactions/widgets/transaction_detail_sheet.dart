import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/design/components/primitives/bottom_sheet_handle.dart';
import 'package:usdc_wallet/design/components/primitives/info_row.dart';
import 'package:usdc_wallet/utils/clipboard_utils.dart';
import 'package:usdc_wallet/utils/color_utils.dart';
import 'package:usdc_wallet/utils/share_utils.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Transaction detail bottom sheet.
class TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  static Future<void> show(BuildContext context, Transaction transaction) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCredit = transaction.isCredit;
    final statusColor = ColorUtils.statusColor(
      transaction.status.name,
      isDark: isDark,
    );

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHandle(
            title: 'Transaction Details',
            onClose: () => Navigator.pop(context),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              children: [
                // Amount
                AmountText.fromText(
                  '${transaction.amountSign}\$${transaction.amount.abs().toStringAsFixed(2)}',
                  currencyCode: transaction.currency,
                  size: AmountTextSize.large,
                  color: isCredit
                      ? context.colors.success
                      : theme.colorScheme.onSurface,
                ),
                SizedBox(height: AppSpacing.xs),
                PillBadge(
                  label: transaction.status.name.toUpperCase(),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  textColor: statusColor,
                ),
                SizedBox(height: AppSpacing.xl),

                // Details
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        InfoRow(
                          label: 'Type',
                          value: transaction.type.displayLabel,
                        ),
                        InfoRow(
                          label: 'Date',
                          value:
                              '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}',
                        ),
                        if (transaction.fee != null && transaction.fee! > 0)
                          InfoRow(
                            label: 'Fee',
                            value: '\$${transaction.fee!.toStringAsFixed(2)}',
                          ),
                        if (transaction.displayCounterpartyName != null)
                          InfoRow(
                            label: 'Recipient',
                            value: transaction.displayCounterpartyName!,
                          ),
                        if (transaction.displayCounterpartyPhone != null)
                          InfoRow(
                            label: 'Phone',
                            value: transaction.displayCounterpartyPhone!,
                          ),
                        if (transaction.description != null)
                          InfoRow(
                            label: 'Description',
                            value: transaction.description!,
                          ),
                        InfoRow(
                          label: 'Reference',
                          value: transaction.reference,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: AppLocalizations.of(context)!.action_copy,
                        onPressed: () =>
                            ClipboardUtils.copyTransactionId(transaction.id),
                        variant: AppButtonVariant.secondary,
                        icon: Icons.copy_rounded,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: AppLocalizations.of(context)!.action_share,
                        onPressed: () => ShareUtils.shareTransactionReceipt(
                          transactionId: transaction.id,
                          amount: transaction.amount,
                          currency: transaction.currency,
                          recipientName:
                              transaction.displayCounterpartyName ??
                              transaction.displayCounterpartyPhone ??
                              'N/A',
                          date: transaction.createdAt,
                          note: transaction.description,
                        ),
                        icon: Icons.share_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
