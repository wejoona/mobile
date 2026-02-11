import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';

/// A tile representing a deposit method.
class DepositMethodTile extends StatelessWidget {
  const DepositMethodTile({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.onTap,
    this.isEnabled = true,
    this.method,
    this.isSelected = false,
  });

  final IconData? icon;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isEnabled;
  final DepositMethod? method;
  final bool isSelected;

  IconData get _icon => icon ?? _iconForMethod(method);
  String get _title => title ?? method?.label ?? '';
  String get _subtitle => subtitle ?? method?.prefix ?? '';

  static IconData _iconForMethod(DepositMethod? m) {
    switch (m) {
      case DepositMethod.orangeMoney: return Icons.phone_android;
      case DepositMethod.mtnMomo: return Icons.phone_android;
      case DepositMethod.moovMoney: return Icons.phone_android;
      case DepositMethod.wave: return Icons.waves;
      case DepositMethod.bankTransfer: return Icons.account_balance;
      default: return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: ListTile(
        onTap: isEnabled ? onTap : null,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_icon, color: colors.primary),
        ),
        title: Text(
          _title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Text(
          _subtitle,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
