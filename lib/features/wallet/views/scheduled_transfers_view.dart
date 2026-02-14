import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Frequency of scheduled transfer
enum TransferFrequency {
  once,
  daily,
  weekly,
  biweekly,
  monthly,
}

extension TransferFrequencyExt on TransferFrequency {
  String get label {
    switch (this) {
      case TransferFrequency.once:
        return 'One Time';
      case TransferFrequency.daily:
        return 'Daily';
      case TransferFrequency.weekly:
        return 'Weekly';
      case TransferFrequency.biweekly:
        return 'Every 2 Weeks';
      case TransferFrequency.monthly:
        return 'Monthly';
    }
  }
}

/// Scheduled transfer model
class ScheduledTransfer {
  final String id;
  final String recipientPhone;
  final String recipientName;
  final double amount;
  final TransferFrequency frequency;
  final DateTime nextDate;
  final DateTime? endDate;
  final bool isActive;
  final String? note;

  const ScheduledTransfer({
    required this.id,
    required this.recipientPhone,
    required this.recipientName,
    required this.amount,
    required this.frequency,
    required this.nextDate,
    this.endDate,
    this.isActive = true,
    this.note,
  });
}

// Mock data
final _mockScheduledTransfers = [
  ScheduledTransfer(
    id: '1',
    recipientPhone: '+225 07 12 34 56',
    recipientName: 'Mom',
    amount: 50.00,
    frequency: TransferFrequency.monthly,
    nextDate: DateTime.now().add(const Duration(days: 5)),
    isActive: true,
    note: 'Monthly allowance',
  ),
  ScheduledTransfer(
    id: '2',
    recipientPhone: '+225 05 98 76 54',
    recipientName: 'Rent',
    amount: 200.00,
    frequency: TransferFrequency.monthly,
    nextDate: DateTime.now().add(const Duration(days: 12)),
    isActive: true,
    note: 'Monthly rent',
  ),
  ScheduledTransfer(
    id: '3',
    recipientPhone: '+225 01 23 45 67',
    recipientName: 'Savings',
    amount: 25.00,
    frequency: TransferFrequency.weekly,
    nextDate: DateTime.now().add(const Duration(days: 3)),
    isActive: false,
    note: 'Weekly savings',
  ),
];

class ScheduledTransfersView extends ConsumerStatefulWidget {
  const ScheduledTransfersView({super.key});

  @override
  ConsumerState<ScheduledTransfersView> createState() =>
      _ScheduledTransfersViewState();
}

class _ScheduledTransfersViewState
    extends ConsumerState<ScheduledTransfersView> {
  List<ScheduledTransfer> _transfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _transfers = List.from(_mockScheduledTransfers);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          'Scheduled Transfers',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colors.gold),
            onPressed: () => _showCreateSheet(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.gold),
            )
          : _transfers.isEmpty
              ? _buildEmptyState(colors)
              : RefreshIndicator(
                  onRefresh: _loadTransfers,
                  color: colors.gold,
                  backgroundColor: colors.container,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: _transfers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSummaryCard(colors);
                      }
                      final transfer = _transfers[index - 1];
                      return _ScheduledTransferCard(
                        transfer: transfer,
                        onTap: () => _showTransferDetails(transfer),
                        onToggle: (value) => _toggleTransfer(transfer.id, value),
                        colors: colors,
                      );
                    },
                  ),
                ),
      floatingActionButton: _transfers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSheet(),
              backgroundColor: colors.gold,
              icon: Icon(Icons.add, color: colors.canvas),
              label: Text(
                'New Schedule',
                style: TextStyle(color: colors.canvas),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colors.container,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Icon(
                Icons.schedule,
                color: colors.textTertiary,
                size: 50,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              'No Scheduled Transfers',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Set up automatic recurring transfers to save time.',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Create Schedule',
              onPressed: () => _showCreateSheet(),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeColors colors) {
    final activeTransfers = _transfers.where((t) => t.isActive).toList();
    final totalMonthly = activeTransfers.fold<double>(0, (sum, t) {
      switch (t.frequency) {
        case TransferFrequency.daily:
          return sum + (t.amount * 30);
        case TransferFrequency.weekly:
          return sum + (t.amount * 4);
        case TransferFrequency.biweekly:
          return sum + (t.amount * 2);
        case TransferFrequency.monthly:
        case TransferFrequency.once:
          return sum + t.amount;
      }
    });

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.gold, colors.gold.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Monthly Scheduled',
                variant: AppTextVariant.bodyMedium,
                color: colors.canvas,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.canvas.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: AppText(
                  '${activeTransfers.length} active',
                  variant: AppTextVariant.labelSmall,
                  color: colors.canvas,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            '\$${totalMonthly.toStringAsFixed(2)}',
            variant: AppTextVariant.headlineMedium,
            color: colors.canvas,
          ),
          const SizedBox(height: AppSpacing.xxs),
          AppText(
            'Total outgoing this month',
            variant: AppTextVariant.bodySmall,
            color: colors.canvas,
          ),
        ],
      ),
    );
  }

  void _showCreateSheet() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _CreateScheduleSheet(
          scrollController: scrollController,
          onCreated: (transfer) {
            setState(() {
              _transfers.insert(0, transfer);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Schedule created successfully!'),
                backgroundColor: context.colors.success,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTransferDetails(ScheduledTransfer transfer) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => _TransferDetailsSheet(
        transfer: transfer,
        onDelete: () {
          setState(() {
            _transfers.removeWhere((t) => t.id == transfer.id);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Schedule deleted'),
              backgroundColor: context.colors.success,
            ),
          );
        },
      ),
    );
  }

  void _toggleTransfer(String id, bool isActive) {
    setState(() {
      final index = _transfers.indexWhere((t) => t.id == id);
      if (index != -1) {
        final transfer = _transfers[index];
        _transfers[index] = ScheduledTransfer(
          id: transfer.id,
          recipientPhone: transfer.recipientPhone,
          recipientName: transfer.recipientName,
          amount: transfer.amount,
          frequency: transfer.frequency,
          nextDate: transfer.nextDate,
          endDate: transfer.endDate,
          isActive: isActive,
          note: transfer.note,
        );
      }
    });
  }
}

class _ScheduledTransferCard extends StatelessWidget {
  const _ScheduledTransferCard({
    required this.transfer,
    required this.onTap,
    required this.onToggle,
    required this.colors,
  });

  final ScheduledTransfer transfer;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: transfer.isActive ? colors.borderSubtle : colors.borderSubtle.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: transfer.isActive
                        ? colors.gold.withValues(alpha: 0.2)
                        : colors.container,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: AppText(
                      _getInitials(transfer.recipientName),
                      variant: AppTextVariant.titleMedium,
                      color: transfer.isActive
                          ? colors.gold
                          : colors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        transfer.recipientName,
                        variant: AppTextVariant.bodyLarge,
                        color: transfer.isActive
                            ? colors.textPrimary
                            : colors.textTertiary,
                      ),
                      AppText(
                        transfer.frequency.label,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      '\$${transfer.amount.toStringAsFixed(2)}',
                      variant: AppTextVariant.titleMedium,
                      color: transfer.isActive
                          ? colors.textPrimary
                          : colors.textTertiary,
                    ),
                    Switch.adaptive(
                      value: transfer.isActive,
                      onChanged: onToggle,
                      activeColor: colors.gold,
                    ),
                  ],
                ),
              ],
            ),
            if (transfer.isActive) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: colors.textTertiary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppText(
                      'Next: ${_formatDate(transfer.nextDate)}',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Tomorrow';
    } else if (diff.inDays < 7) {
      return 'In ${diff.inDays} days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _CreateScheduleSheet extends StatefulWidget {
  const _CreateScheduleSheet({
    required this.scrollController,
    required this.onCreated,
  });

  final ScrollController scrollController;
  final ValueChanged<ScheduledTransfer> onCreated;

  @override
  State<_CreateScheduleSheet> createState() => _CreateScheduleSheetState();
}

