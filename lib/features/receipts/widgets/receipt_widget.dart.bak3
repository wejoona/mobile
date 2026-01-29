import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../domain/enums/index.dart';
import '../models/receipt_data.dart';

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
      color: Colors.white,
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
          Container(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 24),

          // Amount Section
          _buildAmountSection(currencyFormatter),
          const SizedBox(height: 24),

          // Divider
          Container(height: 1, color: Colors.grey[300]),
          const SizedBox(height: 24),

          // Recipient Section (if applicable)
          if (receiptData.recipientPhone != null || receiptData.recipientAddress != null) ...[
            _buildRecipientSection(),
            const SizedBox(height: 24),
            Container(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 24),
          ],

          // Transaction Details
          _buildDetailsSection(dateFormatter),
          const SizedBox(height: 24),

          // Divider
          Container(height: 1, color: Colors.grey[300]),
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
            color: const Color(0xFFD4AF37), // Gold color
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'JP',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'TRANSACTION RECEIPT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
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
          Text(
            receiptData.getStatusLabel().toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
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
            color: Colors.grey[100],
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
        const Text(
          'Recipient',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
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
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          receiptData.truncatedId,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Thank you for using',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'JoonaPay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37), // Gold color
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (receiptData.status) {
      case TransactionStatus.completed:
        return const Color(0xFF10B981); // Green
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return const Color(0xFFF59E0B); // Orange
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return const Color(0xFFEF4444); // Red
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
