import 'package:flutter/material.dart';
import '../widgets/qr_display.dart';
import '../models/qr_data.dart';

/// QR code display screen for receiving payments.
class QrReceiveView extends StatelessWidget {
  final String userId;
  final String? phone;
  final String? displayName;
  final double? amount;

  const QrReceiveView({
    super.key,
    required this.userId,
    this.phone,
    this.displayName,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = QrPaymentData(userId: userId, phone: phone, displayName: displayName, amount: amount);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrCodeDisplay(data: qrData.encode(), displayName: displayName, onShare: () {}),
              if (amount != null) ...[
                const SizedBox(height: 24),
                Text('Requesting \$${amount!.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
