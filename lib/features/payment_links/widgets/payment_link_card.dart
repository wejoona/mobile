import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/payment_links/models/payment_link.dart';
import 'package:usdc_wallet/features/payment_links/models/payment_link_status.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/clipboard_utils.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/utils/share_utils.dart';

/// Card displaying a payment link.
class PaymentLinkCard extends StatelessWidget {
  final PaymentLink link;
  final VoidCallback? onTap;

  const PaymentLinkCard({super.key, required this.link, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(
                    alpha: colors.isDark ? 0.14 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(Icons.link_rounded, color: colors.gold, size: 21),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AmountText.fromText(
                      formatCurrency(link.amount, link.currency),
                      size: AmountTextSize.medium,
                      color: colors.textPrimary,
                    ),
                    if (link.description != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        link.description!,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusPill(
                label: link.status.displayName(isFrench),
                tone: _statusTone,
                compact: true,
                emphasis: link.isPaid,
              ),
            ],
          ),
          if (link.isActive) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: AppLocalizations.of(context)!.action_copy,
                    onPressed: () => ClipboardUtils.copy(link.url),
                    variant: AppButtonVariant.secondary,
                    icon: Icons.copy_rounded,
                    size: AppButtonSize.small,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: AppLocalizations.of(context)!.action_share,
                    onPressed: () => ShareUtils.sharePaymentLink(
                      url: link.url,
                      amount: link.amount,
                      currency: link.currency,
                      description: link.description,
                    ),
                    icon: Icons.share_rounded,
                    size: AppButtonSize.small,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  StatusTone get _statusTone {
    switch (link.status) {
      case PaymentLinkStatus.paid:
        return StatusTone.success;
      case PaymentLinkStatus.viewed:
        return StatusTone.brand;
      case PaymentLinkStatus.expired:
      case PaymentLinkStatus.cancelled:
        return StatusTone.neutral;
      case PaymentLinkStatus.pending:
        return StatusTone.info;
    }
  }
}
