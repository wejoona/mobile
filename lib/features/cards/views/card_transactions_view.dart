import 'package:usdc_wallet/features/kyc/models/missing_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';

/// Card Transactions View
///
/// Shows transaction history for a specific card
class CardTransactionsView extends ConsumerStatefulWidget {
  const CardTransactionsView({
    super.key,
    required this.cardId,
  });

  final String cardId;

  @override
  ConsumerState<CardTransactionsView> createState() =>
      _CardTransactionsViewState();
}

class _CardTransactionsViewState extends ConsumerState<CardTransactionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cardActionsProvider).loadCardTransactions(widget.cardId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final asyncState = ref.watch(cardsProvider);
    final card = ref.watch(selectedCardProvider(widget.cardId));
    final cardsState = CardsState(
      cards: asyncState.value ?? [],
      selectedCard: card,
    );

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.cards_transactions,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(cardActionsProvider).loadCardTransactions(widget.cardId),
        child: cardsState.isLoading && cardsState.transactions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : cardsState.transactions.isEmpty
                ? _buildEmptyState(context, l10n, colors)
                : _buildTransactionsList(context, l10n, colors, cardsState),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.cards_noTransactions,
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              l10n.cards_noTransactionsDescription,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
    CardsState state,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: state.transactions.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final transaction = state.transactions[index];
        return _buildTransactionItem(context, colors, transaction);
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    ThemeColors colors,
    dynamic transaction,
  ) {
    final isSuccess = transaction.status == 'completed';
    final isPending = transaction.status == 'pending';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSuccess
                  ? colors.success.withValues(alpha: 0.1)
                  : isPending
                      ? colors.warning.withValues(alpha: 0.1)
                      : colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _getCategoryIcon(transaction.merchantCategory),
              color: isSuccess
                  ? colors.success
                  : isPending
                      ? colors.warning
                      : colors.error,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  transaction.merchantName,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${transaction.merchantCategory} • ${_formatDate(transaction.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '-${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                variant: AppTextVariant.labelLarge,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? colors.success.withValues(alpha: 0.1)
                      : isPending
                          ? colors.warning.withValues(alpha: 0.1)
                          : colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: AppText(
                  _getStatusLabel(transaction.status),
                  variant: AppTextVariant.labelSmall,
                  color: isSuccess
                      ? colors.success
                      : isPending
                          ? colors.warning
                          : colors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'utilities':
        return Icons.bolt_outlined;
      default:
        return Icons.shopping_cart_outlined;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Success';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
