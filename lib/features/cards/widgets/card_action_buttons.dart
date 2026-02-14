import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Run 384: Card action buttons row (freeze, settings, details, etc.)
class CardActionButtons extends StatelessWidget {
  final bool isFrozen;
  final VoidCallback onFreeze;
  final VoidCallback onSettings;
  final VoidCallback onDetails;
  final VoidCallback onTransactions;

  const CardActionButtons({
    super.key,
    required this.isFrozen,
    required this.onFreeze,
    required this.onSettings,
    required this.onDetails,
    required this.onTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: isFrozen ? Icons.lock_open : Icons.lock,
          label: isFrozen ? 'Debloquer' : 'Bloquer',
          onTap: onFreeze,
          color: isFrozen ? context.colors.warning : context.colors.textSecondary,
        ),
        _ActionButton(
          icon: Icons.visibility_outlined,
          label: 'Details',
          onTap: onDetails,
        ),
        _ActionButton(
          icon: Icons.receipt_long_outlined,
          label: 'Transactions',
          onTap: onTransactions,
        ),
        _ActionButton(
          icon: Icons.settings_outlined,
          label: 'Parametres',
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.elevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color ?? context.colors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              label,
              style: AppTextStyle.bodySmall,
              color: context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
