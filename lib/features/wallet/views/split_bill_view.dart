import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class SplitBillView extends ConsumerStatefulWidget {
  const SplitBillView({super.key});

  @override
  ConsumerState<SplitBillView> createState() => _SplitBillViewState();
}

class _SplitBillViewState extends ConsumerState<SplitBillView> {
  final _totalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<_Participant> _participants = [];
  bool _splitEqually = true;
  bool _includeMe = true;
  bool _isLoading = false;

  double get _totalAmount => double.tryParse(_totalController.text) ?? 0;

  int get _participantCount => _participants.length + (_includeMe ? 1 : 0);

  double get _myShare {
    if (!_includeMe) return 0;
    if (_splitEqually && _participantCount > 0) {
      return _totalAmount / _participantCount;
    }
    return _totalAmount - _participants.fold(0.0, (sum, p) => sum + p.amount);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Split a Bill',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount
            const AppText(
              'Total Bill Amount',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildAmountInput(),

            const SizedBox(height: AppSpacing.xxl),

            // Description
            const AppText(
              'What\'s this for?',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _descriptionController,
              hint: 'e.g., Dinner at Restaurant',
              prefixIcon: Icons.receipt,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Split Options
            _buildSplitOptions(),

            const SizedBox(height: AppSpacing.xxl),

            // Participants
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Split With',
                  variant: AppTextVariant.titleMedium,
                  color: AppColors.textPrimary,
                ),
                TextButton.icon(
                  onPressed: () => _addParticipant(),
                  icon: const Icon(Icons.add, color: AppColors.gold500, size: 20),
                  label: const AppText(
                    'Add Person',
                    variant: AppTextVariant.labelMedium,
                    color: AppColors.gold500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // My Share
            if (_includeMe) _buildMyShare(),

            // Participants List
            ..._participants.asMap().entries.map((entry) =>
              _buildParticipantCard(entry.key, entry.value)
            ),

            if (_participants.isEmpty && !_includeMe)
              _buildEmptyState(),

            const SizedBox(height: AppSpacing.xxl),

            // Summary
            if (_totalAmount > 0 && _participantCount > 0)
              _buildSummary(),

            const SizedBox(height: AppSpacing.xxl),

            // Send Requests Button
            AppButton(
              label: _isLoading ? 'Sending...' : 'Send Payment Requests',
              onPressed: _canSend() ? _sendRequests : null,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Pending Splits
            _buildPendingSplits(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const AppText(
            '\$',
            variant: AppTextVariant.headlineMedium,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _totalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: AppTypography.headlineMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.textTertiary),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitOptions() {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _splitEqually = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _splitEqually ? AppColors.gold500 : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.view_module,
                          color: _splitEqually ? AppColors.obsidian : AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          'Split Equally',
                          variant: AppTextVariant.labelSmall,
                          color: _splitEqually ? AppColors.obsidian : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _splitEqually = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: !_splitEqually ? AppColors.gold500 : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.tune,
                          color: !_splitEqually ? AppColors.obsidian : AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          'Custom Amounts',
                          variant: AppTextVariant.labelSmall,
                          color: !_splitEqually ? AppColors.obsidian : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Include myself in the split',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textPrimary,
              ),
              Switch(
                value: _includeMe,
                onChanged: (value) => setState(() => _includeMe = value),
                activeColor: AppColors.gold500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyShare() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold500, AppColors.gold600],
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: const Icon(Icons.person, color: AppColors.obsidian),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'You',
                    variant: AppTextVariant.labelLarge,
                    color: AppColors.textPrimary,
                  ),
                  AppText(
                    'Your share',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            AppText(
              '\$${_myShare.toStringAsFixed(2)}',
              variant: AppTextVariant.titleMedium,
              color: AppColors.gold500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard(int index, _Participant participant) {
    final share = _splitEqually && _participantCount > 0
        ? _totalAmount / _participantCount
        : participant.amount;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: Key(participant.phone),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          color: AppColors.errorBase,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          setState(() => _participants.removeAt(index));
        },
        child: AppCard(
          variant: AppCardVariant.subtle,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Center(
                  child: AppText(
                    participant.name[0].toUpperCase(),
                    variant: AppTextVariant.titleMedium,
                    color: AppColors.gold500,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      participant.name,
                      variant: AppTextVariant.labelLarge,
                      color: AppColors.textPrimary,
                    ),
                    AppText(
                      participant.phone,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (!_splitEqually)
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: AppTypography.labelLarge.copyWith(color: AppColors.gold500),
                    decoration: InputDecoration(
                      prefixText: '\$',
                      prefixStyle: AppTypography.labelLarge.copyWith(color: AppColors.gold500),
                      border: InputBorder.none,
                      hintText: '0.00',
                    ),
                    onChanged: (value) {
                      setState(() {
                        participant.amount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                )
              else
                AppText(
                  '\$${share.toStringAsFixed(2)}',
                  variant: AppTextVariant.titleMedium,
                  color: AppColors.textPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            const Icon(
              Icons.group_add,
              color: AppColors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            const AppText(
              'Add people to split with',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final totalAssigned = _participants.fold(0.0, (sum, p) {
      final share = _splitEqually ? _totalAmount / _participantCount : p.amount;
      return sum + share;
    }) + _myShare;

    final remaining = _totalAmount - totalAssigned;

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Total Bill',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
              AppText(
                '\$${_totalAmount.toStringAsFixed(2)}',
                variant: AppTextVariant.labelLarge,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Split among',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
              AppText(
                '$_participantCount people',
                variant: AppTextVariant.labelLarge,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          if (!_splitEqually && remaining.abs() > 0.01) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  remaining > 0 ? 'Unassigned' : 'Over-assigned',
                  variant: AppTextVariant.bodyMedium,
                  color: remaining > 0 ? AppColors.warningBase : AppColors.errorBase,
                ),
                AppText(
                  '\$${remaining.abs().toStringAsFixed(2)}',
                  variant: AppTextVariant.labelLarge,
                  color: remaining > 0 ? AppColors.warningBase : AppColors.errorBase,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Requesting from others',
                variant: AppTextVariant.labelMedium,
                color: AppColors.textPrimary,
              ),
              AppText(
                '\$${(_totalAmount - _myShare).toStringAsFixed(2)}',
                variant: AppTextVariant.titleMedium,
                color: AppColors.gold500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSplits() {
    final pendingSplits = [
      _PendingSplit('Dinner', 120.00, 4, 2, DateTime.now().subtract(const Duration(days: 2))),
      _PendingSplit('Movie Night', 45.00, 3, 3, DateTime.now().subtract(const Duration(days: 5))),
    ];

    if (pendingSplits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Pending Splits',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...pendingSplits.map((split) => _buildPendingSplitItem(split)),
      ],
    );
  }

  Widget _buildPendingSplitItem(_PendingSplit split) {
    final isPaid = split.paidCount == split.totalCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPaid
                    ? AppColors.successBase.withValues(alpha: 0.1)
                    : AppColors.warningBase.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? AppColors.successBase : AppColors.warningBase,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    split.description,
                    variant: AppTextVariant.labelMedium,
                    color: AppColors.textPrimary,
                  ),
                  AppText(
                    '${split.paidCount}/${split.totalCount} paid',
                    variant: AppTextVariant.bodySmall,
                    color: isPaid ? AppColors.successBase : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  '\$${split.amount.toStringAsFixed(2)}',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textPrimary,
                ),
                AppText(
                  _formatDate(split.date),
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }

  void _addParticipant() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Add Person',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppText(
              'Name',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: nameController,
              hint: 'Enter name',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppText(
              'Phone Number',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: phoneController,
              hint: 'Enter phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Add',
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  setState(() {
                    _participants.add(_Participant(
                      name: nameController.text,
                      phone: phoneController.text,
                      amount: 0,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  bool _canSend() {
    return _totalAmount > 0 &&
           _participants.isNotEmpty &&
           _descriptionController.text.isNotEmpty;
  }

  Future<void> _sendRequests() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment requests sent to ${_participants.length} people'),
          backgroundColor: AppColors.successBase,
        ),
      );

      // Clear form
      setState(() {
        _totalController.clear();
        _descriptionController.clear();
        _participants.clear();
      });
    }
  }
}

class _Participant {
  final String name;
  final String phone;
  double amount;

  _Participant({
    required this.name,
    required this.phone,
    required this.amount,
  });
}

class _PendingSplit {
  final String description;
  final double amount;
  final int totalCount;
  final int paidCount;
  final DateTime date;

  _PendingSplit(this.description, this.amount, this.totalCount, this.paidCount, this.date);
}
