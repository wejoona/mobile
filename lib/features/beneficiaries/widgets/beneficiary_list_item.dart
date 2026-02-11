import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../models/beneficiary.dart';

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
    final initials = _getInitials(beneficiary.name);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        child: Text(
          initials,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        beneficiary.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        beneficiary.phone,
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
