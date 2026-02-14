import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';

/// App-styled toggle switch with haptic feedback
///
/// Provides consistent switch styling across the app with:
/// - Gold active color matching brand
/// - Haptic feedback on toggle
/// - Disabled state support
/// - Optional label and subtitle
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.enableHaptics = true,
  });

  /// Current toggle state
  final bool value;

  /// Callback when toggle changes
  final ValueChanged<bool>? onChanged;

  /// Enable haptic feedback on toggle (default: true)
  final bool enableHaptics;

  void _handleToggle(bool newValue) {
    if (enableHaptics) {
      hapticService.toggle();
    }
    onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Switch(
      value: value,
      onChanged: onChanged == null ? null : _handleToggle,
      activeThumbColor: colors.gold,
      activeTrackColor: colors.gold.withValues(alpha: 0.5),
      inactiveThumbColor: colors.textTertiary,
      inactiveTrackColor: colors.borderSubtle,
    );
  }
}

/// Toggle tile with icon, title, subtitle, and switch
///
/// Common pattern for settings screens with toggle controls
class AppToggleTile extends StatelessWidget {
  const AppToggleTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.enableHaptics = true,
  });

  /// Toggle label
  final String title;

  /// Optional subtitle/description
  final String? subtitle;

  /// Optional leading icon
  final IconData? icon;

  /// Current toggle state
  final bool value;

  /// Callback when toggle changes
  final ValueChanged<bool>? onChanged;

  /// Enable haptic feedback on toggle (default: true)
  final bool enableHaptics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.container,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppToggle(
            value: value,
            onChanged: onChanged,
            enableHaptics: enableHaptics,
          ),
        ],
      ),
    );
  }
}
