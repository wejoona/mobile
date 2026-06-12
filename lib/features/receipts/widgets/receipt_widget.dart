import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/qr_payment/widgets/branded_qr_image.dart';
import 'package:usdc_wallet/features/receipts/models/receipt_data.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Receipt widget for rendering as image or PDF.
class ReceiptWidget extends StatelessWidget {
  const ReceiptWidget({
    super.key,
    required this.receiptData,
    this.showQrCode = true,
  });

  final ReceiptData receiptData;
  final bool showQrCode;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, yyyy • HH:mm');
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 400,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColorsLight.container,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColorsLight.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xxl),
          _buildStatusRow(),
          const SizedBox(height: AppSpacing.xxl),
          _buildAmountSection(l10n),
          const SizedBox(height: AppSpacing.xxl),
          _Divider(),
          const SizedBox(height: AppSpacing.xl),
          if (receiptData.recipientPhone != null ||
              receiptData.recipientAddress != null) ...[
            _buildRecipientSection(l10n),
            const SizedBox(height: AppSpacing.xl),
            _Divider(),
            const SizedBox(height: AppSpacing.xl),
          ],
          _buildDetailsSection(l10n, dateFormatter),
          if (showQrCode) ...[
            const SizedBox(height: AppSpacing.xxl),
            _buildQrCode(),
          ],
          const SizedBox(height: AppSpacing.xxl),
          _buildFooter(l10n),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.gold500,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Center(
            child: AppText(
              'K',
              variant: AppTextVariant.titleLarge,
              color: AppColors.textInverse,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Korido',
                variant: AppTextVariant.titleLarge,
                color: AppColorsLight.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              AppText(
                'Transaction receipt',
                variant: AppTextVariant.bodySmall,
                color: AppColorsLight.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusPill(
                label: receiptData.getStatusLabel(),
                tone: _getStatusTone(),
                icon: _getStatusIcon(),
                emphasis: true,
              ),
            ),
          ),
          AppText(
            receiptData.getTypeLabel(),
            variant: AppTextVariant.labelMedium,
            color: AppColorsLight.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          l10n.send_total,
          variant: AppTextVariant.labelMedium,
          color: AppColorsLight.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xs),
        AmountText.fromText(
          formatCurrency(receiptData.total, receiptData.currency),
          size: AmountTextSize.display,
          color: AppColorsLight.textPrimary,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildRow(
          l10n.common_amount,
          formatCurrency(receiptData.amount, receiptData.currency),
          money: true,
        ),
        if (receiptData.fee > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildRow(
            l10n.send_fee,
            formatCurrency(receiptData.fee, receiptData.currency),
            money: true,
          ),
        ],
      ],
    );
  }

  Widget _buildRecipientSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.send_recipient,
          variant: AppTextVariant.labelMedium,
          color: AppColorsLight.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: AppSpacing.md),
        if (receiptData.recipientName != null)
          _buildRow('Name', receiptData.recipientName!),
        if (receiptData.recipientPhone != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Phone', receiptData.recipientPhone!),
        ],
        if (receiptData.recipientAddress != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Address', _truncateAddress(receiptData.recipientAddress!)),
        ],
      ],
    );
  }

  Widget _buildDetailsSection(AppLocalizations l10n, DateFormat dateFormatter) {
    return Column(
      children: [
        _buildRow(l10n.send_date, dateFormatter.format(receiptData.date)),
        const SizedBox(height: AppSpacing.sm),
        _buildRow(
          l10n.send_reference,
          receiptData.referenceNumber,
          monospace: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildRow(l10n.common_type, receiptData.getTypeLabel()),
        if (receiptData.description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildRow(l10n.common_note, receiptData.description!),
        ],
      ],
    );
  }

  Widget _buildQrCode() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColorsLight.borderSubtle),
            ),
            child: BrandedQrImage(
              data: receiptData.referenceNumber,
              size: 112,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            receiptData.truncatedId,
            variant: AppTextVariant.monoSmall,
            color: AppColorsLight.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return AppText(
      l10n.receipts_receiptView,
      variant: AppTextVariant.bodySmall,
      color: AppColorsLight.textTertiary,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool monospace = false,
    bool money = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          flex: 2,
          child: money
              ? AmountText.fromText(
                  value,
                  size: AmountTextSize.small,
                  color: AppColorsLight.textPrimary,
                  textAlign: TextAlign.right,
                )
              : AppText(
                  value,
                  variant: monospace
                      ? AppTextVariant.monoSmall
                      : AppTextVariant.bodyMedium,
                  color: AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.right,
                ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (receiptData.status) {
      case TransactionStatus.completed:
        return AppColorsLight.successText;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColorsLight.warningText;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColorsLight.errorText;
    }
  }

  StatusTone _getStatusTone() {
    switch (receiptData.status) {
      case TransactionStatus.completed:
        return StatusTone.success;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return StatusTone.warning;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return StatusTone.danger;
    }
  }

  IconData _getStatusIcon() {
    switch (receiptData.status) {
      case TransactionStatus.completed:
        return Icons.check_circle_rounded;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return Icons.schedule_rounded;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _truncateAddress(String address) {
    if (address.length <= 24) return address;
    return '${address.substring(0, 12)}...${address.substring(address.length - 8)}';
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColorsLight.borderSubtle);
}
