import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/cards_provider.dart';
import '../widgets/virtual_card_widget.dart';

/// Card Detail View
///
/// Shows full card details with copy to clipboard and CVV reveal
class CardDetailView extends ConsumerStatefulWidget {
  const CardDetailView({
    super.key,
    required this.cardId,
  });

  final String cardId;

  @override
  ConsumerState<CardDetailView> createState() => _CardDetailViewState();
}

class _CardDetailViewState extends ConsumerState<CardDetailView> {
  bool _showCVV = false;
  bool _showFullNumber = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(cardsProvider);
    final card = state.selectedCard;

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
          l10n.cards_cardDetails,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: colors.textPrimary),
            onPressed: () => context.push('/cards/settings/${card.id}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Virtual card display
            VirtualCardWidget(
              card: card,
              showFullNumber: _showFullNumber,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Card details section
            AppText(
              l10n.cards_cardInformation,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),

            const SizedBox(height: AppSpacing.md),

            // Card Number
            _buildDetailRow(
              context,
              l10n,
              colors,
              label: l10n.cards_cardNumber,
              value: _showFullNumber ? card.cardNumber : card.maskedNumber,
              icon: _showFullNumber ? Icons.visibility_off : Icons.visibility,
              onIconPressed: () {
                setState(() => _showFullNumber = !_showFullNumber);
              },
              onCopy: () => _copyToClipboard(context, l10n, card.cardNumber),
            ),

            const SizedBox(height: AppSpacing.md),

            // CVV
            _buildDetailRow(
              context,
              l10n,
              colors,
              label: l10n.cards_cvv,
              value: _showCVV ? card.cvv : '***',
              icon: _showCVV ? Icons.visibility_off : Icons.visibility,
              onIconPressed: () {
                setState(() => _showCVV = !_showCVV);
              },
              onCopy: () => _copyToClipboard(context, l10n, card.cvv),
            ),

            const SizedBox(height: AppSpacing.md),

            // Expiry
            _buildDetailRow(
              context,
              l10n,
              colors,
              label: l10n.cards_expiryDate,
              value: card.expiry,
              onCopy: () => _copyToClipboard(context, l10n, card.expiry),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        l10n.cards_spent,
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                      ),
                      AppText(
                        '${card.currency} ${card.spentAmount.toStringAsFixed(2)}',
                        variant: AppTextVariant.labelLarge,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: card.spendingLimit > 0
                        ? card.spentAmount / card.spendingLimit
                        : 0,
                    backgroundColor: colors.borderSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        l10n.cards_limit,
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textSecondary,
                      ),
                      AppText(
                        '${card.currency} ${card.spendingLimit.toStringAsFixed(2)}',
                        variant: AppTextVariant.labelLarge,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Actions
            AppButton(
              label: l10n.cards_viewTransactions,
              onPressed: () => context.push('/cards/transactions/${card.id}'),
              variant: AppButtonVariant.secondary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.md),

            AppButton(
              label: card.isFrozen
                  ? l10n.cards_unfreezeCard
                  : l10n.cards_freezeCard,
              onPressed: () => _toggleFreeze(context, l10n, card.id),
              variant: card.isFrozen
                  ? AppButtonVariant.success
                  : AppButtonVariant.secondary,
              isFullWidth: true,
              icon: card.isFrozen ? Icons.play_arrow : Icons.ac_unit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors, {
    required String label,
    required String value,
    IconData? icon,
    VoidCallback? onIconPressed,
    VoidCallback? onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  value,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textPrimary,
                ),
              ],
            ),
          ),
          if (icon != null && onIconPressed != null)
            IconButton(
              icon: Icon(icon, color: colors.textSecondary),
              onPressed: onIconPressed,
            ),
          if (onCopy != null)
            IconButton(
              icon: Icon(Icons.copy, color: colors.gold),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }

  void _copyToClipboard(
    BuildContext context,
    AppLocalizations l10n,
    String text,
  ) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.cards_copiedToClipboard),
        backgroundColor: context.colors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleFreeze(
    BuildContext context,
    AppLocalizations l10n,
    String cardId,
  ) async {
    final card = ref.read(cardsProvider).selectedCard;
    if (card == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: AppText(
          card.isFrozen ? l10n.cards_unfreezeCard : l10n.cards_freezeCard,
          variant: AppTextVariant.titleMedium,
          color: context.colors.textPrimary,
        ),
        content: AppText(
          card.isFrozen
              ? l10n.cards_unfreezeConfirmation
              : l10n.cards_freezeConfirmation,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: AppText(
              l10n.action_cancel,
              variant: AppTextVariant.labelLarge,
              color: context.colors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: AppText(
              l10n.action_confirm,
              variant: AppTextVariant.labelLarge,
              color: context.colors.gold,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = card.isFrozen
        ? await ref.read(cardsProvider.notifier).unfreezeCard(cardId)
        : await ref.read(cardsProvider.notifier).freezeCard(cardId);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            card.isFrozen
                ? l10n.cards_cardUnfrozen
                : l10n.cards_cardFrozen,
          ),
          backgroundColor: context.colors.success,
        ),
      );
    }
  }
}
