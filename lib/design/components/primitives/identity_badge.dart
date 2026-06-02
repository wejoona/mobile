import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/status_pill.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

enum IdentityBadgeKind {
  koridoMember,
  identityVerified,
  identityPending,
  actionRequired,
}

/// Shared identity/trust badge.
///
/// Keep account membership separate from legal identity verification.
class IdentityBadge extends StatelessWidget {
  const IdentityBadge({
    super.key,
    required this.kind,
    this.compact = false,
    this.label,
  });

  final IdentityBadgeKind kind;
  final bool compact;
  final String? label;

  const IdentityBadge.koridoMember({
    super.key,
    this.compact = false,
    this.label,
  }) : kind = IdentityBadgeKind.koridoMember;

  const IdentityBadge.identityVerified({
    super.key,
    this.compact = false,
    this.label,
  }) : kind = IdentityBadgeKind.identityVerified;

  @override
  Widget build(BuildContext context) {
    final spec = _spec;
    final message = label ?? spec.label;

    if (compact) {
      final colors = context.colors;
      return Tooltip(
        message: message,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _compactBackground(colors),
            shape: BoxShape.circle,
            border: Border.all(
              color: _compactForeground(colors).withValues(alpha: 0.34),
              width: 1,
            ),
          ),
          child: Icon(spec.icon, size: 12, color: _compactForeground(colors)),
        ),
      );
    }

    return Tooltip(
      message: message,
      child: StatusPill(
        label: message,
        tone: spec.tone,
        icon: spec.icon,
        compact: true,
        emphasis: true,
      ),
    );
  }

  Color _compactForeground(ThemeColors colors) {
    switch (kind) {
      case IdentityBadgeKind.koridoMember:
        return colors.gold;
      case IdentityBadgeKind.identityVerified:
        return colors.successText;
      case IdentityBadgeKind.identityPending:
        return colors.warningText;
      case IdentityBadgeKind.actionRequired:
        return colors.errorText;
    }
  }

  Color _compactBackground(ThemeColors colors) {
    final foreground = _compactForeground(colors);
    return foreground.withValues(alpha: colors.isDark ? 0.18 : 0.11);
  }

  _IdentityBadgeSpec get _spec {
    switch (kind) {
      case IdentityBadgeKind.koridoMember:
        return const _IdentityBadgeSpec(
          label: 'Korido member',
          icon: Icons.account_balance_wallet_rounded,
          tone: StatusTone.brand,
        );
      case IdentityBadgeKind.identityVerified:
        return const _IdentityBadgeSpec(
          label: 'Identity verified',
          icon: Icons.verified_user_rounded,
          tone: StatusTone.success,
        );
      case IdentityBadgeKind.identityPending:
        return const _IdentityBadgeSpec(
          label: 'Identity review',
          icon: Icons.hourglass_top_rounded,
          tone: StatusTone.warning,
        );
      case IdentityBadgeKind.actionRequired:
        return const _IdentityBadgeSpec(
          label: 'Action required',
          icon: Icons.error_outline_rounded,
          tone: StatusTone.danger,
        );
    }
  }
}

class _IdentityBadgeSpec {
  const _IdentityBadgeSpec({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final StatusTone tone;
}
