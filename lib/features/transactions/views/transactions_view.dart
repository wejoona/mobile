import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../domain/enums/index.dart';
import '../../../domain/entities/index.dart';
import '../../../state/index.dart';

/// Filter state for transactions
enum TransactionFilter {
  all,
  deposits,
  withdrawals,
  transfersIn,
  transfersOut,
}

extension TransactionFilterExt on TransactionFilter {
  String get label {
    switch (this) {
      case TransactionFilter.all:
        return 'All';
      case TransactionFilter.deposits:
        return 'Deposits';
      case TransactionFilter.withdrawals:
        return 'Withdrawals';
      case TransactionFilter.transfersIn:
        return 'Received';
      case TransactionFilter.transfersOut:
        return 'Sent';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionFilter.all:
        return Icons.all_inclusive;
      case TransactionFilter.deposits:
        return Icons.arrow_downward;
      case TransactionFilter.withdrawals:
        return Icons.arrow_upward;
      case TransactionFilter.transfersIn:
        return Icons.call_received;
      case TransactionFilter.transfersOut:
        return Icons.send;
    }
  }
}

/// Local filter state notifier
class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => TransactionFilter.all;

  void setFilter(TransactionFilter filter) => state = filter;
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
  TransactionFilterNotifier.new,
);

/// Search state notifier
class TransactionSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) => state = query;
  void clear() => state = '';
}

final transactionSearchProvider =
    NotifierProvider<TransactionSearchNotifier, String>(
  TransactionSearchNotifier.new,
);

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionStateMachineProvider);
    final filter = ref.watch(transactionFilterProvider);
    final searchQuery = ref.watch(transactionSearchProvider);

    // Filter transactions
    final filteredTransactions = _filterTransactions(
      state.transactions,
      filter,
      searchQuery,
    );

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                ref.read(transactionSearchProvider.notifier).clear();
              });
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(transactionSearchProvider.notifier).clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => context.push('/transactions/export'),
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(filter),

          // Transactions list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(transactionStateMachineProvider.notifier)
                    .refresh();
              },
              color: AppColors.gold500,
              backgroundColor: AppColors.slate,
              child: state.isLoading && state.transactions.isEmpty
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.gold500),
                    )
                  : filteredTransactions.isEmpty
                      ? _buildEmptyState(filter, searchQuery)
                      : _buildTransactionsList(
                          context,
                          filteredTransactions,
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
      autofocus: true,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.textTertiary,
        ),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        ref.read(transactionSearchProvider.notifier).setSearch(value);
      },
    );
  }

  Widget _buildFilterChips(TransactionFilter currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: TransactionFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 16,
                    color: isSelected ? AppColors.obsidian : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(filter.label),
                ],
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.obsidian : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: AppColors.slate,
              selectedColor: AppColors.gold500,
              checkmarkColor: AppColors.obsidian,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? AppColors.gold500 : AppColors.borderSubtle,
              ),
              onSelected: (_) {
                ref.read(transactionFilterProvider.notifier).setFilter(filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Transaction> _filterTransactions(
    List<Transaction> transactions,
    TransactionFilter filter,
    String searchQuery,
  ) {
    var filtered = transactions;

    // Apply type filter
    switch (filter) {
      case TransactionFilter.all:
        break;
      case TransactionFilter.deposits:
        filtered = filtered
            .where((tx) => tx.type == TransactionType.deposit)
            .toList();
        break;
      case TransactionFilter.withdrawals:
        filtered = filtered
            .where((tx) => tx.type == TransactionType.withdrawal)
            .toList();
        break;
      case TransactionFilter.transfersIn:
        filtered = filtered
            .where((tx) => tx.type == TransactionType.transferInternal)
            .toList();
        break;
      case TransactionFilter.transfersOut:
        filtered = filtered
            .where((tx) => tx.type == TransactionType.transferExternal)
            .toList();
        break;
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((tx) {
        final description = tx.description?.toLowerCase() ?? '';
        final reference = tx.reference.toLowerCase();
        final amount = tx.amount.toString();
        return description.contains(query) ||
            reference.contains(query) ||
            amount.contains(query);
      }).toList();
    }

    return filtered;
  }

  Widget _buildEmptyState(TransactionFilter filter, String searchQuery) {
    String message;
    if (searchQuery.isNotEmpty) {
      message = 'No transactions matching "$searchQuery"';
    } else if (filter != TransactionFilter.all) {
      message = 'No ${filter.label.toLowerCase()} found';
    } else {
      message = 'Your transaction history will appear here';
    }

    return Center(
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
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
            'No Transactions',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: AppText(
              message,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List<Transaction> transactions,
    TransactionListState state,
    WidgetRef ref,
  ) {
    // Group transactions by date
    final grouped = _groupByDate(transactions);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            ref.read(transactionStateMachineProvider.notifier).loadMore();
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
              title: _getTransactionTitle(tx.type, tx.description),
              subtitle: tx.description ?? _getTransactionSubtitle(tx.type),
              amount: tx.amount,
              date: tx.createdAt,
              type: _mapTransactionType(tx.type),
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
