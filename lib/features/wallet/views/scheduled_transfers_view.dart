import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

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
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Scheduled Transfers',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.gold500),
            onPressed: () => _showCreateSheet(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold500),
            )
          : _transfers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTransfers,
                  color: AppColors.gold500,
                  backgroundColor: AppColors.slate,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: _transfers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSummaryCard();
                      }
                      final transfer = _transfers[index - 1];
                      return _ScheduledTransferCard(
                        transfer: transfer,
                        onTap: () => _showTransferDetails(transfer),
                        onToggle: (value) => _toggleTransfer(transfer.id, value),
                      );
                    },
                  ),
                ),
      floatingActionButton: _transfers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateSheet(),
              backgroundColor: AppColors.gold500,
              icon: const Icon(Icons.add, color: AppColors.obsidian),
              label: const Text(
                'New Schedule',
                style: TextStyle(color: AppColors.obsidian),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
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
                color: AppColors.slate,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.textTertiary,
                size: 50,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppText(
              'No Scheduled Transfers',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppText(
              'Set up automatic recurring transfers to save time.',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
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

  Widget _buildSummaryCard() {
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
        gradient: const LinearGradient(
          colors: AppColors.goldGradient,
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
              const AppText(
                'Monthly Scheduled',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.obsidian,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.obsidian.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: AppText(
                  '${activeTransfers.length} active',
                  variant: AppTextVariant.labelSmall,
                  color: AppColors.obsidian,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            '\$${totalMonthly.toStringAsFixed(2)}',
            variant: AppTextVariant.headlineMedium,
            color: AppColors.obsidian,
          ),
          const SizedBox(height: AppSpacing.xxs),
          const AppText(
            'Total outgoing this month',
            variant: AppTextVariant.bodySmall,
            color: AppColors.obsidian,
          ),
        ],
      ),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
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
              const SnackBar(
                content: Text('Schedule created successfully!'),
                backgroundColor: AppColors.successBase,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTransferDetails(ScheduledTransfer transfer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
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
            const SnackBar(
              content: Text('Schedule deleted'),
              backgroundColor: AppColors.successBase,
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
  });

  final ScheduledTransfer transfer;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: transfer.isActive ? AppColors.borderSubtle : AppColors.borderSubtle.withValues(alpha: 0.5),
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
                        ? AppColors.gold500.withValues(alpha: 0.2)
                        : AppColors.slate,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: AppText(
                      _getInitials(transfer.recipientName),
                      variant: AppTextVariant.titleMedium,
                      color: transfer.isActive
                          ? AppColors.gold500
                          : AppColors.textTertiary,
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
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                      AppText(
                        transfer.frequency.label,
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
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
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                    Switch.adaptive(
                      value: transfer.isActive,
                      onChanged: onToggle,
                      activeColor: AppColors.gold500,
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
                  color: AppColors.slate,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppColors.textTertiary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppText(
                      'Next: ${_formatDate(transfer.nextDate)}',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
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
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
            'Create Scheduled Transfer',
            variant: AppTextVariant.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // Recipient
                const AppText(
                  'Recipient Phone',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: _phoneController,
                  hint: '+225 XX XX XX XX',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Amount
                const AppText(
                  'Amount (USD)',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
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
                const AppText(
                  'Frequency',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
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
                              ? AppColors.gold500
                              : AppColors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.gold500
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: AppText(
                          freq.label,
                          variant: AppTextVariant.labelMedium,
                          color: isSelected
                              ? AppColors.obsidian
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Start Date
                const AppText(
                  'Start Date',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppText(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          variant: AppTextVariant.bodyLarge,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Note
                const AppText(
                  'Note (Optional)',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
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
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold500,
              surface: AppColors.slate,
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
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
            valueColor: transfer.isActive ? AppColors.successBase : AppColors.textTertiary,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            label,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
