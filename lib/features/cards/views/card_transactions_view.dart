import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/cards/providers/cards_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Card Transactions View
///
/// Shows transaction history for a specific card
class CardTransactionsView extends ConsumerStatefulWidget {
  const CardTransactionsView({required this.cardId, super.key});

  final String cardId;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('cardId', cardId));
  }

  @override
  ConsumerState<CardTransactionsView> createState() =>
      _CardTransactionsViewState();
}

class _CardTransactionsViewState extends ConsumerState<CardTransactionsView> {
  Future<List<Object?>>? _transactionsFuture;
  String? _loadedCardId;

  void _setTransactionsFuture() {
    _transactionsFuture = ref
        .read(cardActionsProvider)
        .loadCardTransactions(widget.cardId)
        .then((transactions) => transactions.cast<Object?>());
    _loadedCardId = widget.cardId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final asyncCards = ref.watch(cardsProvider);
    final card = ref.watch(selectedCardProvider(widget.cardId));

    if (asyncCards.isLoading && (asyncCards.value ?? []).isEmpty) {
      return _buildScaffold(
        context,
        l10n,
        colors,
        const Center(child: CircularProgressIndicator()),
      );
    }

    if (card == null) {
      return _buildScaffold(
        context,
        l10n,
        colors,
        _buildCardNotFoundState(context, l10n, colors),
      );
    }

    if (_loadedCardId != widget.cardId || _transactionsFuture == null) {
      _setTransactionsFuture();
    }

    return _buildScaffold(
      context,
      l10n,
      colors,
      RefreshIndicator(
        onRefresh: () async {
          setState(_setTransactionsFuture);
          await _transactionsFuture;
        },
        child: FutureBuilder<List<Object?>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(context, l10n, colors);
            }

            final transactions = snapshot.data ?? [];
            if (transactions.isEmpty) {
              return _buildEmptyState(context, l10n, colors);
            }

            return _buildTransactionsList(context, l10n, colors, transactions);
          },
        ),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
    Widget body,
  ) {
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
          onPressed: () => context.fsmSafePop(fallbackRoute: '/cards'),
        ),
        title: AppText(
          l10n.cards_transactions,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: body,
    );
  }

  Widget _buildCardNotFoundState(
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
            Icon(Icons.credit_card_off, size: 72, color: colors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.cards_cardNotFound,
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        Icon(Icons.receipt_long_outlined, size: 72, color: colors.warning),
        const SizedBox(height: AppSpacing.lg),
        AppText(
          l10n.cards_noTransactions,
          variant: AppTextVariant.headlineSmall,
          color: colors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(
          l10n.action_tryAgain,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
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
    List<Object?> transactions,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: transactions.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(context, colors, transaction);
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    ThemeColors colors,
    Object? transaction,
  ) {
    final status = _readString(transaction, ['status'], fallback: 'completed');
    final isSuccess = status == 'completed';
    final isPending = status == 'pending';
    final merchantName = _readString(transaction, [
      'merchantName',
      'merchant',
      'description',
    ], fallback: 'Card transaction');
    final merchantCategory = _readString(transaction, [
      'merchantCategory',
      'category',
      'type',
    ], fallback: 'shopping');
    final currency = _readString(transaction, ['currency'], fallback: 'USDC');
    final amount = _readAmount(transaction);
    final createdAt = _readDate(transaction);

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
              _getCategoryIcon(merchantCategory),
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
                  merchantName,
                  variant: AppTextVariant.labelLarge,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$merchantCategory • ${_formatDate(createdAt)}',
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
              AmountText.fromText(
                '-$currency ${amount.toStringAsFixed(2)}',
                size: AmountTextSize.small,
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
                  _getStatusLabel(status),
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

  String _readString(
    Object? transaction,
    List<String> keys, {
    required String fallback,
  }) {
    if (transaction is Map) {
      for (final key in keys) {
        final value = transaction[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }

    return fallback;
  }

  double _readAmount(Object? transaction) {
    final value = transaction is Map ? transaction['amount'] : null;

    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  DateTime _readDate(Object? transaction) {
    final value = transaction is Map
        ? transaction['createdAt'] ?? transaction['created_at']
        : null;

    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
