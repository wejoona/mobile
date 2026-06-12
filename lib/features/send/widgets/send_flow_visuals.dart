import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

String sendStepLabel(BuildContext context, int step, {int totalSteps = 4}) {
  final language = Localizations.localeOf(context).languageCode;
  return language == 'fr'
      ? 'Étape $step sur $totalSteps'
      : 'Step $step of $totalSteps';
}

String localizedSendCopy(
  BuildContext context, {
  required String en,
  required String fr,
}) {
  final language = Localizations.localeOf(context).languageCode;
  return language == 'fr' ? fr : en;
}

enum SendCalloutTone { info, warning, success, error, brand }

class SendCallout extends StatelessWidget {
  const SendCallout({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
    this.tone = SendCalloutTone.info,
  });

  final IconData icon;
  final String title;
  final String body;
  final SendCalloutTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = _SendTonePalette.forTone(colors, tone);

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: palette.background,
      borderColor: palette.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: palette.foreground.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: palette.foreground, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelLarge,
                  color: palette.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  body,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SendTonePalette {
  const _SendTonePalette({
    required this.background,
    required this.foreground,
    required this.title,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color title;
  final Color border;

  static _SendTonePalette forTone(ThemeColors colors, SendCalloutTone tone) {
    switch (tone) {
      case SendCalloutTone.warning:
        return _SendTonePalette(
          background: colors.warningBg,
          foreground: colors.warningText,
          title: colors.textPrimary,
          border: colors.warning.withValues(alpha: 0.24),
        );
      case SendCalloutTone.success:
        return _SendTonePalette(
          background: colors.successBg,
          foreground: colors.successText,
          title: colors.textPrimary,
          border: colors.success.withValues(alpha: 0.24),
        );
      case SendCalloutTone.error:
        return _SendTonePalette(
          background: colors.errorBg,
          foreground: colors.errorText,
          title: colors.textPrimary,
          border: colors.error.withValues(alpha: 0.24),
        );
      case SendCalloutTone.brand:
        return _SendTonePalette(
          background: Color.alphaBlend(
            colors.gold.withValues(alpha: colors.isDark ? 0.10 : 0.045),
            colors.container,
          ),
          foreground: colors.gold,
          title: colors.textPrimary,
          border: colors.borderGold.withValues(alpha: 0.42),
        );
      case SendCalloutTone.info:
        return _SendTonePalette(
          background: Color.alphaBlend(
            colors.gold.withValues(alpha: colors.isDark ? 0.075 : 0.04),
            colors.container,
          ),
          foreground: colors.gold,
          title: colors.textPrimary,
          border: colors.borderGold.withValues(alpha: 0.30),
        );
    }
  }
}

class SendFlowHeader extends StatelessWidget {
  const SendFlowHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.currentStep,
    super.key,
    this.metaLabel,
    this.totalSteps = 4,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int currentStep;
  final String? metaLabel;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: metaLabel == null ? title : '$metaLabel, $title',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors.gold.withValues(alpha: colors.isDark ? 0.055 : 0.035),
            colors.elevated,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.borderGold.withValues(
              alpha: colors.isDark ? 0.34 : 0.24,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.goldSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.borderGold.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Icon(icon, color: colors.gold, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (metaLabel != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: colors.container,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: colors.borderSubtle),
                          ),
                          child: AppText(
                            metaLabel!,
                            variant: AppTextVariant.labelSmall,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      AppText(
                        title,
                        variant: AppTextVariant.titleLarge,
                        color: colors.textPrimary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        subtitle,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: List.generate(totalSteps, (index) {
                final isActive = index <= currentStep;
                final isCurrent = index == currentStep;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 5,
                    margin: EdgeInsetsDirectional.only(
                      end: index == totalSteps - 1 ? 0 : AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.gold
                          : colors.borderSubtle.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: colors.gold.withValues(
                                  alpha: colors.isDark ? 0.30 : 0.14,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class SendActionTile extends StatelessWidget {
  const SendActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      onTap: onTap,
      variant: AppCardVariant.flat,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.goldSubtle,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.borderGold.withValues(alpha: 0.38),
              ),
            ),
            child: Icon(icon, color: colors.gold, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    subtitle!,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textTertiary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SendSectionTitle extends StatelessWidget {
  const SendSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: AppText(
            text,
            variant: AppTextVariant.labelLarge,
            color: colors.textSecondary,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SendDetailRow extends StatelessWidget {
  const SendDetailRow({
    required this.label,
    required this.value,
    super.key,
    this.valueColor,
    this.valueWidget,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child:
              valueWidget ??
              AppText(
                value,
                variant: AppTextVariant.bodyMedium,
                color: valueColor ?? colors.textPrimary,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        ),
      ],
    );
  }
}
