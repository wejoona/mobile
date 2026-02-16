import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/bill_payments/bill_payments_service.dart';
import 'package:usdc_wallet/features/bill_payments/providers/bill_payments_provider.dart';
import 'package:usdc_wallet/features/bill_payments/widgets/provider_card.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Bill Payment History View
class BillPaymentHistoryView extends ConsumerStatefulWidget {
  const BillPaymentHistoryView({super.key});

  @override
  ConsumerState<BillPaymentHistoryView> createState() => _BillPaymentHistoryViewState();
}

class _BillPaymentHistoryViewState extends ConsumerState<BillPaymentHistoryView> {
  String? _selectedCategory;
  String? _selectedStatus;
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final historyAsync = ref.watch(
      billPaymentHistoryProvider(BillPaymentHistoryParams(
        page: 1,
        limit: 20,
        category: _selectedCategory,
        status: _selectedStatus,
      )),
    );

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          l10n.billPayments_history,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.icon),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: colors.icon),
            onPressed: _showFilterSheet,
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filters
          if (_selectedCategory != null || _selectedStatus != null)
            _buildActiveFilters(l10n),

          // History List
          Expanded(
            child: historyAsync.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return _buildEmptyState(l10n);
                }

                // Group by date
                final grouped = _groupByDate(data.items, l10n);

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(billPaymentHistoryProvider);
                  },
                  color: colors.gold,
                  backgroundColor: colors.container,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 200) {
                        _loadMore(data);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      itemCount: grouped.length + (data.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= grouped.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: CircularProgressIndicator(
                                color: colors.gold,
                              ),
                            ),
                          );
                        }

                        final entry = grouped.entries.elementAt(index);
                        return _HistoryGroup(
                          date: entry.key,
                          items: entry.value,
                          onItemTap: (item) => _onItemTap(item),
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: colors.gold),
              ),
              error: (error, _) => _buildErrorState(l10n, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (_selectedCategory != null)
            _buildFilterChip(
              label: BillCategory.fromString(_selectedCategory!).displayName,
              onRemove: () {
                setState(() {
                  _selectedCategory = null;
                });
                ref.invalidate(billPaymentHistoryProvider);
              },
            ),
          if (_selectedStatus != null) ...[
            if (_selectedCategory != null) const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: _capitalizeStatus(_selectedStatus!),
              onRemove: () {
                setState(() {
                  _selectedStatus = null;
                });
                ref.invalidate(billPaymentHistoryProvider);
              },
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedStatus = null;
              });
              ref.invalidate(billPaymentHistoryProvider);
            },
            child: Text(
              'Effacer',
              style: TextStyle(color: context.colors.gold),
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
    final colors = context.colors;
    return Chip(
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
        color: colors.iconSecondary,
      ),
      onDeleted: onRemove,
      backgroundColor: colors.elevated,
      side: BorderSide(color: colors.borderSubtle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            'Aucun historique de paiement',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: AppText(
              'Vos paiements de factures apparaîtront ici',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Payer une facture',
            onPressed: () => context.push('/bill-payments'),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, String error) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.errorBg,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: colors.errorText,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            "Impossible de charger l'historique",
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
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.action_retry,
            onPressed: () {
              ref.invalidate(billPaymentHistoryProvider);
            },
            icon: Icons.refresh,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }

  Map<String, List<BillPaymentHistoryItem>> _groupByDate(
    List<BillPaymentHistoryItem> items,
    AppLocalizations l10n,
  ) {
    final grouped = <String, List<BillPaymentHistoryItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );

      String label;
      if (itemDate == today) {
        label = l10n.common_today;
      } else if (itemDate == yesterday) {
        label = l10n.transactions_yesterday;
      } else if (now.difference(itemDate).inDays < 7) {
        label = DateFormat('EEEE').format(item.createdAt);
      } else {
        label = DateFormat('MMM d, yyyy').format(item.createdAt);
      }

      grouped.putIfAbsent(label, () => []).add(item);
    }

    return grouped;
  }

  void _showFilterSheet() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => _FilterBottomSheet(
        selectedCategory: _selectedCategory,
        selectedStatus: _selectedStatus,
        onApply: (category, status) {
          setState(() {
            _selectedCategory = category;
            _selectedStatus = status;
          });
          ref.invalidate(billPaymentHistoryProvider);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _loadMore(BillPaymentHistoryResponse data) {
    if (_isLoadingMore || !data.hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Load more is handled by pagination params
  }

  void _onItemTap(BillPaymentHistoryItem item) {
    context.push('/bill-payments/success/${item.id}');
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1);
  }
}

class _HistoryGroup extends StatelessWidget {
  const _HistoryGroup({
    required this.date,
    required this.items,
    required this.onItemTap,
  });

  final String date;
  final List<BillPaymentHistoryItem> items;
  final ValueChanged<BillPaymentHistoryItem> onItemTap;

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
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ProviderListItem(
                payment: item,
                onTap: () => onItemTap(item),
              ),
            )),
      ],
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.selectedCategory,
    required this.selectedStatus,
    required this.onApply,
  });

  final String? selectedCategory;
  final String? selectedStatus;
  final void Function(String? category, String? status) onApply;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _category;
  late String? _status;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _status = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppText(
            'Filtrer les paiements',
            variant: AppTextVariant.titleMedium,
            color: context.colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Category Filter
          AppText(
            'Catégorie',
            variant: AppTextVariant.labelMedium,
            color: context.colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildFilterOption(null, 'All', _category == null, (v) {
                setState(() => _category = v);
              }),
              ...BillCategory.values.map((cat) => _buildFilterOption(
                    cat.value,
                    cat.displayName,
                    _category == cat.value,
                    (v) => setState(() => _category = v),
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Status Filter
          AppText(
            'Statut',
            variant: AppTextVariant.labelMedium,
            color: context.colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildFilterOption(null, 'All', _status == null, (v) {
                setState(() => _status = v);
              }),
              _buildFilterOption('completed', 'Completed', _status == 'completed', (v) {
                setState(() => _status = v);
              }),
              _buildFilterOption('pending', 'Pending', _status == 'pending', (v) {
                setState(() => _status = v);
              }),
              _buildFilterOption('failed', 'Failed', _status == 'failed', (v) {
                setState(() => _status = v);
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Apply Button
          AppButton(
            label: 'Appliquer les filtres',
            onPressed: () => widget.onApply(_category, _status),
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String? value,
    String label,
    bool isSelected,
    ValueChanged<String?> onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.gold : context.colors.container,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? context.colors.gold : context.colors.borderSubtle,
            width: 1,
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: isSelected ? context.colors.canvas : context.colors.textPrimary,
        ),
      ),
    );
  }
}