class _CreateScheduleSheetState extends State<_CreateScheduleSheet> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  TransferFrequency _frequency = TransferFrequency.monthly;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            'Create Scheduled Transfer',
            variant: AppTextVariant.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // Recipient
                AppText(
                  'Recipient Phone',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: _phoneController,
                  hint: '+225 XX XX XX XX',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Amount
                AppText(
                  'Amount (USD)',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: _amountController,
                  hint: '0.00',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.attach_money,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Frequency
                AppText(
                  'Frequency',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: TransferFrequency.values.map((freq) {
                    final isSelected = _frequency == freq;
                    return GestureDetector(
                      onTap: () => setState(() => _frequency = freq),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.gold
                              : colors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: isSelected
                                ? colors.gold
                                : colors.borderSubtle,
                          ),
                        ),
                        child: AppText(
                          freq.label,
                          variant: AppTextVariant.labelMedium,
                          color: isSelected
                              ? colors.canvas
                              : colors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Start Date
                AppText(
                  'Start Date',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: colors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppText(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          variant: AppTextVariant.bodyLarge,
                          color: colors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Note
                AppText(
                  'Note (Optional)',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: _noteController,
                  hint: 'e.g., Monthly rent',
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),

          // Create Button
          AppButton(
            label: 'Create Schedule',
            onPressed: _canCreate() ? _create : null,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final colors = context.colors;
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        final pickerColors = ctx.colors;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.dark(
              primary: pickerColors.gold,
              surface: pickerColors.container,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  bool _canCreate() {
    return _phoneController.text.length >= 8 &&
        (double.tryParse(_amountController.text) ?? 0) > 0;
  }

  void _create() {
    widget.onCreated(ScheduledTransfer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipientPhone: _phoneController.text,
      recipientName: _phoneController.text,
      amount: double.parse(_amountController.text),
      frequency: _frequency,
      nextDate: _startDate,
      isActive: true,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    ));
  }
}

class _TransferDetailsSheet extends StatelessWidget {
  const _TransferDetailsSheet({
    required this.transfer,
    required this.onDelete,
  });

  final ScheduledTransfer transfer;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            'Schedule Details',
            variant: AppTextVariant.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),

          _DetailRow(label: 'Recipient', value: transfer.recipientName),
          _DetailRow(label: 'Phone', value: transfer.recipientPhone),
          _DetailRow(label: 'Amount', value: '\$${transfer.amount.toStringAsFixed(2)}'),
          _DetailRow(label: 'Frequency', value: transfer.frequency.label),
          _DetailRow(
            label: 'Next Transfer',
            value: '${transfer.nextDate.day}/${transfer.nextDate.month}/${transfer.nextDate.year}',
          ),
          if (transfer.note != null)
            _DetailRow(label: 'Note', value: transfer.note!),
          _DetailRow(
            label: 'Status',
            value: transfer.isActive ? 'Active' : 'Paused',
            valueColor: transfer.isActive ? context.colors.success : colors.textTertiary,
          ),

          const SizedBox(height: AppSpacing.xxl),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Delete',
                  onPressed: onDelete,
                  variant: AppButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                  variant: AppButtonVariant.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: valueColor ?? colors.textPrimary,
          ),
        ],
      ),
    );
  }
}
