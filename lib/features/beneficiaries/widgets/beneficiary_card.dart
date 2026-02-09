import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/theme/theme_extensions.dart';
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
    final colors = context.colors;
    final appColors = context.appColors;

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
                    color: colors.textSecondary,
                  ),
                ],
                SizedBox(height: AppSpacing.xs),
                _buildAccountTypeLabel(l10n, colors),
                if (beneficiary.lastTransferAt != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    '${l10n.beneficiaries_lastTransfer}: ${_formatLastTransfer(beneficiary.lastTransferAt!)}',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textTertiary,
                  ),
                ],
              ],
            ),
          ),

          // Favorite star
          if (onFavoriteToggle != null)
            IconButton(
              icon: Icon(
                beneficiary.isFavorite ? Icons.star : Icons.star_border,
                color: beneficiary.isFavorite
                    ? appColors.gold500
                    : colors.textSecondary,
              ),
              onPressed: onFavoriteToggle,
            ),

          // Menu button
          if (showMenu && onLongPress != null)
            IconButton(
              icon: Icon(Icons.more_vert, color: colors.textSecondary),
              onPressed: onLongPress,
            ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeIcon() {
    IconData iconData;
    Color iconColor;
    String? initial;

    switch (beneficiary.accountType) {
      case AccountType.joonapayUser:
        iconData = Icons.person;
        iconColor = AppColors.gold500; // Gold for JoonaPay users
        initial = beneficiary.name.isNotEmpty ? beneficiary.name[0].toUpperCase() : 'J';
        break;
      case AccountType.externalWallet:
        iconData = Icons.account_balance_wallet;
        iconColor = const Color(0xFF6B8DD6); // Purple accent
        break;
      case AccountType.bankAccount:
        iconData = Icons.account_balance;
        iconColor = const Color(0xFF5B9BD5); // Blue accent
        break;
      case AccountType.mobileMoney:
        iconData = Icons.phone_android;
        iconColor = const Color(0xFFFF9955); // Orange accent
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: initial != null
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
    );
  }

  Widget _buildAccountTypeLabel(AppLocalizations l10n, ThemeColors colors) {
    String label;
    Color badgeColor;

    switch (beneficiary.accountType) {
      case AccountType.joonapayUser:
        label = l10n.beneficiaries_typeJoonapay;
        badgeColor = AppColors.gold500;
        break;
      case AccountType.externalWallet:
        label = l10n.beneficiaries_typeWallet;
        badgeColor = const Color(0xFF6B8DD6); // Purple
        break;
      case AccountType.bankAccount:
        label = l10n.beneficiaries_typeBank;
        badgeColor = const Color(0xFF5B9BD5); // Blue
        break;
      case AccountType.mobileMoney:
        label = l10n.beneficiaries_typeMobileMoney;
        badgeColor = const Color(0xFFFF9955); // Orange
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.bodySmall,
        color: badgeColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatLastTransfer(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
