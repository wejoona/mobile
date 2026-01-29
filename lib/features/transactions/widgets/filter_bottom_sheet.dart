import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/entities/index.dart';
import '../providers/transactions_provider.dart';

/// Bottom sheet for advanced transaction filtering
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  // Local state for editing filters before applying
  late String? _selectedType;
  late String? _selectedStatus;
  late DateRangeOption? _selectedDateRange;
  late DateTime? _customStartDate;
  late DateTime? _customEndDate;
  late RangeValues _amountRange;
  late String _sortBy;
  late String _sortOrder;

  // Amount range boundaries
  static const double _minAmount = 0;
  static const double _maxAmount = 10000;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _selectedType = null;
    _selectedStatus = null;
    _selectedDateRange = null;
    _customStartDate = null;
    _customEndDate = null;
    _amountRange = const RangeValues(_minAmount, _maxAmount);
    _sortBy = 'createdAt';
    _sortOrder = 'DESC';

    // Populate from current filter after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final filter = ref.read(transactionFilterProvider);
        setState(() {
          _selectedType = filter.type;
          _selectedStatus = filter.status;
          _selectedDateRange = _getDateRangeOption(filter);
          _customStartDate = filter.startDate;
          _customEndDate = filter.endDate;
          _amountRange = RangeValues(
            filter.minAmount ?? _minAmount,
            filter.maxAmount ?? _maxAmount,
          );
          _sortBy = filter.sortBy;
          _sortOrder = filter.sortOrder;
        });
      }
    });
  }

  DateRangeOption? _getDateRangeOption(TransactionFilter filter) {
    if (filter.startDate == null && filter.endDate == null) return null;
    // Could be improved to detect predefined ranges
    return DateRangeOption.custom;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  l10n.filters_title,
                  variant: AppTextVariant.titleLarge,
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    l10n.filters_reset,
                    style: TextStyle(color: colors.gold),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type
                  _buildSectionTitle(l10n.filters_transactionType, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTypeChips(colors),
                  const SizedBox(height: AppSpacing.xxl),

                  // Status
                  _buildSectionTitle(l10n.filters_status, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildStatusChips(colors),
                  const SizedBox(height: AppSpacing.xxl),

                  // Date Range
                  _buildSectionTitle(l10n.filters_dateRange, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDateRangeChips(colors),
                  if (_selectedDateRange == DateRangeOption.custom) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildCustomDatePickers(l10n),
                  ],
                  const SizedBox(height: AppSpacing.xxl),

                  // Amount Range
                  _buildSectionTitle(l10n.filters_amountRange, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildAmountRangeSlider(colors),
                  const SizedBox(height: AppSpacing.xxl),

                  // Sort Options
                  _buildSectionTitle(l10n.filters_sortBy, colors),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSortOptions(colors),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.gold,
                  foregroundColor: colors.canvas,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                onPressed: _applyFilters,
                child: Text(
                  'Apply Filters${_getActiveFilterCount() > 0 ? ' (${_getActiveFilterCount()})' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeColors colors) {
    return AppText(
      title,
      variant: AppTextVariant.labelLarge,
      color: colors.textSecondary,
    );
  }

  Widget _buildTypeChips(ThemeColors colors) {
    final types = [
      (null, 'All'),
      ('deposit', 'Deposits'),
      ('withdrawal', 'Withdrawals'),
      ('transfer_internal', 'Received'),
      ('transfer_external', 'Sent'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: types.map((type) {
        final isSelected = _selectedType == type.$1;
        return FilterChip(
          selected: isSelected,
          label: Text(type.$2),
          labelStyle: TextStyle(
            color: isSelected ? colors.canvas : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          backgroundColor: colors.elevated,
          selectedColor: colors.gold,
          showCheckmark: false,
          side: BorderSide(
            color: isSelected ? colors.gold : colors.borderSubtle,
          ),
          onSelected: (_) {
            setState(() => _selectedType = type.$1);
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatusChips(ThemeColors colors) {
    final statuses = [
      (null, 'All'),
      ('completed', 'Completed'),
      ('pending', 'Pending'),
      ('processing', 'Processing'),
      ('failed', 'Failed'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: statuses.map((status) {
        final isSelected = _selectedStatus == status.$1;
        return FilterChip(
          selected: isSelected,
          label: Text(status.$2),
          labelStyle: TextStyle(
            color: isSelected ? colors.canvas : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          backgroundColor: colors.elevated,
          selectedColor: _getStatusColor(status.$1, colors),
          showCheckmark: false,
          side: BorderSide(
            color: isSelected
                ? _getStatusColor(status.$1, colors)
                : colors.borderSubtle,
          ),
          onSelected: (_) {
            setState(() => _selectedStatus = status.$1);
          },
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String? status, ThemeColors colors) {
    switch (status) {
      case 'completed':
        return AppColors.successText;
      case 'pending':
      case 'processing':
        return AppColors.warningText;
      case 'failed':
        return AppColors.errorText;
      default:
        return colors.gold;
    }
  }

  Widget _buildDateRangeChips(ThemeColors colors) {
    final options = [
      (null, 'All Time'),
      (DateRangeOption.today, 'Today'),
      (DateRangeOption.thisWeek, 'This Week'),
      (DateRangeOption.thisMonth, 'This Month'),
      (DateRangeOption.last3Months, '3 Months'),
      (DateRangeOption.custom, 'Custom'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((option) {
        final isSelected = _selectedDateRange == option.$1;
        return FilterChip(
          selected: isSelected,
          label: Text(option.$2),
          labelStyle: TextStyle(
            color: isSelected ? colors.canvas : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          backgroundColor: colors.elevated,
          selectedColor: colors.gold,
          showCheckmark: false,
          side: BorderSide(
            color: isSelected ? colors.gold : colors.borderSubtle,
          ),
          onSelected: (_) {
            setState(() {
              _selectedDateRange = option.$1;
              if (option.$1 != null && option.$1 != DateRangeOption.custom) {
                final range = option.$1!.dateRange;
                _customStartDate = range.start;
                _customEndDate = range.end;
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCustomDatePickers(AppLocalizations l10n) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Row(
      children: [
        Expanded(
          child: _DatePickerButton(
            label: l10n.filters_from,
            date: _customStartDate,
            dateFormat: dateFormat,
            onTap: () => _selectDate(isStart: true),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _DatePickerButton(
            label: l10n.filters_to,
            date: _customEndDate,
            dateFormat: dateFormat,
            onTap: () => _selectDate(isStart: false),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_customStartDate ?? DateTime.now())
        : (_customEndDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final colors = context.colors;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: colors.gold,
              onPrimary: colors.canvas,
              surface: colors.container,
              onSurface: colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _customStartDate = picked;
        } else {
          _customEndDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            23,
            59,
            59,
          );
        }
      });
    }
  }

  Widget _buildAmountRangeSlider(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;
    final hasRange = _amountRange.start > _minAmount ||
        _amountRange.end < _maxAmount;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              '\$${_amountRange.start.toInt()}',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
            if (hasRange)
              TextButton(
                onPressed: () {
                  setState(() {
                    _amountRange = const RangeValues(_minAmount, _maxAmount);
                  });
                },
                child: Text(
                  l10n.filters_clear,
                  style: TextStyle(color: colors.gold, fontSize: 12),
                ),
              ),
            AppText(
              _amountRange.end >= _maxAmount
                  ? '\$${_maxAmount.toInt()}+'
                  : '\$${_amountRange.end.toInt()}',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: colors.gold,
            inactiveTrackColor: colors.elevated,
            thumbColor: colors.gold,
            overlayColor: colors.gold.withOpacity(0.2),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 10,
            ),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
          ),
          child: RangeSlider(
            values: _amountRange,
            min: _minAmount,
            max: _maxAmount,
            divisions: 100,
            onChanged: (values) {
              setState(() => _amountRange = values);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions(ThemeColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildSortByDropdown(),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildSortOrderToggle(colors),
      ],
    );
  }

  Widget _buildSortByDropdown() {
    return AppSelect<String>(
      value: _sortBy,
      items: const [
        AppSelectItem(
          value: 'createdAt',
          label: 'Date',
          icon: Icons.calendar_today,
        ),
        AppSelectItem(
          value: 'amount',
          label: 'Amount',
          icon: Icons.attach_money,
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _sortBy = value);
        }
      },
      showCheckmark: false,
    );
  }

  Widget _buildSortOrderToggle(ThemeColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SortOrderButton(
            icon: Icons.arrow_downward,
            tooltip: 'Newest/Highest first',
            isSelected: _sortOrder == 'DESC',
            onTap: () => setState(() => _sortOrder = 'DESC'),
            colors: colors,
          ),
          _SortOrderButton(
            icon: Icons.arrow_upward,
            tooltip: 'Oldest/Lowest first',
            isSelected: _sortOrder == 'ASC',
            onTap: () => setState(() => _sortOrder = 'ASC'),
            colors: colors,
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedType != null) count++;
    if (_selectedStatus != null) count++;
    if (_selectedDateRange != null) count++;
    if (_amountRange.start > _minAmount || _amountRange.end < _maxAmount) {
      count++;
    }
    return count;
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedDateRange = null;
      _customStartDate = null;
      _customEndDate = null;
      _amountRange = const RangeValues(_minAmount, _maxAmount);
      _sortBy = 'createdAt';
      _sortOrder = 'DESC';
    });
  }

  void _applyFilters() {
    final filter = TransactionFilter(
      type: _selectedType,
      status: _selectedStatus,
      startDate: _selectedDateRange != null ? _customStartDate : null,
      endDate: _selectedDateRange != null ? _customEndDate : null,
      minAmount: _amountRange.start > _minAmount ? _amountRange.start : null,
      maxAmount: _amountRange.end < _maxAmount ? _amountRange.end : null,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    ref.read(transactionFilterProvider.notifier).setFilter(filter);
    Navigator.of(context).pop();
  }
}

/// Date picker button widget
class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: colors.textTertiary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    label,
                    variant: AppTextVariant.labelSmall,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    date != null ? dateFormat.format(date!) : 'Select',
                    variant: AppTextVariant.bodyMedium,
                    color: date != null
                        ? colors.textPrimary
                        : colors.textTertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sort order toggle button
class _SortOrderButton extends StatelessWidget {
  const _SortOrderButton({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? colors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? colors.canvas : colors.textTertiary,
          ),
        ),
      ),
    );
  }
}
