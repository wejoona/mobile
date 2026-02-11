/// Consistent status badge widget for transaction/payment statuses.
library;

import 'package:flutter/material.dart';

enum StatusType { success, pending, failed, cancelled, processing }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  factory StatusBadge.fromString(String status) {
    final normalized = status.toLowerCase();
    final StatusType type;
    switch (normalized) {
      case 'completed':
      case 'success':
      case 'paid':
      case 'active':
        type = StatusType.success;
        break;
      case 'pending':
      case 'awaiting':
        type = StatusType.pending;
        break;
      case 'processing':
        type = StatusType.processing;
        break;
      case 'failed':
      case 'rejected':
      case 'error':
        type = StatusType.failed;
        break;
      case 'cancelled':
      case 'expired':
      case 'deactivated':
        type = StatusType.cancelled;
        break;
      default:
        type = StatusType.pending;
    }
    return StatusBadge(label: status, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor) = _colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (Color, Color) _colors(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case StatusType.success:
        return (const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case StatusType.pending:
        return (const Color(0xFFFFF3E0), const Color(0xFFE65100));
      case StatusType.processing:
        return (const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      case StatusType.failed:
        return (scheme.errorContainer, scheme.onErrorContainer);
      case StatusType.cancelled:
        return (const Color(0xFFF5F5F5), const Color(0xFF616161));
    }
  }
}
