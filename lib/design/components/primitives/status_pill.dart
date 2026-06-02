import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

enum StatusTone { neutral, brand, success, warning, danger, info }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
    this.compact = false,
    this.emphasis = false,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;
  final bool compact;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = _palette(colors);
    final verticalPadding = compact ? 3.0 : AppSpacing.xs;
    final iconSize = compact ? 12.0 : 14.0;

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 20 : 24),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: palette.foreground, size: iconSize),
            SizedBox(width: compact ? AppSpacing.xs : AppSpacing.sm),
          ],
          Flexible(
            child: AppText(
              label,
              variant: compact
                  ? AppTextVariant.labelSmall
                  : AppTextVariant.labelMedium,
              color: palette.foreground,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  _StatusPillPalette _palette(ThemeColors colors) {
    switch (tone) {
      case StatusTone.brand:
        return _StatusPillPalette(
          foreground: colors.gold,
          background: colors.gold.withValues(
            alpha: colors.isDark ? 0.14 : 0.10,
          ),
          border: colors.gold.withValues(alpha: colors.isDark ? 0.28 : 0.22),
        );
      case StatusTone.success:
        return _StatusPillPalette(
          foreground: colors.successText,
          background: colors.success.withValues(
            alpha: colors.isDark ? 0.16 : 0.10,
          ),
          border: colors.success.withValues(alpha: colors.isDark ? 0.30 : 0.20),
        );
      case StatusTone.warning:
        return _StatusPillPalette(
          foreground: colors.warningText,
          background: colors.warning.withValues(
            alpha: colors.isDark ? 0.18 : 0.12,
          ),
          border: colors.warning.withValues(alpha: colors.isDark ? 0.32 : 0.22),
        );
      case StatusTone.danger:
        return _StatusPillPalette(
          foreground: colors.errorText,
          background: colors.error.withValues(
            alpha: colors.isDark ? 0.16 : 0.10,
          ),
          border: colors.error.withValues(alpha: colors.isDark ? 0.30 : 0.20),
        );
      case StatusTone.info:
        return _StatusPillPalette(
          foreground: colors.infoText,
          background: colors.info.withValues(
            alpha: colors.isDark ? 0.16 : 0.10,
          ),
          border: colors.info.withValues(alpha: colors.isDark ? 0.30 : 0.20),
        );
      case StatusTone.neutral:
        return _StatusPillPalette(
          foreground: colors.textSecondary,
          background: colors.elevated.withValues(
            alpha: colors.isDark ? 0.64 : 0.78,
          ),
          border: colors.borderSubtle,
        );
    }
  }
}

class _StatusPillPalette {
  const _StatusPillPalette({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}
