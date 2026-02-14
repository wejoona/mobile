import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/receipts/models/receipt_data.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Receipt widget for rendering as image or PDF
/// This widget can be captured using RepaintBoundary or screenshot package
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
    final dateFormatter = DateFormat('MMM dd, yyyy  •  HH:mm');
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      color: context.colors.goldSubtle, // Light cream - paper-like for receipts
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo & Title
          _buildHeader(),
          const SizedBox(height: 32),

          // Status Badge
          _buildStatusBadge(),
          const SizedBox(height: 24),

          // Divider
          Container(height: 1, color: context.colors.goldLight),
          const SizedBox(height: 24),

          // Amount Section
          _buildAmountSection(currencyFormatter),
          const SizedBox(height: 24),

          // Divider
          Container(height: 1, color: context.colors.goldLight),
          const SizedBox(height: 24),

          // Recipient Section (if applicable)
          if (receiptData.recipientPhone != null || receiptData.recipientAddress != null) ...[
            _buildRecipientSection(),
            const SizedBox(height: 24),
            Container(height: 1, color: context.colors.goldLight),
            const SizedBox(height: 24),
          ],

          // Transaction Details
          _buildDetailsSection(dateFormatter),
          const SizedBox(height: 24),

          // Divider
          Container(height: 1, color: context.colors.goldLight),
          const SizedBox(height: 24),

          // QR Code
          if (showQrCode) ...[
            _buildQrCode(),
            const SizedBox(height: 24),
          ],

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo placeholder - replace with actual logo asset
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.gold500,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: AppText(
              'JP',
              variant: AppTextVariant.displayMedium,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const AppText(
          'TRANSACTION RECEIPT',
          variant: AppTextVariant.titleLarge,
          color: AppColors.textInverse,
          fontWeight: FontWeight.bold,
          style: TextStyle(letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    final icon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          AppText(
            receiptData.getStatusLabel().toUpperCase(),
            variant: AppTextVariant.labelLarge,
            color: color,
            fontWeight: FontWeight.bold,
            style: const TextStyle(letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(NumberFormat formatter) {
    return Column(
      children: [
        _buildRow(
          'Amount:',
          formatter.format(receiptData.amount),
          isBold: true,
        ),
        if (receiptData.fee > 0) ...[
          const SizedBox(height: 12),
          _buildRow(
            'Fee:',
            formatter.format(receiptData.fee),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildRow(
            'Total:',
            '${formatter.format(receiptData.total)} ${receiptData.currency}',
            isBold: true,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Recipient',
          variant: AppTextVariant.labelMedium,
          color: AppColors.gold800,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 12),
        if (receiptData.recipientName != null)
          _buildRow('Name:', receiptData.recipientName!),
        if (receiptData.recipientPhone != null) ...[
          if (receiptData.recipientName != null) const SizedBox(height: 8),
          _buildRow('Phone:', receiptData.recipientPhone!),
        ],
        if (receiptData.recipientAddress != null) ...[
          const SizedBox(height: 8),
          _buildRow('Address:', _truncateAddress(receiptData.recipientAddress!)),
        ],
      ],
    );
  }

  Widget _buildDetailsSection(DateFormat dateFormatter) {
    return Column(
      children: [
        _buildRow('Date:', dateFormatter.format(receiptData.date)),
        const SizedBox(height: 12),
        _buildRow('Reference:', receiptData.referenceNumber),
        const SizedBox(height: 12),
        _buildRow('Type:', receiptData.getTypeLabel()),
        if (receiptData.description != null) ...[
          const SizedBox(height: 12),
          _buildRow('Note:', receiptData.description!),
        ],
      ],
    );
  }

  Widget _buildQrCode() {
    // QR code contains transaction reference for verification
    return Column(
      children: [
        QrImageView(
          data: receiptData.referenceNumber,
          version: QrVersions.auto,
          size: 120,
          backgroundColor: AppColors.gold50,
        ),
        const SizedBox(height: 8),
        AppText(
          receiptData.truncatedId,
          variant: AppTextVariant.monoSmall,
          color: AppColors.gold500,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const AppText(
          'Thank you for using',
          variant: AppTextVariant.bodySmall,
          color: AppColors.gold500,
        ),
        const SizedBox(height: 4),
        const AppText(
          'Korido',
          variant: AppTextVariant.titleMedium,
          color: AppColors.gold500,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, double fontSize = 14}) {
    final variant = fontSize >= 18 ? AppTextVariant.titleMedium : AppTextVariant.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          variant: variant,
          color: AppColors.textInverse,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        ),
        Flexible(
          child: AppText(
            value,
            variant: variant,
            color: AppColors.textInverse,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (receiptData.status) {
      case TransactionStatus.completed:
        return AppColors.successBase;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.warningBase;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppColors.errorBase;
    }
  }

  IconData _getStatusIcon() {
    switch (receiptData.status) {
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return Icons.schedule;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 8)}';
  }
}
