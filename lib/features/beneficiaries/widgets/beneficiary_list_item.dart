import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';

/// A single beneficiary list item.
class BeneficiaryListItem extends StatelessWidget {
  const BeneficiaryListItem({
    super.key,
    required this.beneficiary,
    this.onTap,
    this.trailing,
  });

  final Beneficiary beneficiary;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          UserAvatar(
            firstName: beneficiary.name.split(' ').first,
            lastName: beneficiary.name.split(' ').length > 1
                ? beneficiary.name.split(' ').last
                : null,
            size: 40,
            showBorder: beneficiary.accountType == AccountType.joonapayUser,
            borderColor: colors.gold,
          ),
          if (beneficiary.accountType == AccountType.joonapayUser)
            const Positioned(
              right: -2,
              bottom: -2,
              child: KoridoAccountBadge(compact: true),
            ),
        ],
      ),
      title: Row(
        children: [
          Flexible(
            child: AppText(
              beneficiary.name,
              overflow: TextOverflow.ellipsis,
              variant: AppTextVariant.bodyLarge,
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (beneficiary.accountType == AccountType.joonapayUser) ...[
            SizedBox(width: AppSpacing.xs),
            const KoridoAccountBadge(compact: true),
          ],
        ],
      ),
      subtitle: AppText(
        beneficiary.phoneE164 ?? "",
        variant: AppTextVariant.bodySmall,
        color: colors.textSecondary,
      ),
      trailing:
          trailing ??
          (beneficiary.isFavorite
              ? Icon(Icons.star, color: colors.warning, size: 20)
              : null),
    );
  }
}
