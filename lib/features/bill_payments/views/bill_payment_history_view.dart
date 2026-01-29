import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/bill_payments/bill_payments_service.dart';
import '../providers/bill_payments_provider.dart';
import '../widgets/provider_card.dart';

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
        title: const AppText(
          'Payment History',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filters
          if (_selectedCategory != null || _selectedStatus != null)
            _buildActiveFilters(colors),

          // History List
          Expanded(
            child: historyAsync.when(
              data: (data) {
                if (data.items.isEmpty) {
                  return _buildEmptyState(colors);
                }

                // Group by date
                final grouped = _groupByDate(data.items);

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
              error: (error, _) => _buildErrorState(colors, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (_selectedCategory != null)
            _buildFilterChip(
              colors,
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
              colors,
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
              'Clear',
              style: TextStyle(color: colors.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeColors colors, {
    required String label,
    required VoidCallback onRemove,
  }) {
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
        color: colors.textSecondary,
      ),
      onDeleted: onRemove,
      backgroundColor: colors.elevated,
      side: BorderSide(color: colors.borderSubtle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
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
            'No Payment History',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: AppText(
              'Your bill payments will appear here',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.push('/bill-payments'),
            icon: const Icon(Icons.add),
            label: const Text('Pay a Bill'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.gold,
              foregroundColor: colors.canvas,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeColors colors, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.errorBase.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.errorText,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            'Failed to Load History',
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
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(billPaymentHistoryProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.gold,
              foregroundColor: colors.canvas,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<BillPaymentHistoryItem>> _groupByDate(
    List<BillPaymentHistoryItem> items,
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
        label = 'Today';
      } else if (itemDate == yesterday) {
        label = 'Yesterday';
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
    final colors = context.colors;
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
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppText(
            'Filter Payments',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Category Filter
          AppText(
            'Category',
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildFilterOption(colors, null, 'All', _category == null, (v) {
                setState(() => _category = v);
              }),
              ...BillCategory.values.map((cat) => _buildFilterOption(
                    colors,
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
            'Status',
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildFilterOption(colors, null, 'All', _status == null, (v) {
                setState(() => _status = v);
              }),
              _buildFilterOption(colors, 'completed', 'Completed', _status == 'completed', (v) {
                setState(() => _status = v);
              }),
              _buildFilterOption(colors, 'pending', 'Pending', _status == 'pending', (v) {
                setState(() => _status = v);
              }),
              _buildFilterOption(colors, 'failed', 'Failed', _status == 'failed', (v) {
                setState(() => _status = v);
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_category, _status),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: colors.canvas,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    ThemeColors colors,
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
          color: isSelected ? colors.gold : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
            width: 1,
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: isSelected ? colors.canvas : colors.textPrimary,
        ),
      ),
    );
  }
}
