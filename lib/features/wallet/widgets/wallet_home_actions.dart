import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class WalletQuickActionData {
  const WalletQuickActionData({
    required this.icon,
    required this.label,
    required this.route,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String route;
  final VoidCallback? onTap;
}

class WalletQuickActionsRow extends StatelessWidget {
  const WalletQuickActionsRow({required this.actions, super.key});

  final List<WalletQuickActionData> actions;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (index, action) in actions.indexed) ...[
        Expanded(child: _WalletQuickActionButton(action: action)),
        if (index != actions.length - 1) const SizedBox(width: AppSpacing.md),
      ],
    ],
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<WalletQuickActionData>('actions', actions));
  }
}

class WalletQuickActionsGrid extends StatelessWidget {
  const WalletQuickActionsGrid({required this.actions, super.key});

  final List<WalletQuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < actions.length; index += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _WalletQuickActionButton(action: actions[index])),
            if (index + 1 < actions.length) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _WalletQuickActionButton(action: actions[index + 1]),
              ),
            ] else
              const Spacer(),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final (index, row) in rows.indexed) ...[
          row,
          if (index != rows.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<WalletQuickActionData>('actions', actions));
  }
}

class _WalletQuickActionButton extends StatelessWidget {
  const _WalletQuickActionButton({required WalletQuickActionData action})
    : _action = action;

  final WalletQuickActionData _action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return AppCard(
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        final onTap = _action.onTap;
        if (onTap != null) {
          onTap();
          return;
        }
        unawaited(context.fsmPush(_action.route));
      },
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.xs,
      ),
      child: SizedBox(
        height: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(_action.icon, color: colors.gold, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              _action.label,
              variant: AppTextVariant.labelSmall,
              color: isDark ? colors.textSecondary : colors.textPrimary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
