import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/limit.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Card showing transaction limit usage.
class LimitUsageCard extends StatelessWidget {
  const LimitUsageCard({super.key, required this.limits});

  final TransactionLimits limits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.limits_transactionLimits,
            variant: AppTextVariant.titleSmall,
            color: colors.textPrimary,
          ),
          if (limits.hasActiveOverride) ...[
            const SizedBox(height: AppSpacing.md),
            _LimitOverrideBanner(limits: limits),
          ],
          if (!limits.permissions.canSend ||
              !limits.permissions.canDeposit ||
              !limits.permissions.canWithdraw) ...[
            const SizedBox(height: AppSpacing.md),
            _MoneyFlowBlockedBanner(limits: limits),
          ],
          const SizedBox(height: AppSpacing.lg),
          _LimitRow(
            label: l10n.limits_dailyLimits,
            used: limits.dailyUsed,
            limit: limits.dailyLimit,
          ),
          if (limits.weeklyLimit > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _LimitRow(
              label: '7 days',
              used: limits.weeklyUsed,
              limit: limits.weeklyLimit,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _LimitRow(
            label: l10n.limits_monthlyLimits,
            used: limits.monthlyUsed,
            limit: limits.monthlyLimit,
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: colors.borderSubtle),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                l10n.limits_maxPerTransaction,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
              AppText(
                '\$${limits.singleTransactionMax.toStringAsFixed(2)}',
                variant: AppTextVariant.monoMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoneyFlowBlockedBanner extends StatelessWidget {
  const _MoneyFlowBlockedBanner({required this.limits});

  final TransactionLimits limits;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final language = Localizations.localeOf(context).languageCode;
    final reason = limits.permissions.blockReason?.trim();
    final title = limits.permissions.reviewRequired
        ? (language == 'fr'
              ? 'Verification en revue'
              : 'Verification under review')
        : (language == 'fr' ? 'Verification requise' : 'Verification required');
    final body = reason != null && reason.isNotEmpty
        ? reason
        : (language == 'fr'
              ? 'Certaines operations sont suspendues jusqu a la validation de votre compte.'
              : 'Some money movement is paused until your account is cleared.');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_clock_rounded, color: colors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  body,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitOverrideBanner extends StatelessWidget {
  const _LimitOverrideBanner({required this.limits});

  final TransactionLimits limits;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final language = Localizations.localeOf(context).languageCode;
    final reason = limits.overrideReason?.trim();
    final expiresAt = limits.overrideExpiresAt;

    final title = language == 'fr'
        ? 'Limites speciales actives'
        : 'Special limits active';
    final body = [
      if (reason != null && reason.isNotEmpty) reason,
      if (expiresAt != null)
        language == 'fr'
            ? 'Expire le ${MaterialLocalizations.of(context).formatShortDate(expiresAt)}'
            : 'Expires ${MaterialLocalizations.of(context).formatShortDate(expiresAt)}',
      if ((reason == null || reason.isEmpty) && expiresAt == null)
        language == 'fr'
            ? 'Une limite approuvee par le support est appliquee a ce compte.'
            : 'A support-approved limit is applied to this account.',
    ].join(' - ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.gold.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, color: colors.gold, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  body,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({
    required this.label,
    required this.used,
    required this.limit,
  });

  final String label;
  final double used;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final usage = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final color = usage > 0.9
        ? colors.errorText
        : (usage > 0.7 ? colors.warningText : colors.gold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              label,
              variant: AppTextVariant.bodySmall,
              color: colors.textPrimary,
            ),
            AppText(
              '\$${used.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}',
              variant: AppTextVariant.monoSmall,
              color: colors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ProgressBar(value: usage, height: 6, color: color),
      ],
    );
  }
}
