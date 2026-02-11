import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';

/// A tile representing a deposit method.
class DepositMethodTile extends StatelessWidget {
  const DepositMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isEnabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isEnabled;

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
          child: Icon(icon, color: colors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
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
