import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';

/// Card Settings View
///
/// Manage card limits, freeze/unfreeze
class CardSettingsView extends ConsumerStatefulWidget {
  const CardSettingsView({
    super.key,
    required this.cardId,
  });

  final String cardId;

  @override
  ConsumerState<CardSettingsView> createState() => _CardSettingsViewState();
}

class _CardSettingsViewState extends ConsumerState<CardSettingsView> {
  final _limitController = TextEditingController();

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    // ignore: unused_local_variable
    final __state = ref.watch(cardsProvider);
    final card = ref.watch(selectedCardProvider(widget.cardId));

    if (card == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: AppText(
            l10n.cards_cardNotFound,
            variant: AppTextVariant.bodyLarge,
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.cards_cardSettings,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card status section
            AppText(
              l10n.cards_cardStatus,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),

            const SizedBox(height: AppSpacing.md),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    card.isFrozen ? Icons.ac_unit : Icons.check_circle,
                    color: card.isFrozen ? colors.info : colors.success,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          card.isFrozen
                              ? l10n.cards_statusFrozen
                              : l10n.cards_statusActive,
                          variant: AppTextVariant.labelLarge,
                          color: colors.textPrimary,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          card.isFrozen
                              ? l10n.cards_statusFrozenDescription
                              : l10n.cards_statusActiveDescription,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: !card.isFrozen,
                    onChanged: (value) => _toggleFreeze(context, l10n, card.id),
                    activeColor: colors.gold,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Spending limit section
            AppText(
              l10n.cards_spendingLimit,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),

            const SizedBox(height: AppSpacing.md),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AppText(
                          l10n.cards_currentLimit,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        '${card.currency} ${(card.spendingLimit ?? 0).toStringAsFixed(2)}',
                        variant: AppTextVariant.labelLarge,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AppText(
                          l10n.cards_availableLimit,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        '${card.currency} ${card.availableLimit.toStringAsFixed(2)}',
                        variant: AppTextVariant.labelLarge,
                        color: colors.gold,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            AppButton(
              label: l10n.cards_updateLimit,
              onPressed: () => _showUpdateLimitDialog(context, l10n, colors, card),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
              icon: Icons.edit,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Danger zone
            AppText(
              l10n.cards_dangerZone,
              variant: AppTextVariant.titleMedium,
              color: colors.error,
            ),

            const SizedBox(height: AppSpacing.md),

            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.cards_blockCard,
                    variant: AppTextVariant.labelLarge,
                    color: colors.error,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    l10n.cards_blockCardDescription,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.cards_blockCardButton,
                    onPressed: () => _showBlockDialog(context, l10n, colors, card.id),
                    variant: AppButtonVariant.danger,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFreeze(
    BuildContext context,
    AppLocalizations l10n,
    String cardId,
  ) async {
    final card = ref.read(selectedCardProvider(cardId));
    if (card == null) return;

    if (card.isFrozen) {
      await ref.read(cardActionsProvider).unfreezeCard(cardId);
    } else {
      await ref.read(cardActionsProvider).freezeCard(cardId);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            card.isFrozen ? l10n.cards_cardUnfrozen : l10n.cards_cardFrozen,
          ),
          backgroundColor: context.colors.success,
        ),
      );
    }
  }

  Future<void> _showUpdateLimitDialog(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
    dynamic card,
  ) async {
    // ignore: avoid_dynamic_calls
    _limitController.text = (card.spendingLimit ?? 0).toStringAsFixed(0);

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: AppText(
          l10n.cards_updateLimit,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              label: l10n.cards_newLimit,
              controller: _limitController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.cards_limitRange,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(
              l10n.action_cancel,
              variant: AppTextVariant.labelLarge,
              color: colors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              final newLimit = double.tryParse(_limitController.text);
              if (newLimit != null && newLimit >= 10 && newLimit <= 10000) {
                Navigator.pop(dialogContext, newLimit);
              }
            },
            child: AppText(
              l10n.action_save,
              variant: AppTextVariant.labelLarge,
              color: colors.gold,
            ),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      await ref
          .read(cardActionsProvider)
          // ignore: avoid_dynamic_calls
          .updateSpendingLimit(card.id, dailyLimit: result, transactionLimit: result);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cards_limitUpdated),
            backgroundColor: context.colors.success,
          ),
        );
      }
    }
  }

  Future<void> _showBlockDialog(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
    String cardId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: AppText(
          l10n.cards_blockCard,
          variant: AppTextVariant.titleMedium,
          color: colors.error,
        ),
        content: AppText(
          l10n.cards_blockCardConfirmation,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText(
              l10n.action_cancel,
              variant: AppTextVariant.labelLarge,
              color: colors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: AppText(
              l10n.action_confirm,
              variant: AppTextVariant.labelLarge,
              color: colors.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(cardActionsProvider).cancelCard(cardId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cards_cardBlocked),
              backgroundColor: context.colors.error,
            ),
          );
          // Refresh cards list
          ref.invalidate(cardsProvider);
          context.pop();
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to block card: $e'),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    }
  }
}
