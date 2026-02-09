import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../design/utils/responsive_layout.dart';
import '../../../core/orientation/orientation_helper.dart';
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
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xxxl),
            // Illustration container with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.gold.withOpacity(colors.isDark ? 0.15 : 0.1),
                    colors.gold.withOpacity(colors.isDark ? 0.05 : 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xxxl),
                border: Border.all(
                  color: colors.gold.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background decoration circles
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colors.gold.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.gold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Main icon
                  Icon(
                    hasFilters ? Icons.search_off_rounded : Icons.receipt_long_rounded,
                    color: colors.gold,
                    size: 48,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              hasFilters ? l10n.transactions_noResultsFound : l10n.transactions_emptyStateTitle,
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: AppText(
                hasFilters
                    ? l10n.transactions_adjustFilters
                    : l10n.transactions_emptyStateMessage,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            if (hasFilters)
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              )
            else
              AppButton(
                label: l10n.transactions_emptyStateAction,
                onPressed: () => context.go('/deposit'),
                icon: Icons.add_circle_outline,
              ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeColors colors, AppLocalizations l10n) {
    // Determine error type for appropriate messaging
    final isConnectionError = error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('timeout') ||
        error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('socket');
    final isAuthError = error.toLowerCase().contains('unauthorized') ||
        error.toLowerCase().contains('401') ||
        error.toLowerCase().contains('authentication');
    final isNoAccountError = error.toLowerCase().contains('wallet not found') ||
        error.toLowerCase().contains('no wallet') ||
        error.toLowerCase().contains('account not found');

    // Select appropriate icon, title, and message
    IconData icon;
    Color iconColor;
    Color bgColor;
    String title;
    String message;
    String buttonLabel;
    VoidCallback buttonAction;

    if (isNoAccountError || isAuthError) {
      icon = Icons.account_balance_wallet_outlined;
      iconColor = colors.gold;
      bgColor = colors.gold.withOpacity(colors.isDark ? 0.15 : 0.1);
      title = l10n.transactions_noAccountTitle;
      message = l10n.transactions_noAccountMessage;
      buttonLabel = 'Create Wallet';
      buttonAction = () => context.go('/onboarding');
    } else if (isConnectionError) {
      icon = Icons.wifi_off_rounded;
      iconColor = colors.warningText;
      bgColor = colors.warningBg;
      title = l10n.transactions_connectionErrorTitle;
      message = l10n.transactions_connectionErrorMessage;
      buttonLabel = l10n.action_retry;
      buttonAction = () {
        ref.read(filteredPaginatedTransactionsProvider.notifier).refresh();
      };
    } else {
      icon = Icons.error_outline_rounded;
      iconColor = colors.errorText;
      bgColor = colors.errorBg;
      title = l10n.transactions_somethingWentWrong;
      message = error;
      buttonLabel = l10n.action_retry;
      buttonAction = () {
        ref.read(filteredPaginatedTransactionsProvider.notifier).refresh();
      };
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xxxl),
            // Error illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.xxxl),
                border: Border.all(
                  color: iconColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              title,
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: AppText(
                message,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: buttonLabel,
              onPressed: buttonAction,
              icon: isConnectionError ? Icons.refresh : null,
            ),
            if (!isNoAccountError && !isAuthError && context.canPop()) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => context.pop(),
                child: AppText(
                  'Go Back',
                  variant: AppTextVariant.labelLarge,
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
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
    final isTablet = ResponsiveLayout.isTabletOrLarger(context);
    final isLandscape = OrientationHelper.isLandscape(context);

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
      child: ConstrainedContent(
        child: ListView.builder(
          padding: OrientationHelper.padding(
            context,
            portrait: ResponsiveLayout.padding(
              context,
              mobile: const EdgeInsets.all(AppSpacing.screenPadding),
              tablet: const EdgeInsets.all(AppSpacing.xl),
            ),
            landscape: ResponsiveLayout.padding(
              context,
              mobile: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              tablet: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.lg,
              ),
            ),
          ),
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
              isTablet: isTablet,
              isLandscape: isLandscape,
            );
          },
        ),
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
    this.isTablet = false,
    this.isLandscape = false,
  });

  final String date;
  final List<Transaction> transactions;
  final ValueChanged<Transaction> onTransactionTap;
  final AppLocalizations l10n;
  final bool isTablet;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Use grid in landscape mode or on tablet with many items
    final shouldUseGrid = isLandscape || (isTablet && transactions.length > 3);
    final gridColumns = isLandscape ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: (isTablet || isLandscape) ? AppSpacing.lg : AppSpacing.md,
          ),
          child: AppText(
            date,
            variant: (isTablet || isLandscape) ? AppTextVariant.titleSmall : AppTextVariant.labelMedium,
            color: colors.textTertiary,
          ),
        ),
        // Grid layout for landscape or tablet with many items
        if (shouldUseGrid)
          AdaptiveGrid(
            tabletColumns: gridColumns,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: transactions.map((tx) => _buildTransactionCard(tx, colors)).toList(),
          )
        else
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

  Widget _buildTransactionCard(Transaction tx, ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.outlined,
      onTap: () => onTransactionTap(tx),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTransactionIcon(_mapTransactionType(tx.type), colors),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      _getTransactionTitle(tx.type, tx.description),
                      variant: AppTextVariant.labelLarge,
                      color: colors.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      tx.description ?? _getTransactionSubtitle(tx.type),
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                _formatAmount(tx.amount, _mapTransactionType(tx.type)),
                variant: AppTextVariant.titleMedium,
                color: _getAmountColor(_mapTransactionType(tx.type), colors),
              ),
              if (tx.status != null)
                _buildStatusBadge(tx.status!.name, colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionIcon(TransactionDisplayType type, ThemeColors colors) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case TransactionDisplayType.deposit:
        icon = Icons.arrow_downward;
        iconColor = colors.successText;
      case TransactionDisplayType.withdrawal:
        icon = Icons.arrow_upward;
        iconColor = colors.errorText;
      case TransactionDisplayType.transferIn:
        icon = Icons.call_received;
        iconColor = colors.successText;
      case TransactionDisplayType.transferOut:
        icon = Icons.send;
        iconColor = colors.warningText;
      case TransactionDisplayType.reward:
        icon = Icons.card_giftcard;
        iconColor = colors.gold;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(colors.isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildStatusBadge(String status, ThemeColors colors) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
        backgroundColor = colors.warningBg;
        textColor = colors.warningText;
        label = status == 'pending' ? 'Pending' : 'Processing';
      case 'completed':
      case 'success':
        backgroundColor = colors.successBg;
        textColor = colors.successText;
        label = 'Completed';
      case 'failed':
      case 'error':
        backgroundColor = colors.errorBg;
        textColor = colors.errorText;
        label = 'Failed';
      default:
        backgroundColor = colors.elevated;
        textColor = colors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.labelSmall,
        color: textColor,
      ),
    );
  }

  String _formatAmount(double amount, TransactionDisplayType type) {
    final isPositive = type == TransactionDisplayType.deposit ||
        type == TransactionDisplayType.transferIn ||
        type == TransactionDisplayType.reward;
    final sign = isPositive ? '+' : '-';
    return '$sign\$${amount.abs().toStringAsFixed(2)}';
  }

  Color _getAmountColor(TransactionDisplayType type, ThemeColors colors) {
    switch (type) {
      case TransactionDisplayType.deposit:
      case TransactionDisplayType.transferIn:
        return colors.successText; // Green for incoming
      case TransactionDisplayType.reward:
        return colors.gold; // Gold for rewards
      case TransactionDisplayType.withdrawal:
        return colors.errorText; // Red for withdrawals
      case TransactionDisplayType.transferOut:
        return colors.warningText; // Orange/amber for sent transfers
    }
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
