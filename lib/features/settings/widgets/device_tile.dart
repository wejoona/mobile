import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/status_pill.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/duration_extensions.dart';

/// Tile showing a registered device.
class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback? onRemove;

  const DeviceTile({super.key, required this.device, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: colors.isDark ? 0.14 : 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.gold.withValues(
                  alpha: colors.isDark ? 0.22 : 0.16,
                ),
              ),
            ),
            child: Icon(
              device.platform == 'ios'
                  ? Icons.phone_iphone_rounded
                  : Icons.phone_android_rounded,
              color: colors.gold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: AppText(
                        device.displayLabel,
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.isCurrent) ...[
                      const SizedBox(width: 8),
                      StatusPill(
                        label: AppLocalizations.of(
                          context,
                        )!.settings_thisDevice,
                        tone: StatusTone.success,
                        compact: true,
                        emphasis: true,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Last active: ${device.lastActiveAt.timeAgo}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!device.isCurrent && onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, color: colors.error, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          if (device.isTrusted)
            Icon(Icons.verified_user_rounded, color: colors.success, size: 18),
        ],
      ),
    );
  }
}
