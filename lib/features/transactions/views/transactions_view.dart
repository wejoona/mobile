import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final state = ref.watch(filteredPaginatedTransactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final activeFilterCount = filter.activeFilterCount;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _showSearch
            ? _buildSearchField()
            : const AppText(
                'Transactions',
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
                    decoration: const BoxDecoration(
                      color: AppColors.gold500,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: const TextStyle(
                        color: AppColors.obsidian,
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
          if (filter.hasActiveFilters) _buildActiveFiltersBar(filter),

          // Transactions list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(filteredPaginatedTransactionsProvider.notifier)
                    .refresh();
              },
              color: AppColors.gold500,
              backgroundColor: AppColors.slate,
              child: state.isLoading && state.transactions.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.gold500),
                    )
                  : state.error != null
                      ? _buildErrorState(state.error!)
                      : state.transactions.isEmpty
                          ? _buildEmptyState(filter)
                          : _buildTransactionsList(
                              context,
                              state.transactions,
                              state,
                              ref,
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.textTertiary,
        ),
        border: InputBorder.none,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textTertiary,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                onPressed: () {
                  _searchController.clear();
                  ref.read(transactionFilterProvider.notifier).setSearch(null);
                },
              )
            : null,
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildActiveFiltersBar(TransactionFilter filter) {
    final chips = <Widget>[];

    if (filter.type != null) {
      chips.add(_buildFilterChip(
        label: _getTypeName(filter.type!),
        onRemove: () => ref.read(transactionFilterProvider.notifier).setType(null),
      ));
    }

    if (filter.status != null) {
      chips.add(_buildFilterChip(
        label: _capitalize(filter.status!),
        onRemove: () => ref.read(transactionFilterProvider.notifier).setStatus(null),
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
            child: const Text(
              'Clear all',
              style: TextStyle(
                color: AppColors.gold500,
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
  }) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
        deleteIcon: const Icon(
          Icons.close,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onDeleted: onRemove,
        backgroundColor: AppColors.elevated,
        side: const BorderSide(color: AppColors.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'deposit':
        return 'Deposits';
      case 'withdrawal':
        return 'Withdrawals';
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

  Widget _buildEmptyState(TransactionFilter filter) {
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
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
                color: AppColors.textTertiary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              hasFilters ? 'No Results Found' : 'No Transactions',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AppText(
                hasFilters
                    ? 'Try adjusting your filters or search query to find what you\'re looking for.'
                    : 'Your transaction history will appear here once you make your first deposit or transfer.',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
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
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold500,
                  side: const BorderSide(color: AppColors.gold500),
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

  Widget _buildErrorState(String error) {
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
          const AppText(
            'Something Went Wrong',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(filteredPaginatedTransactionsProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold500,
              foregroundColor: AppColors.obsidian,
            ),
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
  ) {
    // Group transactions by date
    final grouped = _groupByDate(transactions);

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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(color: AppColors.gold500),
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
          );
        },
      ),
    );
  }

  Map<String, List<Transaction>> _groupByDate(List<Transaction> transactions) {
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
        label = 'Today';
      } else if (txDate == yesterday) {
        label = 'Yesterday';
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
  });

  final String date;
  final List<Transaction> transactions;
  final ValueChanged<Transaction> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: AppText(
            date,
            variant: AppTextVariant.labelMedium,
            color: AppColors.textTertiary,
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
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return 'Transfer Received';
      case TransactionType.transferExternal:
        return 'Transfer Sent';
    }
  }

  String _getTransactionSubtitle(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Mobile Money Deposit';
      case TransactionType.withdrawal:
        return 'Mobile Money Withdrawal';
      case TransactionType.transferInternal:
        return 'From JoonaPay User';
      case TransactionType.transferExternal:
        return 'External Wallet';
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
