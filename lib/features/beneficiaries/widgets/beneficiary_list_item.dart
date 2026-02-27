import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/user_avatar.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';

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
      leading: UserAvatar(
        firstName: beneficiary.name.split(' ').first,
        lastName: beneficiary.name.split(' ').length > 1 ? beneficiary.name.split(' ').last : null,
        size: 40,
      ),
      title: Text(
        beneficiary.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        beneficiary.phoneE164 ?? "",
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: trailing ??
          (beneficiary.isFavorite
              ? Icon(Icons.star, color: colors.warning, size: 20)
              : null),
    );
  }

}
