import 'package:flutter/material.dart';
import 'package:usdc_wallet/features/payment_links/models/payment_link.dart';
import 'package:usdc_wallet/utils/clipboard_utils.dart';
import 'package:usdc_wallet/utils/share_utils.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Card displaying a payment link.
class PaymentLinkCard extends StatelessWidget {
  final PaymentLink link;
  final VoidCallback? onTap;

  const PaymentLinkCard({super.key, required this.link, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = link.isPaid ? context.colors.success : (link.isExpired ? context.colors.textSecondary : theme.colorScheme.primary);
    final statusLabel = link.isPaid ? 'Paid' : (link.isExpired ? 'Expired' : 'Active');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.link_rounded, color: theme.colorScheme.onPrimaryContainer, size: 20),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatCurrency(link.amount, link.currency), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (link.description != null)
                          Text(link.description!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(statusLabel, style: AppTypography.labelMedium.copyWith(color: statusColor)),
                  ),
                ],
              ),
              if (link.isActive) ...[
                SizedBox(height: AppSpacing.md),
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
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: AppLocalizations.of(context)!.action_share,
                        onPressed: () => ShareUtils.sharePaymentLink(url: link.url, amount: link.amount, currency: link.currency, description: link.description),
                        icon: Icons.share_rounded,
                        size: AppButtonSize.small,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
