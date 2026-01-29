import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/beneficiary.dart';

/// Beneficiary Card Widget
class BeneficiaryCard extends StatelessWidget {
  const BeneficiaryCard({
    super.key,
    required this.beneficiary,
    this.onTap,
    this.onLongPress,
    this.onFavoriteToggle,
    this.showMenu = true,
  });

  final Beneficiary beneficiary;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteToggle;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSpacing.md),
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // Account type icon
          _buildAccountTypeIcon(),
          SizedBox(width: AppSpacing.md),

          // Name and phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  beneficiary.name,
                  variant: AppTextVariant.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
                if (beneficiary.phoneE164 != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    beneficiary.phoneE164!,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
                SizedBox(height: AppSpacing.xs),
                _buildAccountTypeLabel(l10n),
              ],
            ),
          ),

          // Favorite star
          if (onFavoriteToggle != null)
            IconButton(
              icon: Icon(
                beneficiary.isFavorite ? Icons.star : Icons.star_border,
                color: beneficiary.isFavorite
                    ? AppColors.gold500
                    : AppColors.textSecondary,
              ),
              onPressed: onFavoriteToggle,
            ),

          // Menu button
          if (showMenu && onLongPress != null)
            IconButton(
              icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
              onPressed: onLongPress,
            ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (beneficiary.accountType) {
      case AccountType.joonapayUser:
        iconData = Icons.person;
        iconColor = AppColors.gold500;
        break;
      case AccountType.externalWallet:
        iconData = Icons.account_balance_wallet;
        iconColor = AppColors.infoBase;
        break;
      case AccountType.bankAccount:
        iconData = Icons.account_balance;
        iconColor = AppColors.successBase;
        break;
      case AccountType.mobileMoney:
        iconData = Icons.phone_android;
        iconColor = AppColors.warningBase;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildAccountTypeLabel(AppLocalizations l10n) {
    String label;
    switch (beneficiary.accountType) {
      case AccountType.joonapayUser:
        label = l10n.beneficiaries_typeJoonapay;
        break;
      case AccountType.externalWallet:
        label = l10n.beneficiaries_typeWallet;
        break;
      case AccountType.bankAccount:
        label = l10n.beneficiaries_typeBank;
        break;
      case AccountType.mobileMoney:
        label = l10n.beneficiaries_typeMobileMoney;
        break;
    }

    return AppText(
      label,
      variant: AppTextVariant.bodySmall,
      color: AppColors.textSecondary,
    );
  }
}
