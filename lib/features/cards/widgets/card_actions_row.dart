import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/card.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Quick action row for card management.
class CardActionsRow extends StatelessWidget {
  final KoridoCard card;
  final VoidCallback? onFreeze;
  final VoidCallback? onBlock;
  final VoidCallback? onDetails;
  final VoidCallback? onSettings;

  const CardActionsRow({
    super.key,
    required this.card,
    this.onFreeze,
    this.onBlock,
    this.onDetails,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionItem(
            icon: card.status == CardStatus.frozen
                ? Icons.play_arrow_rounded
                : Icons.pause_rounded,
            label: card.status == CardStatus.frozen
                ? l10n.cards_unfreezeCard
                : l10n.cards_freezeCard,
            tone: _ActionTone.brand,
            onTap: onFreeze,
          ),
          _ActionItem(
            icon: Icons.block_rounded,
            label: l10n.cards_blockCard,
            tone: _ActionTone.danger,
            onTap: onBlock,
          ),
          _ActionItem(
            icon: Icons.info_outline_rounded,
            label: 'Details',
            onTap: onDetails,
          ),
          _ActionItem(
            icon: Icons.tune_rounded,
            label: 'Settings',
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

enum _ActionTone { neutral, brand, danger }

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final _ActionTone tone;

  const _ActionItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.tone = _ActionTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = switch (tone) {
      _ActionTone.brand => colors.gold,
      _ActionTone.danger => colors.errorText,
      _ActionTone.neutral => colors.iconSecondary,
    };
    final background = switch (tone) {
      _ActionTone.brand => colors.gold.withValues(alpha: 0.10),
      _ActionTone.danger => colors.error.withValues(alpha: 0.10),
      _ActionTone.neutral => colors.elevated,
    };

    return SizedBox(
      width: 72,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Icon(icon, size: 21, color: foreground),
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                label,
                variant: AppTextVariant.labelSmall,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
