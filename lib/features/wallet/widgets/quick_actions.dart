import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/quick_action_button.dart';

/// Home screen quick action buttons.
class HomeQuickActions extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onReceive;
  final VoidCallback onDeposit;
  final VoidCallback onBills;
  final VoidCallback? onScan;

  const HomeQuickActions({
    super.key,
    required this.onSend,
    required this.onReceive,
    required this.onDeposit,
    required this.onBills,
    this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          QuickActionButton(icon: Icons.arrow_upward_rounded, label: 'Send', onTap: onSend),
          QuickActionButton(icon: Icons.arrow_downward_rounded, label: 'Receive', onTap: onReceive),
          QuickActionButton(icon: Icons.add_rounded, label: 'Deposit', onTap: onDeposit),
          QuickActionButton(icon: Icons.receipt_long_rounded, label: 'Bills', onTap: onBills),
          if (onScan != null)
            QuickActionButton(icon: Icons.qr_code_scanner_rounded, label: 'Scan', onTap: onScan!),
        ],
      ),
    );
  }
}
