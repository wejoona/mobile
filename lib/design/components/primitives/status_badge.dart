import 'package:flutter/material.dart';
import '../../tokens/semantic_colors.dart';

/// A compact status badge for displaying transaction/KYC/account status.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  
  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });
  
  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  _StatusConfig _getConfig(String status) {
    switch (status) {
      case 'completed':
      case 'success':
      case 'approved':
      case 'active':
        return _StatusConfig('Completed', SemanticColors.success, SemanticColors.successLight);
      case 'pending':
      case 'processing':
      case 'submitted':
        return _StatusConfig('Pending', SemanticColors.warning, SemanticColors.warningLight);
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return _StatusConfig('Failed', SemanticColors.error, SemanticColors.errorLight);
      default:
        return _StatusConfig(status, SemanticColors.info, SemanticColors.infoLight);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  const _StatusConfig(this.label, this.textColor, this.backgroundColor);
}
