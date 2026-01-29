import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../domain/enums/index.dart';
import '../../../domain/entities/index.dart';
import '../providers/transactions_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showSearch = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(transactionFilterProvider.notifier).setSearch(query);
    });
  }

  void _showFilterSheet() {
    FilterBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(filteredPaginatedTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final activeFilterCount = filter.activeFilterCount;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _showSearch
            ? _buildSearchField(colors, l10n)
            : AppText(
                l10n.transactions_title,
                variant: AppTextVariant.titleLarge,
              ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_showSearch) {
              setState(() {
                _showSearch = false;
                _searchController.clear();
                ref.read(transactionFilterProvider.notifier).setSearch(null);
              });
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (_showSearch) {
                  _searchFocusNode.requestFocus();
                } else {
                  _searchController.clear();
                  ref.read(transactionFilterProvider.notifier).setSearch(null);
                }
              });
            },
          ),
          // Filter button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
                tooltip: 'Filter',
              ),
              if (activeFilterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.gold,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: TextStyle(
                        color: colors.canvas,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => context.push('/transactions/export'),
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters indicator
          if (filter.hasActiveFilters) _buildActiveFiltersBar(filter, colors, l10n),

          // Transactions list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(filteredPaginatedTransactionsProvider.notifier)
                    .refresh();
              },
              color: colors.gold,
              backgroundColor: colors.container,
              child: state.isLoading && state.transactions.isEmpty
                  ? _buildLoadingState(colors)
                  : state.error != null
                      ? _buildErrorState(state.error!, colors, l10n)
                      : state.transactions.isEmpty
                          ? _buildEmptyState(filter, colors, l10n)
                          : _buildTransactionsList(
                              context,
                              state.transactions,
                              state,
                              ref,
                              colors,
                              l10n,
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeColors colors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: AppInput(
            controller: _searchController,
            focusNode: _searchFocusNode,
            variant: AppInputVariant.search,
            hint: l10n.transactions_searchPlaceholder,
            prefixIcon: Icons.search,
            onChanged: _onSearchChanged,
          ),
        ),
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear, color: colors.textTertiary),
            onPressed: () {
              _searchController.clear();
              ref.read(transactionFilterProvider.notifier).setSearch(null);
              setState(() {});
            },
          ),
      ],
    );
  }

  Widget _buildActiveFiltersBar(TransactionFilter filter, ThemeColors colors, AppLocalizations l10n) {
    final chips = <Widget>[];

    if (filter.type != null) {
      chips.add(_buildFilterChip(
        label: _getTypeName(filter.type!, l10n),
        onRemove: () => ref.read(transactionFilterProvider.notifier).setType(null),
        colors: colors,
      ));
    }

    if (filter.status != null) {
      chips.add(_buildFilterChip(
        label: _capitalize(filter.status!),
        onRemove: () => ref.read(transactionFilterProvider.notifier).setStatus(null),
        colors: colors,
      ));
    }

    if (filter.startDate != null || filter.endDate != null) {
      final dateFormat = DateFormat('MMM d');
      String label;
      if (filter.startDate != null && filter.endDate != null) {
        label = '${dateFormat.format(filter.startDate!)} - ${dateFormat.format(filter.endDate!)}';
      } else if (filter.startDate != null) {
        label = 'From ${dateFormat.format(filter.startDate!)}';
      } else {
        label = 'Until ${dateFormat.format(filter.endDate!)}';
      }
      chips.add(_buildFilterChip(
        label: label,
        onRemove: () => ref.read(transactionFilterProvider.notifier).setDateRange(null, null),
        colors: colors,
      ));
    }

    if (filter.minAmount != null || filter.maxAmount != null) {
      String label;
      if (filter.minAmount != null && filter.maxAmount != null) {
        label = '\$${filter.minAmount!.toInt()} - \$${filter.maxAmount!.toInt()}';
      } else if (filter.minAmount != null) {
        label = '>\$${filter.minAmount!.toInt()}';
      } else {
        label = '<\$${filter.maxAmount!.toInt()}';
      }
      chips.add(_buildFilterChip(
        label: label,
        onRemove: () => ref.read(transactionFilterProvider.notifier).setAmountRange(null, null),
        colors: colors,
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chips,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(transactionFilterProvider.notifier).clearAll();
            },
            child: Text(
              l10n.action_clearAll,
              style: TextStyle(
                color: colors.gold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    required ThemeColors colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 12,
          ),
        ),
        deleteIcon: Icon(
          Icons.close,
          size: 16,
          color: colors.textSecondary,
        ),
        onDeleted: onRemove,
        backgroundColor: colors.elevated,
        side: BorderSide(color: colors.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }

  String _getTypeName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'deposit':
        return l10n.transactions_deposits;
      case 'withdrawal':
        return l10n.transactions_withdrawals;
      case 'transfer_internal':
        return 'Received';
      case 'transfer_external':
        return 'Sent';
      default:
        return type;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildLoadingState(ThemeColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: 8,
      itemBuilder: (context, index) {
        return SkeletonLayouts.transactionItem();
      },
    );
  }

  Widget _buildEmptyState(TransactionFilter filter, ThemeColors colors, AppLocalizations l10n) {
    final hasFilters = filter.hasActiveFilters || filter.hasSearchQuery;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.container,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
                color: colors.textTertiary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              hasFilters ? l10n.transactions_noResultsFound : l10n.transactions_noTransactions,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AppText(
                hasFilters
                    ? l10n.transactions_adjustFilters
                    : l10n.transactions_historyMessage,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  ref.read(transactionFilterProvider.notifier).clearAll();
                },
                icon: const Icon(Icons.filter_alt_off),
                label: Text(l10n.action_clearAll),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.gold,
                  side: BorderSide(color: colors.gold),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeColors colors, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.errorBase.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.errorText,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            l10n.transactions_somethingWentWrong,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: l10n.action_retry,
            onPressed: () {
              ref.read(filteredPaginatedTransactionsProvider.notifier).refresh();
            },
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List<Transaction> transactions,
    FilteredPaginatedTransactionsState state,
    WidgetRef ref,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    // Group transactions by date
    final grouped = _groupByDate(transactions, l10n);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            ref.read(filteredPaginatedTransactionsProvider.notifier).loadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: grouped.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= grouped.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(color: colors.gold),
              ),
            );
          }

          final entry = grouped.entries.elementAt(index);
          return _TransactionGroup(
            key: ValueKey('${entry.key}_${entry.value.first.id}'),
            date: entry.key,
            transactions: entry.value,
            onTransactionTap: (tx) =>
                context.push('/transactions/${tx.id}', extra: tx),
            l10n: l10n,
          );
        },
      ),
    );
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions, AppLocalizations l10n) {
    final grouped = <String, List<Transaction>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in transactions) {
      final txDate = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );

      String label;
      if (txDate == today) {
        label = l10n.transactions_today;
      } else if (txDate == yesterday) {
        label = l10n.transactions_yesterday;
      } else if (now.difference(txDate).inDays < 7) {
        label = DateFormat('EEEE').format(tx.createdAt);
      } else {
        label = DateFormat('MMM d, yyyy').format(tx.createdAt);
      }

      grouped.putIfAbsent(label, () => []).add(tx);
    }

    return grouped;
  }
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({
    super.key,
    required this.date,
    required this.transactions,
    required this.onTransactionTap,
    required this.l10n,
  });

  final String date;
  final List<Transaction> transactions;
  final ValueChanged<Transaction> onTransactionTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: AppText(
            date,
            variant: AppTextVariant.labelMedium,
            color: colors.textTertiary,
          ),
        ),
        ...transactions.map((tx) => TransactionRow(
              key: ValueKey(tx.id),
              title: _getTransactionTitle(tx.type, tx.description),
              subtitle: tx.description ?? _getTransactionSubtitle(tx.type),
              amount: tx.amount,
              date: tx.createdAt,
              type: _mapTransactionType(tx.type),
              status: tx.status,
              onTap: () => onTransactionTap(tx),
            )),
      ],
    );
  }

  String _getTransactionTitle(TransactionType type, String? description) {
    if (description != null && description.isNotEmpty) {
      return description;
    }
    switch (type) {
      case TransactionType.deposit:
        return l10n.transactions_deposit;
      case TransactionType.withdrawal:
        return l10n.transactions_withdrawal;
      case TransactionType.transferInternal:
        return l10n.transactions_transferReceived;
      case TransactionType.transferExternal:
        return l10n.transactions_transferSent;
    }
  }

  String _getTransactionSubtitle(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return l10n.transactions_mobileMoneyDeposit;
      case TransactionType.withdrawal:
        return l10n.transactions_mobileMoneyWithdrawal;
      case TransactionType.transferInternal:
        return l10n.transactions_fromJoonaPayUser;
      case TransactionType.transferExternal:
        return l10n.transactions_externalWallet;
    }
  }

  TransactionDisplayType _mapTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return TransactionDisplayType.deposit;
      case TransactionType.withdrawal:
        return TransactionDisplayType.withdrawal;
      case TransactionType.transferInternal:
        return TransactionDisplayType.transferIn;
      case TransactionType.transferExternal:
        return TransactionDisplayType.transferOut;
    }
  }
}
