import 'package:flutter/material.dart';
import '../../../domain/entities/card.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionItem(
            icon: card.status == CardStatus.frozen ? Icons.play_arrow_rounded : Icons.pause_rounded,
            label: card.status == CardStatus.frozen ? 'Unfreeze' : 'Freeze',
            onTap: onFreeze,
          ),
          _ActionItem(icon: Icons.block_rounded, label: 'Block', onTap: onBlock),
          _ActionItem(icon: Icons.info_outline_rounded, label: 'Details', onTap: onDetails),
          _ActionItem(icon: Icons.settings_rounded, label: 'Settings', onTap: onSettings),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
