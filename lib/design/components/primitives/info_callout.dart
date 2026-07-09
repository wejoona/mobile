import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

enum InfoCalloutTone { brand, success, warning, danger, info, neutral }

class InfoCallout extends StatelessWidget {
  const InfoCallout({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.trailing,
    this.tone = InfoCalloutTone.brand,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? trailing;
  final InfoCalloutTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = _palette(colors);

    return AppCard(
      variant: AppCardVariant.flat,
      backgroundColor: palette.background,
      borderColor: palette.border,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.foreground.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: palette.foreground, size: 21),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                if (body != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    body!,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }

  _InfoCalloutPalette _palette(ThemeColors colors) {
    switch (tone) {
      case InfoCalloutTone.success:
        return _InfoCalloutPalette(
          foreground: colors.successText,
          background: colors.success.withValues(
            alpha: colors.isDark ? 0.12 : 0.08,
          ),
          border: colors.success.withValues(alpha: 0.20),
        );
      case InfoCalloutTone.warning:
        return _InfoCalloutPalette(
          foreground: colors.warningText,
          background: colors.warning.withValues(
            alpha: colors.isDark ? 0.14 : 0.09,
          ),
          border: colors.warning.withValues(alpha: 0.22),
        );
      case InfoCalloutTone.danger:
        return _InfoCalloutPalette(
          foreground: colors.errorText,
          background: colors.error.withValues(
            alpha: colors.isDark ? 0.12 : 0.08,
          ),
          border: colors.error.withValues(alpha: 0.20),
        );
      case InfoCalloutTone.info:
        return _InfoCalloutPalette(
          foreground: colors.infoText,
          background: colors.info.withValues(
            alpha: colors.isDark ? 0.12 : 0.08,
          ),
          border: colors.info.withValues(alpha: 0.20),
        );
      case InfoCalloutTone.neutral:
        return _InfoCalloutPalette(
          foreground: colors.iconSecondary,
          background: colors.isDark
              ? colors.elevated
              : Color.alphaBlend(
                  colors.gold.withValues(alpha: 0.05),
                  colors.container,
                ),
          border: colors.borderSubtle,
        );
      case InfoCalloutTone.brand:
        return _InfoCalloutPalette(
          foreground: colors.gold,
          background: colors.gold.withValues(
            alpha: colors.isDark ? 0.12 : 0.10,
          ),
          border: colors.gold.withValues(alpha: colors.isDark ? 0.22 : 0.28),
        );
    }
  }
}

class _InfoCalloutPalette {
  const _InfoCalloutPalette({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}
