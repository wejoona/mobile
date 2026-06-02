import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/bank_account.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Card displaying a linked bank account.
class BankAccountCard extends StatelessWidget {
  final BankAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const BankAccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: colors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        account.bankName,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (account.isDefault) ...[
                      const SizedBox(width: AppSpacing.sm),
                      StatusPill(
                        label: l10n.common_default,
                        tone: StatusTone.brand,
                        compact: true,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  account.maskedAccount,
                  variant: AppTextVariant.monoSmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (account.isVerified)
            StatusPill(
              label: l10n.common_verified,
              tone: StatusTone.success,
              icon: Icons.verified_user_rounded,
              compact: true,
            )
          else if (account.isPending)
            StatusPill(
              label: l10n.kyc_pending,
              tone: StatusTone.warning,
              icon: Icons.hourglass_top_rounded,
              compact: true,
            ),
        ],
      ),
    );
  }
}
