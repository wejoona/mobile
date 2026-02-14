import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/info_row.dart';

/// Transfer summary before confirmation.
class TransferSummary extends StatelessWidget {
  final String recipientName;
  final String recipientPhone;
  final double amount;
  final double fee;
  final String currency;
  final String? note;

  const TransferSummary({
    super.key,
    required this.recipientName,
    required this.recipientPhone,
    required this.amount,
    required this.fee,
    this.currency = 'USDC',
    this.note,
  });

  double get total => amount + fee;

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final __theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InfoRow(label: 'To', value: recipientName),
            InfoRow(label: 'Phone', value: recipientPhone),
            InfoRow(label: 'Amount', value: '\$${amount.toStringAsFixed(2)} $currency'),
            InfoRow(label: 'Fee', value: fee > 0 ? '\$${fee.toStringAsFixed(2)}' : 'Free'),
            if (note != null && note!.isNotEmpty)
              InfoRow(label: 'Note', value: note!),
            const InfoDivider(),
            InfoRow(label: 'Total', value: '\$${total.toStringAsFixed(2)} $currency', isBold: true),
          ],
        ),
      ),
    );
  }
}
