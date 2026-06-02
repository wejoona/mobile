import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class CachedDataChip extends StatelessWidget {
  const CachedDataChip({required this.lastUpdated, super.key});

  final DateTime lastUpdated;

  String _timeAgo() {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inMinutes < 1) {
      return 'just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colors.warningBase.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 14, color: colors.warningText),
            const SizedBox(width: AppSpacing.xs),
            AppText(
              'Cached · Updated ${_timeAgo()}',
              variant: AppTextVariant.labelSmall,
              color: colors.warningText,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DateTime>('lastUpdated', lastUpdated));
  }
}
