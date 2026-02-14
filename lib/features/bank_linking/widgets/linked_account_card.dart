/// Linked Account Card Widget
library;
import 'package:usdc_wallet/design/tokens/index.dart';

import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/bank_linking/models/linked_bank_account.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class LinkedAccountCard extends StatelessWidget {
  const LinkedAccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onDeposit,
    this.onWithdraw,
    this.onSetPrimary,
    this.onUnlink,
  });

  final LinkedBankAccount account;
  final VoidCallback? onTap;
  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onSetPrimary;
  final VoidCallback? onUnlink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: account.isPrimary
              ? Border.all(color: context.colors.gold, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Bank logo placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: AppText(
                      account.bankName.substring(0, 1),
                      style: AppTypography.headlineSmall.copyWith(
                        color: context.colors.gold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              account.bankName,
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (account.isPrimary)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.gold.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xs),
                              ),
                              child: AppText(
                                l10n.bankLinking_primary,
                                style: AppTypography.bodySmall.copyWith(
                                  color: context.colors.gold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 2),
                      AppText(
                        account.accountNumberMasked,
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, account.status),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            // Account holder name
            AppText(
              account.accountHolderName,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            if (account.availableBalance != null &&
                account.status == BankAccountStatus.verified) ...[
              SizedBox(height: AppSpacing.sm),
              AppText(
                '${l10n.bankLinking_balance}: ${_formatAmount(account.availableBalance!)} ${account.currency}',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (account.status == BankAccountStatus.verified) ...[
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      label: l10n.bankLinking_deposit,
                      icon: Icons.arrow_downward,
                      onTap: onDeposit,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      label: l10n.bankLinking_withdraw,
                      icon: Icons.arrow_upward,
                      onTap: onWithdraw,
                    ),
                  ),
                ],
              ),
            ],
            if (account.status == BankAccountStatus.pending) ...[
              SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: context.colors.gold.withValues(alpha: 0.1),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  ),
                  child: AppText(
                    l10n.bankLinking_verifyAccount,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, BankAccountStatus status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case BankAccountStatus.verified:
        color = context.colors.success;
        icon = Icons.check_circle;
        label = AppLocalizations.of(context)!.bankLinking_verified;
        break;
      case BankAccountStatus.pending:
        color = context.colors.warning;
        icon = Icons.pending;
        label = AppLocalizations.of(context)!.bankLinking_pending;
        break;
      case BankAccountStatus.failed:
        color = context.colors.error;
        icon = Icons.error;
        label = AppLocalizations.of(context)!.bankLinking_failed;
        break;
      case BankAccountStatus.suspended:
        color = context.colors.textTertiary;
        icon = Icons.block;
        label = AppLocalizations.of(context)!.bankLinking_suspended;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          AppText(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: context.colors.elevated,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: context.colors.gold),
          SizedBox(width: AppSpacing.xs),
          AppText(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}
