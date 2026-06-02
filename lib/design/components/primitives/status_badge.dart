import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/status_pill.dart';

/// A compact status badge for displaying transaction/KYC/account status.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status.toLowerCase());
    return StatusPill(
      label: config.label,
      tone: config.tone,
      compact: fontSize <= 12,
    );
  }

  _StatusConfig _getConfig(String status) {
    switch (status) {
      case 'completed':
      case 'success':
      case 'approved':
      case 'active':
        return const _StatusConfig('Completed', StatusTone.success);
      case 'pending':
      case 'processing':
      case 'submitted':
        return const _StatusConfig('Pending', StatusTone.warning);
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return const _StatusConfig('Failed', StatusTone.danger);
      default:
        return _StatusConfig(status, StatusTone.info);
    }
  }
}

class _StatusConfig {
  final String label;
  final StatusTone tone;

  const _StatusConfig(this.label, this.tone);
}
