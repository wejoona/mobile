import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

enum PillBadgeTone { brand, success, warning, error, info }

/// A small pill/badge for counts, labels, status tags.
class PillBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final bool isOutlined;
  final PillBadgeTone tone;

  const PillBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.isOutlined = false,
    this.tone = PillBadgeTone.brand,
  });

  factory PillBadge.success(String label) =>
      PillBadge(label: label, tone: PillBadgeTone.success);

  factory PillBadge.warning(String label) =>
      PillBadge(label: label, tone: PillBadgeTone.warning);

  factory PillBadge.error(String label) =>
      PillBadge(label: label, tone: PillBadgeTone.error);

  factory PillBadge.info(String label) =>
      PillBadge(label: label, tone: PillBadgeTone.info);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = _palette(colors);
    final bg = backgroundColor ?? palette.background;
    final fg = textColor ?? palette.foreground;

    if (isOutlined) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: fg.withValues(alpha: 0.5)),
        ),
        child: AppText(
          label,
          variant: fontSize <= 11
              ? AppTextVariant.labelSmall
              : AppTextVariant.labelMedium,
          color: fg,
          fontWeight: FontWeight.w600,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(
        label,
        variant: fontSize <= 11
            ? AppTextVariant.labelSmall
            : AppTextVariant.labelMedium,
        color: fg,
        fontWeight: FontWeight.w600,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  _PillBadgePalette _palette(ThemeColors colors) {
    switch (tone) {
      case PillBadgeTone.success:
        return _PillBadgePalette(
          colors.successText,
          colors.success.withValues(alpha: colors.isDark ? 0.16 : 0.10),
        );
      case PillBadgeTone.warning:
        return _PillBadgePalette(
          colors.warningText,
          colors.warning.withValues(alpha: colors.isDark ? 0.18 : 0.12),
        );
      case PillBadgeTone.error:
        return _PillBadgePalette(
          colors.errorText,
          colors.error.withValues(alpha: colors.isDark ? 0.16 : 0.10),
        );
      case PillBadgeTone.info:
        return _PillBadgePalette(
          colors.infoText,
          colors.info.withValues(alpha: colors.isDark ? 0.16 : 0.10),
        );
      case PillBadgeTone.brand:
        return _PillBadgePalette(
          colors.gold,
          colors.gold.withValues(alpha: colors.isDark ? 0.14 : 0.10),
        );
    }
  }
}

class _PillBadgePalette {
  const _PillBadgePalette(this.foreground, this.background);

  final Color foreground;
  final Color background;
}

/// Notification count badge (small red circle with number).
class CountBadge extends StatelessWidget {
  final int count;
  final double size;

  const CountBadge({super.key, required this.count, this.size = 18});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final colors = context.colors;

    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colors.error,
        shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count > 9 ? BorderRadius.circular(size / 2) : null,
      ),
      alignment: Alignment.center,
      child: AppText(
        count > 99 ? '99+' : count.toString(),
        variant: AppTextVariant.labelSmall,
        color: colors.onDark,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
